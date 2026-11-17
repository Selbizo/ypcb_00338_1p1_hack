// Block Wiener deconvolution, 16-bit input / unscaled wide-output FFT.
// 8 parallel cores, tiled transpose, analytic sinc OTF.
//
// The unscaled FFT keeps the full range: 16-bit input, (16+LOGN+1)-bit output.
// Between passes the wide result is shifted back to 16 bits by a fixed
// factor; the overall block scale is constant and is removed by the caller.
#include "hls_fft_rt.h"
#include <ap_fixed.h>
#include <hls_stream.h>
#include <complex>
#include <math.h>
#include "g_lut.h"

#ifndef N
#define N 128
#endif
#ifndef LOGN
#define LOGN 7
#endif
#define PAR 8

#ifndef IN_W
#define IN_W 16
#endif

#define OUT_W  (IN_W + LOGN + 1)
#define WIDE_W (((OUT_W + 7) / 8) * 8)
#define WIDE_I (WIDE_W - IN_W + 1)

typedef ap_fixed<IN_W, 1> sample_t;
typedef std::complex<sample_t> cplx_t;
typedef ap_fixed<WIDE_W, WIDE_I> wide_t;
typedef std::complex<wide_t> cplx_w_t;

struct fft_cfg_u : hls::ip_fft::params_t {
    static const unsigned max_nfft           = LOGN;
    static const unsigned config_width       = 8;
    static const unsigned input_width        = IN_W;
    static const unsigned output_width       = OUT_W;
    static const unsigned phase_factor_width = 16;
    static const unsigned ordering_opt       = hls::ip_fft::natural_order;
    static const unsigned scaling_opt        = hls::ip_fft::unscaled;
    static const unsigned rounding_opt       = hls::ip_fft::convergent_rounding;
    static const unsigned arch_opt           = hls::ip_fft::pipelined_streaming_io;
};
typedef hls::ip_fft::config_t<fft_cfg_u> cfg_t;
typedef hls::ip_fft::status_t<fft_cfg_u> st_t;

static void fft1d_u(cplx_t xn[N], cplx_w_t xk[N], int dir) {
    hls::stream<cfg_t> cfg;
    hls::stream<st_t> st;
    cfg_t c;
    c.setDir(dir != 0);
    cfg.write(c);
    hls::fft<fft_cfg_u>(xn, xk, st, cfg);
    st.read();
}

static cplx_t narrow(cplx_w_t v, int s) {
    wide_t re = v.real() >> s;
    wide_t im = v.imag() >> s;
    return cplx_t(sample_t(re), sample_t(im));
}

static cplx_t cmul(cplx_t a, cplx_t b) {
    return cplx_t(a.real()*b.real() - a.imag()*b.imag(),
                  a.real()*b.imag() + a.imag()*b.real());
}

#define LUT_A 96.0f
#define LUT_M 8192
static cplx_t gbin_lut(int kx, int ky, float L, float ct, float st) {
    int sx = (kx < N/2) ? kx : kx - N;
    int sy = (ky < N/2) ? ky : ky - N;
    float a = (L/(float)N) * (sx*ct + sy*st);
    float x = (a + LUT_A) * (LUT_M/(2.0f*LUT_A)) - 0.5f;
    int i0 = (int)x;
    if (i0 < 0) i0 = 0;
    if (i0 >= LUT_M - 1) i0 = LUT_M - 2;
    float f = x - (float)i0;
    if (f < 0.0f) f = 0.0f;
    if (f > 1.0f) f = 1.0f;
    float re = (1.0f-f)*g_lut_re[i0] + f*g_lut_re[i0+1];
    float im = (1.0f-f)*g_lut_im[i0] + f*g_lut_im[i0+1];
    return cplx_t(sample_t(re/32768.0f), sample_t(im/32768.0f));
}

void wiener_block_u(cplx_t in[N][N], cplx_w_t out[N][N],
                    float Lf, float thf, float nsrf, float gsf, int mode) {
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
    float ct = cosf((float)th), st = sinf((float)th);
    (void)nsr; (void)gs;

    for (int r = 0; r < N; ++r)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            A[r/8][c/8][r%8][c%8] = in[r][c];
        }

    // forward rows -> B (transposed), /256
    for (int r0 = 0; r0 < N; r0 += PAR) {
        cplx_t xn[PAR][N];
        cplx_w_t xk[PAR][N];
#pragma HLS array_partition variable=xn complete dim=1
#pragma HLS array_partition variable=xk complete dim=1
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            for (int c = 0; c < N; ++c)
                xn[p][c] = A[(r0+p)/8][c/8][(r0+p)%8][c%8];
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d_u(xn[p], xk[p], 1);
        }
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                B[c/8][(r0+p)/8][c%8][(r0+p)%8] = narrow(xk[p][c], 8);
            }
        }
    }

    // forward columns -> G -> inverse columns -> A (transposed back)
    for (int c0 = 0; c0 < N; c0 += PAR) {
        cplx_t xn[PAR][N], xi[PAR][N];
        cplx_w_t xk[PAR][N], xo[PAR][N];
#pragma HLS array_partition variable=xn complete dim=1
#pragma HLS array_partition variable=xi complete dim=1
#pragma HLS array_partition variable=xk complete dim=1
#pragma HLS array_partition variable=xo complete dim=1
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            for (int r = 0; r < N; ++r)
                xn[p][r] = B[(c0+p)/8][r/8][(c0+p)%8][r%8];
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d_u(xn[p], xk[p], 1);
        }
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                cplx_t v = narrow(xk[p][r], 8);
                xi[p][r] = mode ? v : cmul(v, gbin_lut(c0+p, r, (float)L, ct, st));
            }
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d_u(xi[p], xo[p], 0);
        }
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                A[r/8][(c0+p)/8][r%8][(c0+p)%8] = narrow(xo[p][r], 4);
            }
        }
    }

    // inverse rows -> out (wide)
    for (int r0 = 0; r0 < N; r0 += PAR) {
        cplx_t xn[PAR][N];
        cplx_w_t xk[PAR][N];
#pragma HLS array_partition variable=xn complete dim=1
#pragma HLS array_partition variable=xk complete dim=1
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            for (int c = 0; c < N; ++c)
                xn[p][c] = A[(r0+p)/8][c/8][(r0+p)%8][c%8];
        }
        for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
            fft1d_u(xn[p], xk[p], 0);
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
