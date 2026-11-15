#include "utils.h"
#include "evaluate_odometry.h"
#include <fstream>
#include <vector>
#include <mutex>
#include <cmath>
#include <algorithm>
#include <utility>
#include <unordered_map>

// --------------------------------
// Keyframe visualization
// --------------------------------
static std::vector<int> keyframe_frame_ids_;
static std::vector<std::vector<cv::Point2f>> keyframe_points_;
static std::vector<cv::Mat> keyframe_poses_;
static std::mutex keyframe_mutex_;

void drawKeyframesOnTrajectory(cv::Mat& trajectory)
{
    std::lock_guard<std::mutex> lock(keyframe_mutex_);
    
    for (size_t i = 0; i < keyframe_poses_.size(); i++) {
        cv::Mat pose_mat = keyframe_poses_[i];
        
        int x = trajectory.cols/2 + int(pose_mat.at<double>(0, 3));
        int y = trajectory.rows/2 - int(pose_mat.at<double>(2, 3));
        
        if (x >= 0 && x < trajectory.cols && y >= 0 && y < trajectory.rows) {
            circle(trajectory, cv::Point(x, y), 8, CV_RGB(0, 255, 255), 2);
            circle(trajectory, cv::Point(x, y), 10, CV_RGB(0, 128, 128), 1);
        }
    }
}

void setKeyframePoints(int frame_id, const std::vector<cv::Point2f>& keypoints, const cv::Mat& pose)
{
    std::lock_guard<std::mutex> lock(keyframe_mutex_);
    
    keyframe_frame_ids_.push_back(frame_id);
    
    std::vector<cv::Point2f> keypoints_scaled;
    for (const auto& kp : keypoints) {
        cv::Point2f kp_scaled(kp.x * 0.1, kp.y * 0.1);
        keypoints_scaled.push_back(kp_scaled);
    }
    keyframe_points_.push_back(keypoints_scaled);
    
    cv::Mat pose_copy = pose.clone();
    keyframe_poses_.push_back(pose_copy);
}

// --------------------------------
// Visualization
// --------------------------------
void drawFeaturePoints(cv::Mat image, std::vector<cv::Point2f>& points)
{
    int radius = 2;
    
    for (int i = 0; i < points.size(); i++)
    {
        circle(image, cv::Point(points[i].x, points[i].y), radius, CV_RGB(255,255,255));
    }
}

// --------------------------------
// Trajectory history
// --------------------------------
// The old implementation accumulated a 3000x3000 raster canvas (27 MB, faded and
// warped on every frame). Instead we keep the raw per-frame path as a compact list
// of world positions and redraw just the 400x400 minimap from it. `base` is the
// uncorrected world position (accumulated loop-closure offset removed); `display`
// holds the corrected positions that are actually drawn.
namespace {

struct TrajSample {
    int id;
    cv::Point2f base;        // world (X, Z) without the accumulated loop correction
};

std::vector<TrajSample> traj_samples_;
std::vector<cv::Point2f> traj_display_;          // corrected world (X, Z)
std::unordered_map<int, int> traj_id_index_;     // frame id -> sample index
cv::Point2f cumulative_offset_(0.0f, 0.0f);      // correction currently baked into frame_pose

// World metres mapped across the minimap width. Halved from 3000 -> 1500 so the
// trajectory is shown at 2x zoom for more detail.
const double kMinimapWorldSpan = 1500.0;

}  // namespace

void display(int frame_id, cv::Mat& trajectory_biased, cv::Mat& pose, float fps)
{
    static std::ofstream coord_file("/home/selbizo/CV/StabAndSLAM/visual_odom/trajectory_coordinates.txt");

    if (coord_file.is_open() && frame_id % 29 == 0) {
        coord_file << frame_id << " "
                   << pose.at<double>(0) << " "
                   << pose.at<double>(1) << " "
                   << pose.at<double>(2) << std::endl;
    }

    const double PX = pose.at<double>(0);
    const double PZ = pose.at<double>(2);

    // Record this frame (once). base strips the correction already baked into frame_pose.
    if (traj_id_index_.find(frame_id) == traj_id_index_.end()) {
        TrajSample s;
        s.id = frame_id;
        s.base = cv::Point2f(static_cast<float>(PX - cumulative_offset_.x),
                             static_cast<float>(PZ - cumulative_offset_.y));
        traj_id_index_[frame_id] = static_cast<int>(traj_samples_.size());
        traj_samples_.push_back(s);
        traj_display_.push_back(s.base + cumulative_offset_);
    }

    // --- Heading from the current direction of motion ---
    static cv::Point2d last_pos(0.0, 0.0);
    static bool        has_last_pos = false;
    static double      view_angle = 0.0;   // rotation applied to the minimap (rad)

    if (has_last_pos) {
        const double dX = PX - last_pos.x;
        const double dZ = PZ - last_pos.y;
        if (std::hypot(dX, dZ) > 1e-2) {
            // Motion vector in image coords (x right, y down)
            const double mx = dX;
            const double my = -dZ;
            // Rotate so the direction of motion points up in the minimap
            const double target = std::atan2(mx, my) + M_PI;
            double diff = target - view_angle;
            while (diff >  M_PI) diff -= 2.0 * M_PI;
            while (diff < -M_PI) diff += 2.0 * M_PI;
            view_angle += 0.15 * diff;   // smooth to avoid jitter
        }
    }
    last_pos = cv::Point2d(PX, PZ);
    has_last_pos = true;

    // --- Render the minimap: current pose at the centre, heading up ---
    trajectory_biased.setTo(cv::Scalar(0, 0, 0));
    const int W = trajectory_biased.cols;
    const int H = trajectory_biased.rows;
    const double sc = W / kMinimapWorldSpan;
    const double c  = std::cos(view_angle);
    const double sn = std::sin(view_angle);
    const cv::Point2f cur = traj_display_.back();

    // Cap the polyline cost for very long runs.
    const size_t total  = traj_display_.size();
    const size_t stride = (total > 4000) ? (total / 4000) : 1;

    auto to_pixel = [&](const cv::Point2f& p) {
        const cv::Point2f d = p - cur;
        const double u =  d.x;   // world X -> right
        const double v = -d.y;   // world Z -> up
        const double rx = c * u - sn * v;
        const double ry = sn * u + c * v;
        return cv::Point(static_cast<int>(std::lround(W * 0.5 + sc * rx)),
                         static_cast<int>(std::lround(H * 0.5 + sc * ry)));
    };

    std::vector<cv::Point> pts;
    pts.reserve(total / stride + 2);
    for (size_t i = 0; i < total; i += stride) {
        pts.push_back(to_pixel(traj_display_[i]));
    }
    if ((total - 1) % stride != 0) {
        pts.push_back(to_pixel(traj_display_.back()));   // newest point exactly at centre
    }

    // Soft pastel blue (BGR) instead of harsh pure white; thin line for detail.
    const cv::Scalar trajColor(231, 211, 181);

    if (pts.size() >= 2) {
        cv::polylines(trajectory_biased, pts, false, trajColor, 2, cv::LINE_AA);
    } else if (pts.size() == 1) {
        cv::circle(trajectory_biased, pts[0], 2, trajColor, -1, cv::LINE_AA);
    }
}

void applyLoopClosurePoses(const std::vector<std::pair<int, cv::Mat>>& corrected_keyframe_poses)
{
    if (corrected_keyframe_poses.empty() || traj_samples_.empty()) {
        return;
    }

    // Corrected absolute positions of the keyframes, sorted by frame id.
    std::vector<std::pair<int, cv::Point2f>> corr;
    corr.reserve(corrected_keyframe_poses.size());
    for (const auto& kv : corrected_keyframe_poses) {
        auto it = traj_id_index_.find(kv.first);
        if (it == traj_id_index_.end()) continue;
        if (kv.second.rows != 4 || kv.second.cols != 4) continue;
        corr.emplace_back(kv.first,
                          cv::Point2f(static_cast<float>(kv.second.at<double>(0, 3)),
                                      static_cast<float>(kv.second.at<double>(2, 3))));
    }
    if (corr.empty()) return;
    std::sort(corr.begin(), corr.end(),
              [](const std::pair<int, cv::Point2f>& a, const std::pair<int, cv::Point2f>& b) {
                  return a.first < b.first;
              });

    // True correction at each keyframe, relative to its stored uncorrected base.
    std::vector<std::pair<int, cv::Point2f>> kd;
    kd.reserve(corr.size());
    for (const auto& c : corr) {
        const cv::Point2f base = traj_samples_[traj_id_index_[c.first]].base;
        kd.emplace_back(c.first, c.second - base);
    }

    // Interpolate the correction over every stored frame so the whole tail is redrawn.
    traj_display_.resize(traj_samples_.size());
    size_t j = 0;
    for (size_t i = 0; i < traj_samples_.size(); ++i) {
        const int id = traj_samples_[i].id;
        cv::Point2f d;
        if (id <= kd.front().first) {
            d = kd.front().second;
        } else if (id >= kd.back().first) {
            d = kd.back().second;
        } else {
            while (j + 1 < kd.size() && kd[j + 1].first < id) ++j;
            const int a = kd[j].first;
            const int b = kd[j + 1].first;
            const float alpha = (b > a) ? static_cast<float>(id - a) / static_cast<float>(b - a) : 0.0f;
            d.x = kd[j].second.x * (1.0f - alpha) + kd[j + 1].second.x * alpha;
            d.y = kd[j].second.y * (1.0f - alpha) + kd[j + 1].second.y * alpha;
        }
        traj_display_[i] = traj_samples_[i].base + d;
    }

    // Frames captured after this correction already live in corrected coordinates
    // (frame_pose was reset), so remember the offset to strip when recording them.
    cumulative_offset_ = kd.back().second;
}

cv::Mat renderTrajectoryMap(int size, int margin)
{
    cv::Mat img(size, size, CV_8UC3, cv::Scalar(0, 0, 0));
    if (traj_display_.size() < 2) {
        return img;
    }

    float minX = traj_display_[0].x, maxX = traj_display_[0].x;
    float minZ = traj_display_[0].y, maxZ = traj_display_[0].y;
    for (const auto& p : traj_display_) {
        minX = std::min(minX, p.x); maxX = std::max(maxX, p.x);
        minZ = std::min(minZ, p.y); maxZ = std::max(maxZ, p.y);
    }
    const double span = std::max({static_cast<double>(maxX - minX),
                                  static_cast<double>(maxZ - minZ), 1.0});
    const double sc = (size - 2.0 * margin) / span;

    std::vector<cv::Point> pts;
    pts.reserve(traj_display_.size());
    for (const auto& p : traj_display_) {
        const int x = static_cast<int>(std::lround(margin + (p.x - minX) * sc));
        const int y = static_cast<int>(std::lround(size - margin - (p.y - minZ) * sc));
        pts.emplace_back(x, y);
    }
    cv::polylines(img, pts, false, cv::Scalar(231, 211, 181), 1, cv::LINE_AA);
    return img;
}

// --------------------------------
// Transformation
// --------------------------------


void integrateOdometryStereo(int frame_i, cv::Mat& rigid_body_transformation, cv::Mat& frame_pose, const cv::Mat& rotation, const cv::Mat& translation_stereo)
{

    // std::cout << "rotation" << rotation << std::endl;
    // std::cout << "translation_stereo" << translation_stereo << std::endl;

    
    cv::Mat addup = (cv::Mat_<double>(1, 4) << 0, 0, 0, 1);

    cv::hconcat(rotation, translation_stereo, rigid_body_transformation);
    cv::vconcat(rigid_body_transformation, addup, rigid_body_transformation);

    // std::cout << "rigid_body_transformation" << rigid_body_transformation << std::endl;

    double scale = sqrt((translation_stereo.at<double>(0))*(translation_stereo.at<double>(0)) 
                        + (translation_stereo.at<double>(1))*(translation_stereo.at<double>(1))
                        + (translation_stereo.at<double>(2))*(translation_stereo.at<double>(2))) ;

    // frame_pose = frame_pose * rigid_body_transformation;
    // std::cout << "scale: " << scale << std::endl;

    rigid_body_transformation = rigid_body_transformation.inv();
    // if ((scale>0.1)&&(translation_stereo.at<double>(2) > translation_stereo.at<double>(0)) && (translation_stereo.at<double>(2) > translation_stereo.at<double>(1))) 
    if (scale > 0.002 && scale < 400000.0) 
    {
      // std::cout << "Rpose" << Rpose << std::endl;

      frame_pose = frame_pose * rigid_body_transformation;

    }
    else 
    {
        // scale is out of range, skip integration but don't print warning
    }
}

bool isRotationMatrix(cv::Mat &R)
{
    cv::Mat Rt;
    transpose(R, Rt);
    cv::Mat shouldBeIdentity = Rt * R;
    cv::Mat I = cv::Mat::eye(3,3, shouldBeIdentity.type());
     
    return  norm(I, shouldBeIdentity) < 1e-6;
     
}
 
// Calculates rotation matrix to euler angles
// The result is the same as MATLAB except the order
// of the euler angles ( x and z are swapped ).
cv::Vec3f rotationMatrixToEulerAngles(cv::Mat &R)
{
 
    assert(isRotationMatrix(R));
     
    float sy = sqrt(R.at<double>(0,0) * R.at<double>(0,0) +  R.at<double>(1,0) * R.at<double>(1,0) );
 
    bool singular = sy < 1e-6; // If
 
    float x, y, z;
    if (!singular)
    {
        x = atan2(R.at<double>(2,1) , R.at<double>(2,2));
        y = atan2(-R.at<double>(2,0), sy);
        z = atan2(R.at<double>(1,0), R.at<double>(0,0));
    }
    else
    {
        x = atan2(-R.at<double>(1,2), R.at<double>(1,1));
        y = atan2(-R.at<double>(2,0), sy);
        z = 0;
    }
    return cv::Vec3f(x, y, z);
     
}

// --------------------------------
// I/O
// --------------------------------

void loadGyro(std::string filename, std::vector<std::vector<double>>& time_gyros)
// read time gyro txt file with format of timestamp, gx, gy, gz
{
    std::ifstream file(filename);

    std::string value;
    double timestamp, gx, gy, gz;

    while (file.good())
    {    

         std::vector<double> time_gyro;

         getline ( file, value, ' ' );
         timestamp = stod(value);
         time_gyro.push_back(timestamp);

         getline ( file, value, ' ' );
         gx = stod(value);
         time_gyro.push_back(gx);

         getline ( file, value, ' ' );
         gy = stod(value);
         time_gyro.push_back(gy);

         getline ( file, value);
         gz = stod(value);
         time_gyro.push_back(gz);

         // printf("t: %f, gx: %f, gy: %f, gz: %f\n" , timestamp, gx, gy, gz);    

         time_gyros.push_back(time_gyro);
    }
}

void loadImageLeft(cv::Mat& image_color, cv::Mat& image_gary, int frame_id, std::string filepath){
    char file[200];
    sprintf(file, "image_0/%06d.png", frame_id);

    // sprintf(file, "image_0/%010d.png", frame_id);
    std::string filename = filepath + std::string(file);
    image_color.release();
    image_gary.release();
    image_color = cv::imread(filename, cv::IMREAD_COLOR);
    cvtColor(image_color, image_gary, cv::COLOR_BGR2GRAY);
}

void loadImageRight(cv::Mat& image_color, cv::Mat& image_gary, int frame_id, std::string filepath){
    char file[200];
    sprintf(file, "image_1/%06d.png", frame_id);

    // sprintf(file, "image_0/%010d.png", frame_id);
    std::string filename = filepath + std::string(file);
    image_color.release();
    image_gary.release();
    image_color = cv::imread(filename, cv::IMREAD_COLOR);
    cvtColor(image_color, image_gary, cv::COLOR_BGR2GRAY);
}

