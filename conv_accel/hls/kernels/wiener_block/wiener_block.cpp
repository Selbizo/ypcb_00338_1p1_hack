// Block Wiener deconvolution: forward 2D FFT -> analytic sinc OTF -> inverse 2D FFT.
// Fixed-point 16-bit (Q1.15), block-floating-point FFT, 8 parallel 1D cores.
//
//   N, LOGN  : block size (128/512) and log2
//   PAR      : 8 parallel FFT cores
//
// Buffers use an 8x8 tiled layout:
//   A[r/8][c/8][r%8][c%8]
// so the transpose writes (8 rows, one column) and the column reads
// (8 columns, one row) both hit 8 different banks.
#include "hls_fft_rt.h"
#include <ap_fixed.h>
#include <hls_stream.h>
#include <complex>
#include <math.h>

#ifndef N
#define N 128
#endif
#ifndef LOGN
#define LOGN 7
#endif
#define PAR 8

typedef ap_fixed<16, 1> sample_t;
typedef std::complex<sample_t> cplx_t;

struct fft_cfg : hls::ip_fft::params_t {
    static const unsigned max_nfft           = LOGN;
    static const unsigned config_width       = 8;     // BFP: direction only
    static const unsigned input_width        = 16;
    static const unsigned output_width       = 16;
    static const unsigned phase_factor_width = 16;
    static const unsigned ordering_opt       = hls::ip_fft::natural_order;
    static const unsigned scaling_opt        = hls::ip_fft::block_floating_point;
    static const unsigned rounding_opt       = hls::ip_fft::convergent_rounding;
    static const unsigned arch_opt           = hls::ip_fft::pipelined_streaming_io;
};
typedef hls::ip_fft::config_t<fft_cfg> cfg_t;
typedef hls::ip_fft::status_t<fft_cfg> st_t;

static void fft1d(cplx_t xn[N], cplx_t xk[N], int dir, int &E) {
    hls::stream<cfg_t> cfg;
    hls::stream<st_t> st;
    cfg_t c;
    c.setDir(dir != 0);
    cfg.write(c);
    hls::fft<fft_cfg>(xn, xk, st, cfg);
    st_t s = st.read();
    E = s.getBlkExp();
}

static cplx_t sh(cplx_t v, int s) {
    if (s <= 0) return v;
    return cplx_t(v.real() >> s, v.imag() >> s);
}

static cplx_t norm_bfp(cplx_t v, int E) {
    int s = LOGN - E;
    if (s < 0) s = 0;
    return sh(v, s);
}

// Inverse passes: undo the BFP scaling (multiply by 2^E).  The shift must be
// done in a wider type: shifting a Q1.15 value left inside Q1.15 overflows.
typedef ap_fixed<32, 17> wide_t;
static cplx_t unnorm_bfp(cplx_t v, int E) {
    if (E <= 0) return v;
    wide_t re = ((wide_t)v.real()) << E;
    wide_t im = ((wide_t)v.imag()) << E;
    return cplx_t(sample_t(re), sample_t(im));
}

static cplx_t cmul(cplx_t a, cplx_t b) {
    sample_t re = a.real()*b.real() - a.imag()*b.imag();
    sample_t im = a.real()*b.imag() + a.imag()*b.real();
    return cplx_t(re, im);
}

// G(kx,ky) = gs * conj(H) / (|H|^2 + nsr),  H = exp(-i*pi*a)*sinc(pi*a)
static cplx_t gbin(int kx, int ky, double L, double th, double nsr, double gs) {
    int sx = (kx < N/2) ? kx : kx - N;
    int sy = (ky < N/2) ? ky : ky - N;
    double a  = (L/(double)N) * (sx*cos(th) + sy*sin(th));
    double pa = M_PI * a;
    double s  = (fabs(a) < 1e-9) ? 1.0 : sin(pa)/pa;
    double d  = s*s + nsr;
    double re = gs * s *  cos(pa) / d;
    double im = gs * s *  sin(pa) / d;
    return cplx_t(sample_t(re), sample_t(im));
}

void wiener_block(cplx_t in[N][N], cplx_t out[N][N],
                  float Lf, float thf, float nsrf, float gsf) {
#pragma HLS interface ap_memory port=in
#pragma HLS interface ap_memory port=out
#pragma HLS interface ap_ctrl_none port=return

    static cplx_t A[N/8][N/8][8][8];
    static cplx_t B[N/8][N/8][8][8];
#pragma HLS array_partition variable=A complete dim=3
#pragma HLS array_partition variable=A complete dim=4
#pragma HLS array_partition variable=B complete dim=3
#pragma HLS array_partition variable=B complete dim=4

    double L = Lf, th = thf, nsr = nsrf, gs = gsf;

    // ---- load block into A (row-major tiled) ----
    for (int r = 0; r < N; ++r)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            A[r/8][c/8][r%8][c%8] = in[r][c];
        }

    // ---- row FFT -> B (transposed) ----
    for (int r0 = 0; r0 < N; r0 += PAR) {
        cplx_t xn[PAR][N], xk[PAR][N];
        int E[PAR];
#pragma HLS array_partition variable=xn complete dim=1
#pragma HLS array_partition variable=xk complete dim=1
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            for (int c = 0; c < N; ++c)
                xn[p][c] = A[(r0+p)/8][c/8][(r0+p)%8][c%8];
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d(xn[p], xk[p], 1, E[p]);
        }
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                B[c/8][(r0+p)/8][c%8][(r0+p)%8] = norm_bfp(xk[p][c], E[p]);
            }
        }
    }

    // ---- column FFT -> G -> inverse column FFT -> A (transposed back) ----
    for (int c0 = 0; c0 < N; c0 += PAR) {
        cplx_t xn[PAR][N], xk[PAR][N], xi[PAR][N], xo[PAR][N];
        int E[PAR], Ei[PAR];
#pragma HLS array_partition variable=xn complete dim=1
#pragma HLS array_partition variable=xk complete dim=1
#pragma HLS array_partition variable=xi complete dim=1
#pragma HLS array_partition variable=xo complete dim=1
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            for (int r = 0; r < N; ++r)
                xn[p][r] = B[(c0+p)/8][r/8][(c0+p)%8][r%8];
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d(xn[p], xk[p], 1, E[p]);
        }
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                cplx_t v = norm_bfp(xk[p][r], E[p]);
                xi[p][r] = cmul(v, gbin(c0+p, r, L, th, nsr, gs));
            }
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d(xi[p], xo[p], 0, Ei[p]);
        }
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                A[r/8][(c0+p)/8][r%8][(c0+p)%8] = unnorm_bfp(xo[p][r], Ei[p]);
            }
        }
    }

    // ---- inverse row FFT -> out ----
    for (int r0 = 0; r0 < N; r0 += PAR) {
        cplx_t xn[PAR][N], xk[PAR][N];
        int E[PAR];
#pragma HLS array_partition variable=xn complete dim=1
#pragma HLS array_partition variable=xk complete dim=1
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            for (int c = 0; c < N; ++c)
                xn[p][c] = A[(r0+p)/8][c/8][(r0+p)%8][c%8];
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d(xn[p], xk[p], 0, E[p]);
        }
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                out[r0+p][c] = unnorm_bfp(xk[p][c], E[p]);
            }
        }
    }
}
