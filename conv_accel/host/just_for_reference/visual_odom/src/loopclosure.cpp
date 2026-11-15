#include "loopclosure.h"

#include <iostream>
#include <algorithm>
#include <cmath>

#include "posegraph/pose_graph.h"

LoopClosure::LoopClosure() 
    : min_keypoints_(30),
      weak_threshold_(0.7f),
      strong_threshold_(0.85f),
      max_weak_candidates_(5),
      min_match_count_(20),
       keyframe_distance_meters_(50.0f),
       last_keyframe_id_(0),
     current_keyframe_id_(0),
     loop_detected_(false),
     candidate_keyframe_id_(-1),
     candidate_index_(-1),
     needs_correction_(false),
     debug_mode_(false),
     current_similarity_(0.0f),
     current_match_count_(0),
      max_loop_distance_meters_(50.0f),
      min_keyframe_distance_meters_(50.0f) {
    
    std::string model_path = "/home/selbizo-pc/CV_projects/visual_odom/src/dnn_weights/mobilenet_v2_simplified.onnx";
    
    network_ = cv::makePtr<cv::dnn::Net>(cv::dnn::readNetFromONNX(model_path));
    
    if (network_.empty()) {
        std::cerr << "[LoopClosure] Failed to load MobileNetV2 ONNX model" << std::endl;
    }
    
    orb_descriptor_ = cv::ORB::create(200);
    matcher_ = cv::DescriptorMatcher::create("BruteForce-Hamming");

    descriptor_thread_ = std::thread(&LoopClosure::descriptorWorker, this);
}

LoopClosure::~LoopClosure() {
    stopDescriptorWorker();
}

void LoopClosure::stopDescriptorWorker() {
    {
        std::lock_guard<std::mutex> lock(descriptor_queue_mutex_);
        descriptor_stop_ = true;
    }
    descriptor_queue_cv_.notify_all();
    if (descriptor_thread_.joinable()) {
        descriptor_thread_.join();
    }
}

void LoopClosure::descriptorWorker() {
    for (;;) {
        DescriptorJob job;
        {
            std::unique_lock<std::mutex> lock(descriptor_queue_mutex_);
            descriptor_queue_cv_.wait(lock, [this] {
                return descriptor_stop_ || !descriptor_queue_.empty();
            });
            if (descriptor_stop_ && descriptor_queue_.empty()) {
                return;
            }
            job = std::move(descriptor_queue_.front());
            descriptor_queue_.pop();
        }

        // Expensive part runs without holding any lock.
        cv::Mat feature_vec;
        cv::Mat orb_descs;
        std::vector<int> feature_idx;

        if (extractDeepFeatures(job.image, feature_vec)) {
            extractKeypointDescriptors(job.image, job.keypoints, orb_descs, feature_idx);
        }

        {
            std::lock_guard<std::mutex> lock(keyframe_mutex_);
            if (job.index >= 0 && job.index < static_cast<int>(keyframes_.size())) {
                feature_vec.copyTo(keyframes_[job.index].descriptor);
                orb_descs.copyTo(keyframes_[job.index].orb_descriptor);
                keyframes_[job.index].desc_feat_indx = feature_idx;
            }
        }
    }
}

void LoopClosure::setCameraParameters(const cv::Mat& projMatl, const cv::Mat& projMatr) {
    projMatl_ = projMatl.clone();
    projMatr_ = projMatr.clone();
}

void LoopClosure::setParameters(int min_keypoints, float weak_threshold,
                                float strong_threshold, int max_weak_candidates,
                                int min_match_count, float keyframe_distance_meters) {
    min_keypoints_ = min_keypoints;
    weak_threshold_ = weak_threshold;
    strong_threshold_ = strong_threshold;
    max_weak_candidates_ = max_weak_candidates;
    min_match_count_ = min_match_count;
    keyframe_distance_meters_ = keyframe_distance_meters;
}

bool LoopClosure::isKeyframe(const cv::Mat& points3D, int min_points, const cv::Mat& world_pose,
                             const KeyFrame& last_kf, bool has_last_kf, double timestamp_curr) {
    // Quality precondition: a keyframe needs enough reconstructed 3D points.
    if (points3D.empty() || points3D.rows < min_points) {
        return false;
    }

    // First keyframe (no reference yet): accept based on point quality alone.
    bool pose_valid = has_last_kf && !world_pose.empty() && world_pose.rows == 4 && world_pose.cols == 4 &&
                      !last_kf.full_pose.empty() && last_kf.full_pose.rows == 4;
    if (!pose_valid) {
        return true;
    }

    // Orientation change (azimuth / yaw delta) between current pose and last keyframe.
    cv::Mat R_curr = world_pose(cv::Rect(0, 0, 3, 3));
    cv::Mat R_ref = last_kf.full_pose(cv::Rect(0, 0, 3, 3));
    double dz = azimuthDeg(R_curr) - azimuthDeg(R_ref);
    if (dz > 180.0) {
        dz -= 360.0;
    } else if (dz < -180.0) {
        dz += 360.0;
    }
    double orient_deg = std::fabs(dz);

    // Time floor: never create a keyframe sooner than the minimum synthetic gap.
    bool time_ok = (timestamp_curr - last_kf.timestamp_) >= min_keyframe_time_delta_s_;

    // Directional isolation: is there any existing keyframe inside the elongated ellipse
    // centered at the current position, with major axis along the viewing direction?
    cv::Mat P_curr = world_pose(cv::Rect(3, 0, 1, 3));
    cv::Vec3d fwd(R_curr.at<double>(0, 0), R_curr.at<double>(1, 0), R_curr.at<double>(2, 0));
    double n = cv::norm(fwd);
    if (n < 1e-9) {
        fwd = cv::Vec3d(1.0, 0.0, 0.0);
    } else {
        fwd /= n;
    }
    bool spatially_isolated = !anyKeyframeInsideEllipsoid(P_curr, fwd, ellipse_major_m_, ellipse_minor_m_);

    if (use_or_policy_) {
        // Create a keyframe when either the heading changed significantly OR the current
        // position is spatially isolated from all existing keyframes; time floor always applies.
        return time_ok && (orient_deg >= azimuth_threshold_deg_ || spatially_isolated);
    } else {
        // Turn-aware spatiotemporal policy:
        //  - While TURNING (heading changed >= azimuth_threshold since last KF): emit a
        //    dense batch of keyframes, gated only by a short time floor. The heading
        //    threshold itself guarantees a new viewpoint between consecutive KFs.
        //  - On STRAIGHTS: emit a keyframe only after a large spatial gap (large ellipse
        //    around every existing KF) AND the longer straight time floor.
        const bool turning = orient_deg >= azimuth_threshold_deg_;
        if (turning) {
            const bool time_ok_turn =
                (timestamp_curr - last_kf.timestamp_) >= min_keyframe_time_delta_turn_s_;
            return time_ok_turn;
        }
        const bool isolated_straight =
            !anyKeyframeInsideEllipsoid(P_curr, fwd, straight_ellipse_major_m_, straight_ellipse_minor_m_);
        return time_ok && isolated_straight;
    }
}

double LoopClosure::azimuthDeg(const cv::Mat& R) const {
    // Camera forward axis (+X in camera frame) mapped to the world frame and projected onto
    // the horizontal plane gives the heading (azimuth / yaw).
    double wx = R.at<double>(0, 0);
    double wy = R.at<double>(1, 0);
    return std::atan2(wy, wx) * 180.0 / M_PI;
}

bool LoopClosure::anyKeyframeInsideEllipsoid(const cv::Mat& P_curr, const cv::Vec3d& d_hat, float a_meters, float b_meters) const {
    double cx = P_curr.at<double>(0, 0);
    double cy = P_curr.at<double>(1, 0);
    double cz = P_curr.at<double>(2, 0);

    for (const auto& kf : keyframes_) {
        if (!kf.is_keyframe || kf.full_pose.empty() || kf.full_pose.rows != 4) {
            continue;
        }
        double kx = kf.full_pose.at<double>(0, 3);
        double ky = kf.full_pose.at<double>(1, 3);
        double kz = kf.full_pose.at<double>(2, 3);

        double vx = kx - cx;
        double vy = ky - cy;
        double vz = kz - cz;

        double s_par = vx * d_hat[0] + vy * d_hat[1] + vz * d_hat[2];
        cv::Vec3d proj(s_par * d_hat[0], s_par * d_hat[1], s_par * d_hat[2]);
        cv::Vec3d perp(vx - proj[0], vy - proj[1], vz - proj[2]);
        double perp_norm = std::sqrt(perp[0] * perp[0] + perp[1] * perp[1] + perp[2] * perp[2]);

        double term_par = s_par / a_meters;
        double term_perp = perp_norm / b_meters;
        if (term_par * term_par + term_perp * term_perp <= 1.0) {
            return true;
        }
    }
    return false;
}

bool LoopClosure::extractDeepFeatures(const cv::Mat& image, cv::Mat& feature_vec) {
    if (network_.empty()) {
        return false;
    }
    
    cv::Mat dst;
    if (image.empty()) {
        return false;
    }
    
    if (image.channels() == 1) {
        cv::cvtColor(image, dst, cv::COLOR_GRAY2RGB);
    } else {
        image.copyTo(dst);
    }
    
    if (dst.empty()) {
        return false;
    }
    
    cv::Mat blurred;
    cv::GaussianBlur(dst, blurred, cv::Size(7, 7), 0);
    
    cv::Mat blob;
    cv::dnn::blobFromImage(blurred, blob, 1.0/255.0, cv::Size(224, 224),
                           cv::Scalar(0.485, 0.456, 0.406), true, false);
    
    if (blob.empty()) {
        return false;
    }
    
    network_->setInput(blob);
    
    std::string feature_layer_name = "output";
    cv::Mat output = network_->forward(feature_layer_name);
    
    if (output.empty()) {
        return false;
    }
    
    output.copyTo(feature_vec);
    
    float norm = cv::norm(feature_vec);
    if (norm > 1e-6) {
        feature_vec /= norm;
    } else {
        return false;
    }
    
    return true;
}

bool LoopClosure::extractKeypointDescriptors(const cv::Mat& image,
                                            const std::vector<cv::Point2f>& keypoints,
                                            cv::Mat& descriptors,
                                            std::vector<int>& feature_indices) {
    if (orb_descriptor_.empty()) {
        return false;
    }
    
    std::vector<cv::KeyPoint> keypoints_cv;
    for (const auto& kp : keypoints) {
        keypoints_cv.push_back(cv::KeyPoint(kp.x, kp.y, 7.0f));
    }
    
    if (keypoints_cv.empty()) {
        return false;
    }
    
    orb_descriptor_->compute(image, keypoints_cv, descriptors);
    
    if (descriptors.empty()) {
        return false;
    }
    
    feature_indices.clear();
    feature_indices.resize(keypoints_cv.size(), -1);
    
    for (size_t i = 0; i < keypoints_cv.size(); i++) {
        for (size_t j = 0; j < keypoints.size(); j++) {
            if (std::abs(keypoints_cv[i].pt.x - keypoints[j].x) < 1.0f &&
                std::abs(keypoints_cv[i].pt.y - keypoints[j].y) < 1.0f) {
                feature_indices[i] = static_cast<int>(j);
                break;
            }
        }
    }
    
    // Remove any -1 values if they exist
    size_t write_idx = 0;
    for (size_t i = 0; i < feature_indices.size(); i++) {
        if (feature_indices[i] >= 0) {
            feature_indices[write_idx++] = feature_indices[i];
        }
    }
    feature_indices.resize(write_idx);
    
    return feature_indices.size() > 0;
}

bool LoopClosure::matchDescriptors(const cv::Mat& desc1, const cv::Mat& desc2,
                                    std::vector<cv::DMatch>& matches) {
    if (matcher_.empty() || desc1.empty() || desc2.empty()) {
        return false;
    }
    
    matcher_->match(desc1, desc2, matches);
    
    if (matches.empty()) {
        return false;
    }
    
    auto min_it = std::min_element(matches.begin(), matches.end(),
        [](const cv::DMatch& a, const cv::DMatch& b) {
            return a.distance < b.distance;
        });
    
    double distance_threshold = std::max(2.0 * min_it->distance, 30.0);
    
    std::vector<cv::DMatch> filtered_matches;
    for (const auto& match : matches) {
        if (match.distance <= distance_threshold) {
            filtered_matches.push_back(match);
        }
    }
    
    matches = filtered_matches;
    
    return !matches.empty();
}

float LoopClosure::computeSimilarity(const cv::Mat& vec1, const cv::Mat& vec2) {
    if (vec1.empty() || vec2.empty()) {
        return 0.0f;
    }
    
    cv::Mat v1 = vec1.reshape(1, 1);
    cv::Mat v2 = vec2.reshape(1, 1);
    
    if (v1.cols != v2.cols) {
        return 0.0f;
    }
    
    int len = v1.cols;
    float sum = 0.0f;
    
    if (v1.type() == CV_32F) {
        const float* p1 = v1.ptr<float>();
        const float* p2 = v2.ptr<float>();
        for (int i = 0; i < len; i++) {
            sum += p1[i] * p2[i];
        }
    } else if (v1.type() == CV_64F) {
        const double* p1 = v1.ptr<double>();
        const double* p2 = v2.ptr<double>();
        for (int i = 0; i < len; i++) {
            sum += static_cast<float>(p1[i] * p2[i]);
        }
    } else {
        return 0.0f;
    }
    
    return sum;
}

bool LoopClosure::poseCorrectionPnP(const std::vector<cv::Point3f>& points3D,
                                    const std::vector<cv::Point2f>& points2D,
                                    cv::Mat& rotation, cv::Mat& translation) {
    if (points3D.size() < 6 || points2D.size() < 6) {
        return false;
    }
    
    cv::Mat dist_coeff = cv::Mat::zeros(4, 1, CV_64F);
    cv::Mat rvec = cv::Mat::zeros(3, 1, CV_64F);
    cv::Mat tvec = cv::Mat::zeros(3, 1, CV_64F);
    
    cv::Mat K = cv::Mat::zeros(3, 3, CV_64F);
    K.at<double>(0, 0) = projMatl_.at<float>(0, 0);
    K.at<double>(1, 1) = projMatl_.at<float>(1, 1);
    K.at<double>(0, 2) = projMatl_.at<float>(0, 2);
    K.at<double>(1, 2) = projMatl_.at<float>(1, 2);
    K.at<double>(2, 2) = 1.0;
    
    std::vector<int> inliers;
    bool success = cv::solvePnPRansac(points3D, points2D, K, dist_coeff, rvec, tvec,
                                      false, 200, 3.0, 0.99, inliers, cv::SOLVEPNP_ITERATIVE);
    
    if (!success) {
        return false;
    }
    
    if (static_cast<int>(inliers.size()) < 8) {
        return false;
    }
    
    cv::Rodrigues(rvec, rotation);
    tvec.copyTo(translation);
    
    return true;
}

bool LoopClosure::addFrame(int frame_id, const cv::Mat& image_left, const cv::Mat& image_right,
                            const std::vector<cv::Point2f>& keypoints_left,
                            const std::vector<cv::Point2f>& keypoints_right,
                            const cv::Mat& rotation, const cv::Mat& translation,
                            const cv::Mat& points3D, const cv::Mat& world_pose,
                            bool force_keyframe) {
    std::lock_guard<std::mutex> lock(keyframe_mutex_);
    
    KeyFrame last_kf;
    bool has_last_kf = false;
    if (!keyframes_.empty()) {
        for (int i = static_cast<int>(keyframes_.size()) - 1; i >= 0; i--) {
            if (keyframes_[i].is_keyframe) {
                last_kf = keyframes_[i];
                has_last_kf = true;
                break;
            }
        }
    }
    
    // Synthetic absolute time for the current frame (monotonic in frame_id).
    double timestamp_curr = static_cast<double>(frame_id) * synthetic_dt_s_;

    bool is_kf = force_keyframe || isKeyframe(points3D, min_keypoints_, world_pose, last_kf, has_last_kf, timestamp_curr);

    if (debug_mode_ && !is_kf && !force_keyframe) {
        std::cout << "[LoopClosure] Frame " << frame_id << " not a keyframe" << std::endl;
    }

    KeyFrame kf;
    kf.id = frame_id;
    kf.timestamp_ = timestamp_curr;
    kf.rotation = rotation.clone();
    kf.translation = translation.clone();
    kf.keypoints = keypoints_left;
    kf.points3D = points3D;
    kf.is_keyframe = is_kf;
    kf.last_keyframe_pose = has_last_kf ? last_kf.full_pose.clone() : cv::Mat();
    
    // IMPORTANT: full_pose must be the ACCUMULATED world pose of this frame (frame_pose
    // in main.cpp), NOT the frame-to-frame incremental rotation/translation. The loop
    // correction math below relies on candidate_kf.full_pose / current_kf.full_pose being
    // expressed in the same, consistent world coordinate system.
    if (world_pose.rows == 4 && world_pose.cols == 4) {
        kf.full_pose = world_pose.clone();
        if (kf.full_pose.type() != CV_64F) {
            kf.full_pose.convertTo(kf.full_pose, CV_64F);
        }
    } else {
        kf.full_pose = cv::Mat::eye(4, 4, CV_64F);
        if (debug_mode_) {
            std::cerr << "[LoopClosure] WARNING: world_pose is not 4x4, falling back to identity "
                      "for keyframe " << frame_id << std::endl;
        }
    }
    
    if (is_kf) {
        last_keyframe_id_ = frame_id;
        if (debug_mode_) {
            std::cout << "[LoopClosure] Keyframe " << frame_id << " added" << std::endl;
        }
    }
    
    keyframes_.push_back(kf);

    // Deep + ORB descriptors are computed lazily on a worker thread and only for
    // keyframes (not every frame). Non-keyframes are never used as detection queries,
    // so running the DNN on all of them is pure waste.
    if (is_kf) {
        DescriptorJob job;
        job.index = static_cast<int>(keyframes_.size()) - 1;
        job.image = image_left.clone();
        job.keypoints = keypoints_left;
        {
            std::lock_guard<std::mutex> qlock(descriptor_queue_mutex_);
            descriptor_queue_.push(std::move(job));
        }
        descriptor_queue_cv_.notify_one();
    }
    
    current_keyframe_id_ = frame_id;

    // Report whether this frame actually became a keyframe, so callers can log
    // / gate work based on the real decision instead of a forced flag.
    return is_kf;
}

bool LoopClosure::detectLoop() {
    std::lock_guard<std::mutex> lock(keyframe_mutex_);
    
    if (debug_mode_ && !keyframes_.empty()) {
        std::cout << "[LoopClosure] detectLoop called for frame " 
                  << keyframes_.back().id << ", keyframe count: " << keyframes_.size() << std::endl;
    }
    
    loop_detected_ = false;
    candidate_keyframe_id_ = -1;
    needs_correction_ = false;
    current_similarity_ = 0.0f;
    current_match_count_ = 0;
    current_desc_.release();
    candidate_desc_.release();
    
    if (keyframes_.empty()) {
        return false;
    }
    
    // Descriptors are produced asynchronously, so the newest keyframe may not have
    // one yet. Query with the most recent frame whose descriptor is ready.
    int query_idx = -1;
    for (int i = static_cast<int>(keyframes_.size()) - 1; i >= 0; --i) {
        if (!keyframes_[i].descriptor.empty()) {
            query_idx = i;
            break;
        }
    }
    if (query_idx < 0) {
        return false;
    }
    
    KeyFrame& current_kf = keyframes_[query_idx];
    
    cv::Mat current_desc = current_kf.descriptor;
    if (current_desc.empty()) {
        return false;
    }
    
    float max_similarity = 0.0f;
    size_t max_sim_index = 0;
    int num_weak_candidates = 0;
    
    int num_checked = 0;
    for (size_t i = 0; i < keyframes_.size(); i++) {
        if (static_cast<int>(i) == query_idx) {
            continue;
        }
        const KeyFrame& kf = keyframes_[i];
        
        if (!kf.is_keyframe || kf.descriptor.empty() || kf.id >= current_kf.id) {
            continue;
        }
        
        int id_diff = current_kf.id - kf.id;
        
        if (id_diff < min_loop_gap_) {
            continue;
        }
        
        if (max_loop_distance_meters_ > 0) {
            if (!kf.full_pose.empty() && !current_kf.full_pose.empty() &&
                kf.full_pose.rows == 4 && kf.full_pose.cols == 4 &&
                current_kf.full_pose.rows == 4 && current_kf.full_pose.cols == 4) {
                
                cv::Mat t_kf = kf.full_pose(cv::Rect(3, 0, 1, 3));
                cv::Mat t_current = current_kf.full_pose(cv::Rect(3, 0, 1, 3));
                double dist = cv::norm(t_kf - t_current);
                
                if (debug_mode_) {
                    std::cout << "[LoopClosure] Checking frame " << kf.id 
                             << ", world distance: " << dist << "m" << std::endl;
                }
                
                if (dist > max_loop_distance_meters_) {
                    if (debug_mode_) {
                        std::cout << "[LoopClosure] Skip (too far: " << dist << "m > " 
                                 << max_loop_distance_meters_ << "m)" << std::endl;
                    }
                    continue;
                }
            }
        }
        
        num_checked++;
        float similarity = computeSimilarity(current_desc, kf.descriptor);
        
        if (similarity > max_similarity) {
            max_similarity = similarity;
            max_sim_index = i;
        }
        
        if (similarity > weak_threshold_) {
            num_weak_candidates++;
            if (debug_mode_) {
                // std::cout << "[LoopClosure]  Weak candidate: frame " << kf.id 
                //          << ", similarity: " << similarity << std::endl;
            }
        }
    }
    
    if (debug_mode_) {
        std::cout << "[LoopClosure] Checked " << num_checked 
                 << " keyframes, max similarity: " << max_similarity 
                 << ", strong threshold: " << strong_threshold_ << std::endl;
    }
    
    if (max_similarity < strong_threshold_) {
        current_similarity_ = max_similarity;
        return false;
    }
    
    KeyFrame& candidate_kf = keyframes_[max_sim_index];
    current_similarity_ = max_similarity;
    candidate_desc_ = candidate_kf.descriptor.clone();
    current_desc_ = current_desc.clone();
    
    if (debug_mode_) {
        std::cout << "[LoopClosure] Strong match found: current frame " 
                 << current_kf.id << " vs candidate " << candidate_kf.id 
                 << ", similarity: " << max_similarity << std::endl;
    }
    
    if (candidate_kf.orb_descriptor.empty() || current_kf.orb_descriptor.empty()) {
        if (debug_mode_) {
            std::cout << "[LoopClosure] ORB descriptors not ready" << std::endl;
        }
        return false;
    }

    std::vector<cv::DMatch> matches;
    if (!matchDescriptors(candidate_kf.orb_descriptor, current_kf.orb_descriptor, matches)) {
        if (debug_mode_) {
            std::cout << "[LoopClosure] ORB matching failed" << std::endl;
        }
        return false;
    }
    
    current_match_count_ = matches.size();
    
    if (debug_mode_) {
        std::cout << "[LoopClosure] ORB matches found: " << matches.size() 
                 << " (min required: " << min_match_count_ << ")" << std::endl;
    }
    
    if (static_cast<int>(matches.size()) < min_match_count_) {
        return false;
    }
    
    std::vector<cv::Point3f> points3D_cand;
    std::vector<cv::Point2f> points2D_curr;
    
    for (const auto& match : matches) {
        if (match.queryIdx >= static_cast<int>(candidate_kf.desc_feat_indx.size()) ||
            match.trainIdx >= static_cast<int>(current_kf.desc_feat_indx.size())) {
            continue;
        }
        
        int cand_idx = candidate_kf.desc_feat_indx[match.queryIdx];
        int curr_idx = current_kf.desc_feat_indx[match.trainIdx];
        
        if (cand_idx >= 0 && cand_idx < static_cast<int>(candidate_kf.points3D.size()) &&
            curr_idx >= 0 && curr_idx < static_cast<int>(current_kf.keypoints.size())) {
            points3D_cand.push_back(candidate_kf.points3D[cand_idx]);
            points2D_curr.push_back(current_kf.keypoints[curr_idx]);
        }
    }
    
    if (static_cast<int>(points3D_cand.size()) < min_match_count_) {
        return false;
    }
    
    cv::Mat R_correction, t_correction;
    if (!poseCorrectionPnP(points3D_cand, points2D_curr, R_correction, t_correction)) {
        return false;
    }
    
    // R_correction/t_correction from solvePnPRansac describe the CURRENT camera pose
    // expressed in the CANDIDATE keyframe's own LOCAL coordinate frame (because
    // candidate_kf.points3D were triangulated relative to the candidate camera at
    // capture time). This is NOT yet a world-frame correction - it must be composed
    // with the candidate's known world pose to find out where the current frame
    // *should* be in world coordinates, and compared against where odometry drift
    // currently thinks it is.
    cv::Mat T_pnp = cv::Mat::eye(4, 4, CV_64F);
    R_correction.copyTo(T_pnp(cv::Rect(0, 0, 3, 3)));
    t_correction.copyTo(T_pnp(cv::Rect(3, 0, 1, 3)));
    
    if (candidate_kf.full_pose.empty() || current_kf.full_pose.empty()) {
        return false;
    }
    
    // Where the current frame SHOULD be in world coordinates, according to the loop match:
    cv::Mat T_current_estimated_world = candidate_kf.full_pose * T_pnp.inv();
    
    // Where odometry (with accumulated drift) currently thinks the current frame is:
    cv::Mat T_current_naive_world = current_kf.full_pose;
    
    // Calculate correction delta
    cv::Mat T_delta = T_current_estimated_world * T_current_naive_world.inv();
    
    // Extract rotation and translation from correction
    cv::Mat R_delta = T_delta(cv::Rect(0, 0, 3, 3));
    cv::Mat t_delta = T_delta(cv::Rect(3, 0, 1, 3));
    
    // Check if correction is too large (loop between two far images is not reliable)
    cv::Mat rvec_delta;
    cv::Rodrigues(R_delta, rvec_delta);
    double pose_distance_rad = cv::norm(rvec_delta);
    double pose_distance_deg = pose_distance_rad * 180.0 / CV_PI;

    if (pose_distance_deg > max_pose_distance_between_loop_keyframes_) {
        return false;
    }

    // Check pose difference between new and old calculation.
    // cv::norm(rvec) is in RADIANS; max_pose_differnece_between_old_new_ is expressed
    // in DEGREES. Without the conversion the threshold (10.0) was effectively ~573
    // degrees, so the validation never rejected a bad loop correction.
    cv::Mat T_diff = T_current_naive_world * T_current_estimated_world.inv();
    cv::Mat rvec_diff;
    cv::Rodrigues(T_diff(cv::Rect(0, 0, 3, 3)), rvec_diff);
    double pose_diff_rad = cv::norm(rvec_diff);
    double pose_diff_deg = pose_diff_rad * 180.0 / CV_PI;

    if (pose_diff_deg > max_pose_differnece_between_old_new_) {
        return false;
    }

    if (pose_diff_rad < 0.01) {
        needs_correction_ = false;
        return false;
    }
    
    needs_correction_ = true;
    
    if (debug_mode_) {
        std::cout << "[LoopClosure] Pose correction delta: rotation=" << pose_distance_deg << "deg, translation norm=" << cv::norm(t_delta) << std::endl;
        std::cout << "[LoopClosure] Pose difference (new vs old): " << pose_diff_deg << " deg" << std::endl;
    }
    
    loop_rotation_ = R_delta.clone();
    loop_translation_ = t_delta.clone();
    loop_correction_ = T_delta.clone();
    
    candidate_keyframe_id_ = candidate_kf.id;
    candidate_index_ = static_cast<int>(max_sim_index);
    loop_detected_ = true;

    // Accumulate this loop as a relative edge for the pose-graph optimizer.
    // Z_loop (pose of current node in candidate frame) equals T_pnp^{-1}.
    cv::Mat T_pnp_inv = T_pnp.inv();
    if (!used_candidates_.count(candidate_index_)) {
        used_candidates_.insert(candidate_index_);
        LoopConstraint lc;
        lc.i = keyframes_[candidate_index_].id;
        lc.j = current_kf.id;   // query frame (may lag keyframes_.back())
        lc.T_ij = T_pnp_inv.clone();
        lc.w_rot = 100.0;
        lc.w_trans = 100.0;
        stored_loops_.push_back(lc);
    }

    return true;
}

void LoopClosure::applyCorrectionToKeyframes() {
    std::lock_guard<std::mutex> lock(keyframe_mutex_);

    // A loop must have been confirmed first (see detectLoop). If no constraint has been
    // accumulated yet there is nothing to optimize.
    if (stored_loops_.empty()) {
        return;
    }

    // Build the keyframe sequence: only entries flagged as keyframes, in insertion order.
    std::vector<int> kf_idx;
    for (size_t k = 0; k < keyframes_.size(); ++k) {
        if (keyframes_[k].is_keyframe) {
            kf_idx.push_back(static_cast<int>(k));
        }
    }
    if (kf_idx.size() < 2) {
        needs_correction_ = false;
        return;
    }

    // Initial full pose for a given frame id (real KF pose, or identity fallback).
    auto find_pose = [&](int fid) -> cv::Mat {
        for (const auto& kf : keyframes_) {
            if (kf.id == fid && !kf.full_pose.empty()) return kf.full_pose.clone();
        }
        return cv::Mat::eye(4, 4, CV_64F);
    };

    PoseGraphOptimizer optimizer;

    // Nodes: every real keyframe. Insertion order is preserved so the first KF becomes
    // the gauge-fixed anchor (its frame number is used as node id).
    for (int idx : kf_idx) {
        optimizer.addNode(keyframes_[idx].id, keyframes_[idx].full_pose);
    }

    // Loop-closure endpoints must also be nodes even when they are not keyframes.
    for (const LoopConstraint& lc : stored_loops_) {
        optimizer.addNode(lc.i, find_pose(lc.i));
        optimizer.addNode(lc.j, find_pose(lc.j));
    }

    // Odom edges between consecutive keyframes: ideal X_j == X_i * T_ij  =>  T_ij = X_i^{-1} X_j.
    const double odom_w = 1e4;
    for (size_t k = 0; k + 1 < kf_idx.size(); ++k) {
        const cv::Mat& Xi = keyframes_[kf_idx[k]].full_pose;
        const cv::Mat& Xj = keyframes_[kf_idx[k + 1]].full_pose;
        optimizer.addEdge(keyframes_[kf_idx[k]].id, keyframes_[kf_idx[k + 1]].id,
                          Xi.inv() * Xj, odom_w, odom_w);
    }

    // Loop-closure edges: T_ij is the pose of node j expressed in frame i.
    const double loop_w = 100.0;
    for (const LoopConstraint& lc : stored_loops_) {
        optimizer.addEdge(lc.i, lc.j, lc.T_ij, loop_w, loop_w);
    }

    if (!optimizer.optimize()) {
        needs_correction_ = false;
        return;
    }

    // Write the globally consistent poses back to every keyframe.
    int corrected_count = 0;
    for (int idx : kf_idx) {
        cv::Mat T_opt;
        if (optimizer.getNodePose(keyframes_[idx].id, T_opt)) {
            keyframes_[idx].full_pose = T_opt.clone();
            keyframes_[idx].rotation = keyframes_[idx].full_pose(cv::Rect(0, 0, 3, 3)).clone();
            keyframes_[idx].translation = keyframes_[idx].full_pose(cv::Rect(3, 0, 1, 3)).clone();
            corrected_count++;
        }
    }

    needs_correction_ = false;

    if (debug_mode_) {
        std::cout << "[LoopClosure] Pose-graph optimization applied to " << corrected_count
                  << " keyframes (rot cost=" << optimizer.rotationCost()
                  << ", trans cost=" << optimizer.translationCost() << ")" << std::endl;
    }
}

std::vector<KeyFrame> LoopClosure::getKeyframes() {
    std::lock_guard<std::mutex> lock(keyframe_mutex_);
    return keyframes_;
}

int LoopClosure::getKeyframeCount() {
    std::lock_guard<std::mutex> lock(keyframe_mutex_);
    return static_cast<int>(keyframes_.size());
}

int LoopClosure::getRawKeyframeCount() {
    std::lock_guard<std::mutex> lock(keyframe_mutex_);
    return static_cast<int>(keyframes_.size());
}

cv::Mat LoopClosure::getLastKeyframePose() {
    std::lock_guard<std::mutex> lock(keyframe_mutex_);
    for (int k = static_cast<int>(keyframes_.size()) - 1; k >= 0; --k) {
        if (keyframes_[k].is_keyframe && !keyframes_[k].full_pose.empty()) {
            return keyframes_[k].full_pose.clone();
        }
    }
    return cv::Mat();
}

std::vector<std::pair<int, cv::Mat>> LoopClosure::getCorrectedKeyframePoses() {
    std::lock_guard<std::mutex> lock(keyframe_mutex_);
    std::vector<std::pair<int, cv::Mat>> out;
    for (const auto& kf : keyframes_) {
        if (kf.is_keyframe && !kf.full_pose.empty() && kf.full_pose.rows == 4 && kf.full_pose.cols == 4) {
            out.emplace_back(kf.id, kf.full_pose.clone());
        }
    }
    return out;
}

cv::Mat LoopClosure::getLoopCorrection() {
    return loop_correction_.clone();
}

cv::Mat LoopClosure::getLoopRotation() {
    return loop_rotation_.clone();
}

cv::Mat LoopClosure::getLoopTranslation() {
    return loop_translation_.clone();
}
