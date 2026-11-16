#include <ap_fixed.h>
#include <complex>
#include <cmath>
#include <cstdio>
#include <cstdlib>

typedef ap_fixed<16, 1> sample_t;
typedef std::complex<sample_t> cplx_t;

void fft2d64(cplx_t in[64][64], cplx_t out[64][64]);

int main() {
    const int N = 64;
    cplx_t in[N][N], out[N][N];
    std::complex<double> ref[N][N];

    for (int y = 0; y < N; ++y)
        for (int x = 0; x < N; ++x) {
            double v = 0.20
                     + 0.20*std::cos(2*M_PI*(3.0*x + 5.0*y)/N)
                     + 0.10*std::sin(2*M_PI*(7.0*x - 2.0*y)/N)
                     + 0.05*((double)std::rand()/RAND_MAX - 0.5);
            in[y][x] = cplx_t(sample_t(v), sample_t(0.0));
        }

    for (int y = 0; y < N; ++y)
        for (int x = 0; x < N; ++x)
            ref[y][x] = std::complex<double>(in[y][x].real().to_double(),
                                             in[y][x].imag().to_double());

    fft2d64(in, out);

    double err2 = 0.0, ref2 = 0.0, maxe = 0.0;
    for (int ky = 0; ky < N; ++ky)
        for (int kx = 0; kx < N; ++kx) {
            std::complex<double> s(0.0, 0.0);
            for (int y = 0; y < N; ++y)
                for (int x = 0; x < N; ++x) {
                    double ph = -2.0*M_PI*(kx*x + ky*y)/(double)N;
                    s += ref[y][x] * std::complex<double>(std::cos(ph), std::sin(ph));
                }
            s /= (double)(N*N);
            std::complex<double> o(out[ky][kx].real().to_double(),
                                   out[ky][kx].imag().to_double());
            double e = std::abs(o - s);
            err2 += e*e;
            ref2 += std::norm(s);
            if (e > maxe) maxe = e;
        }

    std::printf("2D FFT64: SNR = %.1f dB  max|err| = %.5f  DC ref %.4f out %.4f\n",
                10.0*std::log10(ref2/err2), maxe, ref[0][0].real(),
                out[0][0].real().to_double());
    return 0;
}
