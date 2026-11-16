#include <hls_stream.h>
#include <complex>
#include <cmath>
#include <cstdio>
#include <cstdlib>

void fft512(hls::stream<std::complex<float> > &in,
            hls::stream<std::complex<float> > &out,
            int dir);

int main() {
    const int N = 512;
    std::complex<float> x[N], y[N];

    for (int n = 0; n < N; ++n) {
        double t = 2.0 * M_PI * n / N;
        double re = 1.0*std::cos(3*t) + 0.5*std::cos(17*t)
                  + 0.1*((double)std::rand()/RAND_MAX - 0.5);
        double im = 0.8*std::sin(5*t) + 0.3*std::sin(23*t)
                  + 0.1*((double)std::rand()/RAND_MAX - 0.5);
        x[n] = std::complex<float>((float)re, (float)im);
    }

    hls::stream<std::complex<float> > in, out;
    for (int n = 0; n < N; ++n) in.write(x[n]);

    fft512(in, out, 1);

    for (int k = 0; k < N; ++k) y[k] = out.read();

    double maxerr = 0.0, maxmag = 0.0, err2 = 0.0, ref2 = 0.0;
    for (int k = 0; k < N; ++k) {
        std::complex<double> s(0.0, 0.0);
        for (int n = 0; n < N; ++n) {
            double ph = -2.0 * M_PI * k * n / N;
            s += std::complex<double>(x[n].real(), x[n].imag())
               * std::complex<double>(std::cos(ph), std::sin(ph));
        }
        double e = std::abs(std::complex<double>(y[k].real(), y[k].imag()) - s);
        maxerr = std::max(maxerr, e);
        maxmag = std::max(maxmag, std::abs(s));
        err2 += e*e;
        ref2 += std::norm(s);
    }

    double snr = 10.0 * std::log10(ref2 / err2);
    std::printf("FFT512: max|err| = %.6f, max|ref| = %.3f, rel = %.3e, SNR = %.1f dB\n",
                maxerr, maxmag, maxerr / maxmag, snr);

    if (maxerr / maxmag > 1e-3) { std::printf("FAIL\n"); return 1; }
    std::printf("PASS\n");
    return 0;
}
