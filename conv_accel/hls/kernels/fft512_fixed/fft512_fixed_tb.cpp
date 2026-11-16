#include <ap_fixed.h>
#include <hls_stream.h>
#include <complex>
#include <cmath>
#include <cstdio>
#include <cstdlib>

typedef ap_fixed<16, 1> sample_t;
typedef std::complex<sample_t> cplx_t;

void fft512_fixed(cplx_t xn[512], cplx_t xk[512], int dir, int sch, int *ovflo);

int main() {
    const int N = 512;
    cplx_t xn[N], xk[N];
    std::complex<double> ref[N];

    for (int n = 0; n < N; ++n) {
        double re = 0.40 * std::cos(2*M_PI*3.0*n/N) + 0.20*(std::rand()/(double)RAND_MAX - 0.5);
        double im = 0.30 * std::sin(2*M_PI*7.0*n/N) + 0.20*(std::rand()/(double)RAND_MAX - 0.5);
        xn[n] = cplx_t(sample_t(re), sample_t(im));
    }
    for (int n = 0; n < N; ++n) {
        ref[n] = std::complex<double>(xn[n].real().to_double(), xn[n].imag().to_double());
    }

    int schs[] = {0x1AA, 0x0AA, 0x1A9, 0x155};
    for (int t = 0; t < 4; ++t) {
        int ovflo = 0;
        fft512_fixed(xn, xk, 1, schs[t], &ovflo);

        double num = 0.0, den = 0.0;
        for (int k = 0; k < N; ++k) {
            std::complex<double> s(0.0, 0.0);
            for (int n = 0; n < N; ++n) {
                double ph = -2.0*M_PI*k*n/N;
                s += ref[n] * std::complex<double>(std::cos(ph), std::sin(ph));
            }
            std::complex<double> y(xk[k].real().to_double(), xk[k].imag().to_double());
            num += (y * std::conj(s)).real();
            den += std::norm(s);
        }
        double alpha = num / den;
        double err2 = 0.0, ref2 = 0.0;
        for (int k = 0; k < N; ++k) {
            std::complex<double> s(0.0, 0.0);
            for (int n = 0; n < N; ++n) {
                double ph = -2.0*M_PI*k*n/N;
                s += ref[n] * std::complex<double>(std::cos(ph), std::sin(ph));
            }
            std::complex<double> y(xk[k].real().to_double(), xk[k].imag().to_double());
            err2 += std::norm(y - alpha*s);
            ref2 += std::norm(alpha*s);
        }
        double snr = 10.0*std::log10(ref2/err2);
        std::printf("sch=0x%03X  alpha=%.8f (1/alpha=%.1f)  ovflo=%d  SNR=%.1f dB\n",
                    schs[t], alpha, 1.0/alpha, ovflo, snr);
    }
    return 0;
}
