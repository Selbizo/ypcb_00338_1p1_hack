// Minimal CLI for deblur::Engine: image in, deblurred image out.
#include "deblur/deblur.h"

#include <opencv2/imgcodecs.hpp>

#include <cstdlib>
#include <iostream>
#include <string>

namespace {

deblur::Backend parse_backend(const std::string& s) {
    if (s == "auto")   return deblur::Backend::Auto;
    if (s == "cpu")    return deblur::Backend::CPU;
    if (s == "opencl") return deblur::Backend::OpenCL;
    if (s == "cuda")   return deblur::Backend::CUDA;
    if (s == "fpga")   return deblur::Backend::FPGA;
    throw std::runtime_error("unknown backend: " + s);
}

}  // namespace

int main(int argc, char** argv) {
    std::string in, out = "deblurred.png", backend = "auto";
    float dx = 30.0f, dy = 10.0f, da = 0.1f, exposure = 0.5f, nsr = 0.01f;

    for (int i = 1; i < argc; ++i) {
        const std::string a = argv[i];
        auto next = [&]() -> std::string {
            if (++i >= argc) { std::cerr << "missing value for " << a << "\n"; std::exit(1); }
            return argv[i];
        };
        if (a == "--in")            in = next();
        else if (a == "--out")      out = next();
        else if (a == "--backend")  backend = next();
        else if (a == "--dx")       dx = std::stof(next());
        else if (a == "--dy")       dy = std::stof(next());
        else if (a == "--da")       da = std::stof(next());
        else if (a == "--exposure") exposure = std::stof(next());
        else if (a == "--nsr")      nsr = std::stof(next());
        else if (a == "--list-backends") { std::cout << deblur::backendList() << "\n"; return 0; }
        else if (a == "-h" || a == "--help") {
            std::cout << "usage: deblur_demo --in IMG [--out IMG] [--backend auto|cpu|opencl|cuda|fpga]\n"
                         "                   [--dx 30] [--dy 10] [--da 0.1] [--exposure 0.5] [--nsr 0.01]\n";
            return 0;
        } else {
            std::cerr << "unknown option: " << a << "\n";
            return 1;
        }
    }

    if (in.empty()) { std::cerr << "usage: deblur_demo --in IMG [options]\n"; return 1; }

    cv::Mat src = cv::imread(in, cv::IMREAD_COLOR);
    if (src.empty()) { std::cerr << "cannot read " << in << "\n"; return 1; }

    deblur::MotionParams p;
    p.dx = dx; p.dy = dy; p.dalpha = da; p.exposure = exposure; p.nsr = nsr;

    try {
        auto eng = deblur::Engine::create(parse_backend(backend));
        cv::Mat dst;
        eng->process(src, dst, p);
        if (!cv::imwrite(out, dst)) { std::cerr << "cannot write " << out << "\n"; return 1; }
        std::cout << "backend=" << eng->name() << "  " << src.cols << "x" << src.rows
                  << "  -> " << out << "\n";
    } catch (const std::exception& e) {
        std::cerr << "error: " << e.what() << "\n";
        return 1;
    }
    return 0;
}
