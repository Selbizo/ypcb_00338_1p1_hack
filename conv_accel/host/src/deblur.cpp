#include "deblur/deblur.h"

#include <opencv2/core/ocl.hpp>
#include <opencv2/core/cuda.hpp>

#include <unistd.h>

#include <stdexcept>

namespace deblur {

std::unique_ptr<Engine> makeFpgaEngine();
std::unique_ptr<Engine> makeCpuEngine();
std::unique_ptr<Engine> makeOclEngine();
std::unique_ptr<Engine> makeCudaEngine();

bool Engine::available(Backend b) {
    switch (b) {
        case Backend::CPU:    return true;
        case Backend::FPGA:   return ::access("/dev/xdma0_user", F_OK) == 0;
        case Backend::OpenCL: return cv::ocl::haveOpenCL();
        case Backend::CUDA:   return cv::cuda::getCudaEnabledDeviceCount() > 0;
        case Backend::Auto:   return true;
    }
    return false;
}

std::unique_ptr<Engine> Engine::create(Backend backend, const std::string&) {
    if (backend == Backend::Auto) {
        if (available(Backend::FPGA))        backend = Backend::FPGA;
        else if (available(Backend::CUDA))   backend = Backend::CUDA;
        else if (available(Backend::OpenCL)) backend = Backend::OpenCL;
        else                                 backend = Backend::CPU;
    }
    switch (backend) {
        case Backend::CPU:  return makeCpuEngine();
        case Backend::OpenCL: return makeOclEngine();
        case Backend::CUDA: return makeCudaEngine();
        case Backend::FPGA: return makeFpgaEngine();
        default: throw std::runtime_error("deblur: backend not implemented yet");
    }
}

std::string backendList() {
    std::string s;
    auto add = [&](const char* n, bool ok) {
        if (!ok) return;
        if (!s.empty()) s += ", ";
        s += n;
    };
    add("cpu", true);
    add("fpga", Engine::available(Backend::FPGA));
    add("opencl", Engine::available(Backend::OpenCL));
    add("cuda", Engine::available(Backend::CUDA));
    return s;
}

}  // namespace deblur
