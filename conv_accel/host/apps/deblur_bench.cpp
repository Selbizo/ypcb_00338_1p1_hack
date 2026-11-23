// deblur_bench: compare CPU / OpenCL / CUDA / FPGA on the same deblur task.
//
// Every backend runs the same block-Wiener algorithm and receives the same
// image and motion parameters.  The program prints the median wall time of
// `iters` runs (after `warmup` runs), frames per second and the PSNR of each
// backend against the CPU reference.
#include "deblur/deblur.h"

#include <opencv2/core.hpp>
#include <opencv2/core/cuda.hpp>
#include <opencv2/core/ocl.hpp>
#include <opencv2/imgcodecs.hpp>

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

namespace {

deblur::Backend parse_backend(const std::string& s) {
    if (s == "cpu")    return deblur::Backend::CPU;
    if (s == "opencl") return deblur::Backend::OpenCL;
    if (s == "cuda")   return deblur::Backend::CUDA;
    if (s == "fpga")   return deblur::Backend::FPGA;
    throw std::runtime_error("unknown backend: " + s);
}

std::vector<std::string> split(const std::string& s, char sep) {
    std::vector<std::string> out;
    std::string cur;
    for (char c : s) {
        if (c == sep) { if (!cur.empty()) out.push_back(cur); cur.clear(); }
        else cur += c;
    }
    if (!cur.empty()) out.push_back(cur);
    return out;
}

double psnr(const cv::Mat& a, const cv::Mat& b) {
    if (a.size() != b.size() || a.type() != b.type()) return 0.0;
    cv::Mat fa, fb;
    a.convertTo(fa, CV_32F);
    b.convertTo(fb, CV_32F);
    cv::Mat d = fa - fb;
    const double mse = cv::mean(d.mul(d))[0];
    if (mse <= 0.0) return 99.0;
    return 10.0 * std::log10(255.0 * 255.0 / mse);
}

std::string fmt(double v, int prec = 2) {
    std::ostringstream os;
    os << std::fixed << std::setprecision(prec) << v;
    return os.str();
}

}  // namespace

int main(int argc, char** argv) {
    std::string in;
    std::string list = "cpu,opencl,cuda,fpga";
    std::string save_dir;
    int iters = 5, warmup = 1;
    bool use_ref = true;

    deblur::MotionParams p;
    p.dx = 9.0f; p.dy = 0.0f; p.dalpha = 0.0f; p.exposure = 1.0f; p.nsr = 0.01f;

    for (int i = 1; i < argc; ++i) {
        const std::string a = argv[i];
        auto next = [&]() -> std::string {
            if (++i >= argc) { std::cerr << "missing value for " << a << "\n"; std::exit(1); }
            return argv[i];
        };
        if (a == "--in")              in = next();
        else if (a == "--backends")   list = next();
        else if (a == "--iters")      iters = std::max(1, std::stoi(next()));
        else if (a == "--warmup")     warmup = std::max(0, std::stoi(next()));
        else if (a == "--dx")         p.dx = std::stof(next());
        else if (a == "--dy")         p.dy = std::stof(next());
        else if (a == "--da")         p.dalpha = std::stof(next());
        else if (a == "--exposure")   p.exposure = std::stof(next());
        else if (a == "--nsr")        p.nsr = std::stof(next());
        else if (a == "--save")       save_dir = next();
        else if (a == "--no-ref")     use_ref = false;
        else if (a == "-h" || a == "--help") {
            std::cout <<
                "usage: deblur_bench --in IMG [--backends cpu,opencl,cuda,fpga]\n"
                "                    [--iters 5] [--warmup 1] [--no-ref] [--save DIR]\n"
                "                    [--dx 9] [--dy 0] [--da 0] [--exposure 1] [--nsr 0.01]\n";
            return 0;
        } else {
            std::cerr << "unknown option: " << a << "\n";
            return 1;
        }
    }
    if (in.empty()) { std::cerr << "usage: deblur_bench --in IMG [options]\n"; return 1; }

    cv::Mat src = cv::imread(in, cv::IMREAD_COLOR);
    if (src.empty()) { std::cerr << "cannot read " << in << "\n"; return 1; }

    std::cout << "image: " << in << "  " << src.cols << "x" << src.rows
              << "   motion: dx=" << p.dx << " dy=" << p.dy << " da=" << p.dalpha
              << " exposure=" << p.exposure << " nsr=" << p.nsr << "\n";
    if (deblur::Engine::available(deblur::Backend::OpenCL)) {
        cv::ocl::Device d = cv::ocl::Device::getDefault();
        const int t = d.type();
        const char* kind = (t & cv::ocl::Device::TYPE_CPU) ? " (CPU)"
                         : (t & cv::ocl::Device::TYPE_GPU) ? " (GPU)" : "";
        std::cout << "OpenCL device: " << d.name() << kind << "\n";
    }
    if (deblur::Engine::available(deblur::Backend::CUDA)) {
        std::cout << "CUDA device:   " << cv::cuda::DeviceInfo(0).name() << "\n";
    }
    std::cout << "each backend: warmup " << warmup << ", measured runs " << iters << "\n\n";

    // CPU reference (also useful when CPU itself is not in the list).
    cv::Mat ref;
    if (use_ref) {
        try {
            auto cpu = deblur::Engine::create(deblur::Backend::CPU);
            cpu->process(src, ref, p);
        } catch (const std::exception& e) {
            std::cerr << "warning: no CPU reference: " << e.what() << "\n";
            use_ref = false;
        }
    }

    std::cout << std::left << std::setw(9) << "backend"
              << std::right << std::setw(12) << "median ms"
              << std::setw(10) << "fps"
              << std::setw(11) << "vs CPU"
              << "  note\n";
    std::cout << std::string(60, '-') << "\n";

    std::vector<std::string> names = split(list, ',');
    for (const std::string& name : names) {
        deblur::Backend b;
        try {
            b = parse_backend(name);
        } catch (const std::exception& e) {
            std::cout << std::left << std::setw(9) << name << "  skipped: " << e.what() << "\n";
            continue;
        }
        if (!deblur::Engine::available(b)) {
            std::cout << std::left << std::setw(9) << name << "  unavailable on this host\n";
            continue;
        }

        try {
            auto eng = deblur::Engine::create(b);
            cv::Mat dst;
            for (int i = 0; i < warmup; ++i) eng->process(src, dst, p);

            std::vector<double> ms;
            ms.reserve(iters);
            for (int i = 0; i < iters; ++i) {
                const auto t0 = std::chrono::steady_clock::now();
                eng->process(src, dst, p);
                const auto t1 = std::chrono::steady_clock::now();
                ms.push_back(std::chrono::duration<double, std::milli>(t1 - t0).count());
            }
            std::sort(ms.begin(), ms.end());
            const double med = ms[ms.size() / 2];

            std::string note;
            double quality = 0.0;
            if (use_ref && !ref.empty()) {
                quality = psnr(dst, ref);
                note = (b == deblur::Backend::CPU) ? "reference" : "PSNR dB";
            }
            if (!save_dir.empty()) {
                const std::string path = save_dir + "/bench_" + eng->name() + ".png";
                cv::imwrite(path, dst);
            }
            std::cout << std::left << std::setw(9) << eng->name()
                      << std::right << std::setw(12) << fmt(med, 1)
                      << std::setw(10) << fmt(1000.0 / med, 2);
            if (use_ref && !ref.empty()) std::cout << std::setw(11) << fmt(quality, 2);
            else                         std::cout << std::setw(11) << "-";
            std::cout << "  " << note << "\n";
        } catch (const std::exception& e) {
            std::cout << std::left << std::setw(9) << name << "  error: " << e.what() << "\n";
        }
    }
    std::cout << "\nPSNR is measured against the CPU backend on the same input.\n";
    std::cout << "FPGA time includes the XDMA host<->DDR transfers of one frame.\n";
    return 0;
}
