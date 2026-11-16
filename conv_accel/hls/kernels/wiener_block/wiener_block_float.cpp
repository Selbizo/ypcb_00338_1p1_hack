// Float validation of the block pipeline: forward 2D FFT -> G -> inverse 2D FFT,
// 8 parallel cores, same tiled transpose as the fixed-point kernel.
#include "hls_fft_rt.h"
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

typedef std::complex<float> cplx_t;

struct fft_cfg_f : hls::ip_fft::params_t {
    static const unsigned max_nfft           = LOGN;
    static const unsigned input_width        = 32;
    static const unsigned output_width       = 32;
    static const unsigned phase_factor_width = 24;
    static const unsigned ordering_opt       = hls::ip_fft::natural_order;
    static const unsigned arch_opt           = hls::ip_fft::pipelined_streaming_io;
};
typedef hls::ip_fft::config_t<fft_cfg_f> cfg_t;
typedef hls::ip_fft::status_t<fft_cfg_f> st_t;

static void fft1d(cplx_t xn[N], cplx_t xk[N], int dir) {
    hls::stream<cfg_t> cfg;
    hls::stream<st_t> st;
    cfg_t c;
    c.setDir(dir != 0);
    cfg.write(c);
    hls::fft<fft_cfg_f>(xn, xk, st, cfg);
    st.read();
}

static cplx_t gbin(int kx, int ky, float L, float th, float nsr, float gs) {
    int sx = (kx < N/2) ? kx : kx - N;
    int sy = (ky < N/2) ? ky : ky - N;
    float a  = (L/(float)N) * (sx*cosf(th) + sy*sinf(th));
    float pa = (float)M_PI * a;
    float s  = (fabsf(a) < 1e-9f) ? 1.0f : sinf(pa)/pa;
    float d  = s*s + nsr;
    return cplx_t(gs*s*cosf(pa)/d, gs*s*sinf(pa)/d);
}

void wiener_block_f(cplx_t in[N][N], cplx_t out[N][N],
                    float L, float th, float nsr, float gs) {
#pragma HLS interface ap_memory port=in
#pragma HLS interface ap_memory port=out
#pragma HLS interface ap_ctrl_none port=return

    static cplx_t A[N/8][N/8][8][8];
    static cplx_t B[N/8][N/8][8][8];
#pragma HLS array_partition variable=A complete dim=3
#pragma HLS array_partition variable=A complete dim=4
#pragma HLS array_partition variable=B complete dim=3
#pragma HLS array_partition variable=B complete dim=4

    for (int r = 0; r < N; ++r)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            A[r/8][c/8][r%8][c%8] = in[r][c];
        }

    for (int r0 = 0; r0 < N; r0 += PAR) {
        cplx_t xn[PAR][N], xk[PAR][N];
#pragma HLS array_partition variable=xn complete dim=1
#pragma HLS array_partition variable=xk complete dim=1
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            for (int c = 0; c < N; ++c)
                xn[p][c] = A[(r0+p)/8][c/8][(r0+p)%8][c%8];
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d(xn[p], xk[p], 1);
        }
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                B[c/8][(r0+p)/8][c%8][(r0+p)%8] = xk[p][c];
            }
        }
    }

    for (int c0 = 0; c0 < N; c0 += PAR) {
        cplx_t xn[PAR][N], xk[PAR][N], xi[PAR][N], xo[PAR][N];
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
            fft1d(xn[p], xk[p], 1);
        }
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                xi[p][r] = xk[p][r] * gbin(c0+p, r, L, th, nsr, gs);
            }
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d(xi[p], xo[p], 0);
        }
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                A[r/8][(c0+p)/8][r%8][(c0+p)%8] = xo[p][r];
            }
        }
    }

    for (int r0 = 0; r0 < N; r0 += PAR) {
        cplx_t xn[PAR][N], xk[PAR][N];
#pragma HLS array_partition variable=xn complete dim=1
#pragma HLS array_partition variable=xk complete dim=1
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            for (int c = 0; c < N; ++c)
                xn[p][c] = A[(r0+p)/8][c/8][(r0+p)%8][c%8];
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d(xn[p], xk[p], 0);
        }
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                out[r0+p][c] = xk[p][c];
            }
        }
    }
}
