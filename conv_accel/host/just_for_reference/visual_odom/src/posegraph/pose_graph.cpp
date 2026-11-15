#include "posegraph/pose_graph.h"

#include <Eigen/SparseCore>
#include <Eigen/SparseCholesky>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <cmath>
#include <vector>

namespace {

// Axis-angle exponential map so(3) -> SO(3) (Rodrigues formula).
Eigen::Matrix3d exp_so3(const Eigen::Vector3d& w) {
    const double theta2 = w.squaredNorm();
    Eigen::Matrix3d I = Eigen::Matrix3d::Identity();
    if (theta2 < 1e-12) {
        return I + 0.5 * (w * w.transpose());   // second-order near identity
    }
    const double theta = std::sqrt(theta2);
    const double a = std::sin(theta) / theta;
    const double b = (1.0 - std::cos(theta)) / theta2;
    Eigen::Matrix3d W;
    W <<     0.0, -w(2),  w(1),
         w(2),      0.0, -w(0),
        -w(1),  w(0),      0.0;
    return I + a * W + b * (W * W);
}

// Logarithm SO(3) -> so(3). Returns the rotation vector (axis*angle).
// Eigen's AngleAxisd extracts the axis robustly, including the near-pi case
// (the previous hand-rolled recovery used R^T*R which is always identity and
// therefore returned the wrong axis for a ~180 degree residual).
Eigen::Vector3d log_so3(const Eigen::Matrix3d& R) {
    const Eigen::AngleAxisd aa(R);
    return aa.angle() * aa.axis();
}

// Scalar damping added to every diagonal block to keep the sparse normal
// equations positive definite even for disconnected graph components.
constexpr double kDiagRegularization = 1e-9;

inline Eigen::Matrix3d mat3(const cv::Mat& M) {
    Eigen::Matrix3d R;
    for (int r = 0; r < 3; ++r)
        for (int c = 0; c < 3; ++c)
            R(r, c) = M.at<double>(r, c);
    return R;
}

inline Eigen::Vector3d vec3(const cv::Mat& M) {
    return Eigen::Vector3d(M.at<double>(0, 3), M.at<double>(1, 3), M.at<double>(2, 3));
}

inline void to_mat4(const Eigen::Matrix3d& R, const Eigen::Vector3d& t, cv::Mat& out) {
    out = cv::Mat::eye(4, 4, CV_64F);
    for (int r = 0; r < 3; ++r)
        for (int c = 0; c < 3; ++c)
            out.at<double>(r, c) = R(r, c);
    out.at<double>(0, 3) = t(0);
    out.at<double>(1, 3) = t(1);
    out.at<double>(2, 3) = t(2);
}

}  // namespace

void PoseGraphOptimizer::reset() {
    ids_.clear();
    id_to_idx_.clear();
    R_.clear();
    t_.clear();
    edges_.clear();
    rot_cost_ = 0.0;
    trans_cost_ = 0.0;
}

void PoseGraphOptimizer::addNode(int id, const cv::Mat& T_world) {
    if (id_to_idx_.count(id)) return;
    int idx = static_cast<int>(ids_.size());
    ids_.push_back(id);
    id_to_idx_[id] = idx;
    R_.push_back(mat3(T_world));
    t_.push_back(vec3(T_world));
}

void PoseGraphOptimizer::addEdge(int id_i, int id_j, const cv::Mat& T_ij,
                                 double weight_rot, double weight_trans) {
    if (!id_to_idx_.count(id_i) || !id_to_idx_.count(id_j)) return;
    Edge e;
    e.i = id_to_idx_[id_i];
    e.j = id_to_idx_[id_j];
    e.R_ij = mat3(T_ij);
    e.t_ij = vec3(T_ij);
    e.w_rot = weight_rot;
    e.w_trans = weight_trans;
    edges_.push_back(e);
}

namespace {

// Build the sparse Hessian (3N x 3N) and gradient for the current estimates.
// Blocks are accumulated as triplets so duplicate entries are summed by
// setFromTriplets. Diagonal damping and the node-0 gauge pin are added inline.
void build_sparse_system(int N, const std::vector<PoseGraphOptimizer::Edge>& edges,
                         const std::vector<Eigen::Matrix3d>& R,
                         const std::vector<Eigen::Vector3d>& t,
                         bool rotation_stage, double damping,
                         Eigen::SparseMatrix<double>& H, Eigen::VectorXd& g) {
    std::vector<Eigen::Triplet<double>> trips;
    trips.reserve(edges.size() * 36 + 3 * N + 3);
    g = Eigen::VectorXd::Zero(3 * N);

    const Eigen::Matrix3d I3 = Eigen::Matrix3d::Identity();

    for (const auto& e : edges) {
        Eigen::Matrix<double, 6, 6> B;
        Eigen::Matrix<double, 6, 1> rhs;
        const int bi[2] = {3 * e.i, 3 * e.j};

        if (rotation_stage) {
            const Eigen::Matrix3d Rij = R[e.i] * e.R_ij;
            const Eigen::Vector3d err = log_so3(Rij.transpose() * R[e.j]);
            const double w = e.w_rot;

            B.block<3, 3>(0, 0) =  w * I3;
            B.block<3, 3>(0, 3) = -w * I3;
            B.block<3, 3>(3, 0) = -w * I3;
            B.block<3, 3>(3, 3) =  w * I3;
            rhs.segment<3>(0) = -w * err;
            rhs.segment<3>(3) =  w * err;
        } else {
            const Eigen::Vector3d r = (t[e.j] - t[e.i]) - R[e.i] * e.t_ij;
            const double w = e.w_trans;

            B.block<3, 3>(0, 0) =  w * I3;
            B.block<3, 3>(0, 3) = -w * I3;
            B.block<3, 3>(3, 0) = -w * I3;
            B.block<3, 3>(3, 3) =  w * I3;
            rhs.segment<3>(0) = -w * r;
            rhs.segment<3>(3) =  w * r;
        }

        for (int a = 0; a < 6; ++a) {
            const int row = bi[a < 3 ? 0 : 1] + (a % 3);
            g(row) += rhs(a);
            for (int b = 0; b < 6; ++b) {
                const int col = bi[b < 3 ? 0 : 1] + (b % 3);
                trips.emplace_back(row, col, B(a, b));
            }
        }
    }

    // Regularization on every diagonal + pin the first node's translation/rotation
    // to remove the global gauge freedom.
    const double pin = 1e8;
    for (int d = 0; d < 3 * N; ++d) trips.emplace_back(d, d, damping);
    for (int c = 0; c < 3; ++c) trips.emplace_back(c, c, pin);

    H.resize(3 * N, 3 * N);
    H.setFromTriplets(trips.begin(), trips.end());
    H.makeCompressed();
}

}  // namespace

bool PoseGraphOptimizer::optimize() {
    const int N = static_cast<int>(R_.size());
    if (N == 0) return false;

    // ---- Stage 1: rotations on SO(3), Levenberg-Marquardt ------------------
    // Sparse normal equations (H + lambda*I) dx = -g, solved with a sparse
    // Cholesky factorization. Cost is O(nnz) instead of the previous dense O(N^3),
    // which removes the multi-second freeze when a loop closes.
    {
        const int max_rot_iters = 30;
        double lambda = 1e-4;

        auto rotation_cost = [&](const std::vector<Eigen::Matrix3d>& Rot) {
            double c = 0.0;
            for (const Edge& e : edges_) {
                const Eigen::Matrix3d Rij = Rot[e.i] * e.R_ij;
                const Eigen::Vector3d err = log_so3(Rij.transpose() * Rot[e.j]);
                c += e.w_rot * err.dot(err);
            }
            return c;
        };

        double cost = rotation_cost(R_);

        for (int it = 0; it < max_rot_iters; ++it) {
            Eigen::SparseMatrix<double> H;
            Eigen::VectorXd g;
            build_sparse_system(N, edges_, R_, t_, true, lambda, H, g);

            Eigen::SimplicialLDLT<Eigen::SparseMatrix<double>> solver;
            solver.compute(H);
            if (solver.info() != Eigen::Success) break;

            Eigen::VectorXd dx = solver.solve(-g);
            if (solver.info() != Eigen::Success || dx.hasNaN()) break;

            std::vector<Eigen::Matrix3d> R_try = R_;
            double step_norm = 0.0;
            for (int k = 0; k < N; ++k) {
                const Eigen::Vector3d dk = dx.segment<3>(3 * k);
                step_norm += dk.norm();
                R_try[k] = exp_so3(dk) * R_[k];
            }

            const double new_cost = rotation_cost(R_try);
            if (new_cost < cost) {
                R_.swap(R_try);
                cost = new_cost;
                lambda = std::max(lambda * 0.5, 1e-12);
                if (step_norm < 1e-9) break;
            } else {
                lambda *= 3.0;
                if (lambda > 1e8) break;
            }
        }
        rot_cost_ = cost;
    }

    // ---- Stage 2: translations, sparse linear weighted least-squares -------
    {
        Eigen::SparseMatrix<double> H;
        Eigen::VectorXd g;
        build_sparse_system(N, edges_, R_, t_, false, kDiagRegularization, H, g);

        Eigen::SimplicialLDLT<Eigen::SparseMatrix<double>> solver;
        solver.compute(H);
        if (solver.info() != Eigen::Success) {
            trans_cost_ = 0.0;
            return false;
        }
        Eigen::VectorXd dx = solver.solve(-g);
        if (solver.info() != Eigen::Success || dx.hasNaN()) {
            trans_cost_ = 0.0;
            return false;
        }

        for (int k = 0; k < N; ++k) {
            t_[k] += dx.segment<3>(3 * k);
        }

        double residual = 0.0;
        for (const Edge& e : edges_) {
            const Eigen::Vector3d r = (t_[e.j] - t_[e.i]) - R_[e.i] * e.t_ij;
            residual += e.w_trans * r.dot(r);
        }
        trans_cost_ = residual;
    }

    return true;
}

bool PoseGraphOptimizer::getNodePose(int id, cv::Mat& T_world_out) const {
    auto it = id_to_idx_.find(id);
    if (it == id_to_idx_.end()) return false;
    to_mat4(R_[it->second], t_[it->second], T_world_out);
    return true;
}
