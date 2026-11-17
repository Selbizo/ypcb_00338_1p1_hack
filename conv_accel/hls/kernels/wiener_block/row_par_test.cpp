// Streaming 8-core row pass: 8 realtime FFT cores in a dataflow region.
// Proves that the cores can run concurrently; the load/store use the
// transposed tiled buffer in the full kernel.
#include "hls_fft_rt.h"
#include <ap_fixed.h>
#include <hls_stream.h>
#include <complex>

#ifndef N
#define N 256
#endif
#ifndef LOGN
#define LOGN 8
#endif
#ifndef IN_W
#define IN_W 24
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

static void fft_core(hls::stream<cplx_t> &in, hls::stream<cplx_w_t> &out, int n) {
#pragma HLS inline off
    for (int i = 0; i < n; ++i) {
        hls::stream<cfg_t> cfg;
        hls::stream<st_t> st;
        cfg_t c;
        c.setDir(1);
        cfg.write(c);
        hls::fft<fft_cfg_u>(in, out, st, cfg);
        st.read();
    }
}

static cplx_t narrow(cplx_w_t v, int s) {
    return cplx_t(sample_t(v.real() >> s), sample_t(v.imag() >> s));
}

static void load_rows(cplx_t A[N][N], hls::stream<cplx_t> in[8]) {
#pragma HLS inline off
    load_rows(A, in);
}

static void store_rows(hls::stream<cplx_w_t> out[8], cplx_t B[N][N]) {
#pragma HLS inline off
    store_rows(out, B);
}

void row_pass(cplx_t A[N][N], cplx_t B[N][N]) {
#pragma HLS interface ap_memory port=A
#pragma HLS interface ap_memory port=B
#pragma HLS array_partition variable=A cyclic factor=8 dim=1
#pragma HLS array_partition variable=B cyclic factor=8 dim=2
#pragma HLS dataflow

    hls::stream<cplx_t>   in[8];
    hls::stream<cplx_w_t> out[8];

    for (int r0 = 0; r0 < N; r0 += 8)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                in[p].write(A[r0+p][c]);
            }
        }

    fft_core(in[0], out[0], N/8);
    fft_core(in[1], out[1], N/8);
    fft_core(in[2], out[2], N/8);
    fft_core(in[3], out[3], N/8);
    fft_core(in[4], out[4], N/8);
    fft_core(in[5], out[5], N/8);
    fft_core(in[6], out[6], N/8);
    fft_core(in[7], out[7], N/8);

    for (int r0 = 0; r0 < N; r0 += 8)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                B[c][r0+p] = narrow(out[p].read(), 8);
            }
        }
}
