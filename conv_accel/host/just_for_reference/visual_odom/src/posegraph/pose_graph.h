#ifndef POSE_GRAPH_H
#define POSE_GRAPH_H

#include <opencv2/opencv.hpp>

#include <Eigen/Dense>
#include <vector>
#include <unordered_map>
#include <unordered_set>

// Sparse SE(3) pose-graph optimizer used to correct a keyframe trajectory.
//
// The graph nodes are full camera poses X_i in SE(3); the edges are relative
// constraints "pose of node j expressed in frame i" (ideal X_j == X_i * T_ij).
// Two independent Gauss-Newton passes solve the problem:
//   1) rotations on SO(3) with residual e = log((R_i R_ij)^T R_j),
//   2) translations given the optimized rotations, a linear weighted least-squares.
// Eigen is used internally; the public interface only touches cv::Mat 4x4 poses.
class PoseGraphOptimizer {
public:
    void reset();

    // Register a node with its initial SE(3) estimate (4x4 CV_64F, orthonormal R).
    void addNode(int id, const cv::Mat& T_world);

    // Relative constraint: T_ij is the pose of node j in frame i (ideal X_j == X_i * T_ij).
    // weight_rot / weight_trans scale the 3x3 identity information blocks.
    void addEdge(int id_i, int id_j, const cv::Mat& T_ij,
                 double weight_rot = 1.0, double weight_trans = 1.0);

    // Run both optimization passes; corrected poses are available via getNodePose().
    bool optimize();

    // Optimized pose for a node after optimize() (4x4 CV_64F). Returns false if unknown.
    bool getNodePose(int id, cv::Mat& T_world_out) const;

    int nodeCount() const { return static_cast<int>(R_.size()); }
    std::vector<int> nodeIds() const { return ids_; }

    double rotationCost() const { return rot_cost_; }
    double translationCost() const { return trans_cost_; }

    // Relative constraint between two nodes (stored in insertion order).
    struct Edge {
        int i, j;
        Eigen::Matrix3d R_ij;
        Eigen::Vector3d t_ij;
        double w_rot;
        double w_trans;
    };

private:
    std::vector<int> ids_;                       // node id in insertion order (== index)
    std::unordered_map<int, int> id_to_idx_;     // node id -> storage index
    std::vector<Eigen::Matrix3d> R_;             // current rotation estimate per node
    std::vector<Eigen::Vector3d> t_;             // current translation estimate per node
    std::vector<Edge> edges_;

    double rot_cost_ = 0.0;
    double trans_cost_ = 0.0;
};

#endif
