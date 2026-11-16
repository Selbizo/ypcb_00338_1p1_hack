// Multi-backend motion deblurring API.
//
// One OpenCV-facing engine with selectable backends:
//   CPU     - reference implementation (host)
//   OpenCL  - GPU via OpenCV T-API / custom kernels
//   CUDA    - GPU via OpenCV CUDA / custom kernels
//   FPGA    - YPCB-00338-1P1 (Kintex-7) over PCIe
//
// The caller always works with cv::Mat / cv::UMat and MotionParams; the
// backend is chosen once at start-up and can be changed at run time.
#pragma once

#include <opencv2/core.hpp>

#include <memory>
#include <string>

namespace deblur {

// Motion between two frames, as estimated by estimateAffine2D():
//   p(u) = c + u*T + R(u*Phi)*(p - c),  T = exposure*(dx,dy), Phi = exposure*dalpha
struct MotionParams {
    float dx       = 0.0f;   // px per frame, full resolution
    float dy       = 0.0f;   // px per frame, full resolution
    float dalpha   = 0.0f;   // rad per frame (roll around the view axis)
    float exposure = 0.2f;   // D: exposure time / frame interval
    float nsr      = 0.01f;  // Wiener noise-to-signal ratio
    int   block    = 512;    // FFT block size
    int   hop      = 256;    // valid tile inside the block (50% overlap)
};

enum class Backend { Auto, CPU, OpenCL, CUDA, FPGA };

class Engine {
public:
    virtual ~Engine() = default;

    // src/dst: CV_8UC1 or CV_8UC3, same size. Implementations may accept
    // cv::UMat / cv::cuda::GpuMat and keep data on the device.
    virtual void process(cv::InputArray src, cv::OutputArray dst,
                         const MotionParams& p) = 0;

    virtual const char* name() const = 0;

    // config:
    //   FPGA   - optional PCIe BDF or "" for auto-detect
    //   OpenCL - optional device index
    //   CUDA   - optional device index
    static std::unique_ptr<Engine> create(Backend backend,
                                          const std::string& config = std::string());

    static bool available(Backend backend);
};

// Short human-readable list of usable backends (for CLI --list-backends).
std::string backendList();

}  // namespace deblur
