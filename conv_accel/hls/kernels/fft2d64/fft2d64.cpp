// 2D FFT 64x64 on fixed-point 16-bit (Q1.15), single core, for structural
// validation of the row -> transpose -> column flow. Scaled arithmetic 1/64
// per 1D pass, so the 2D result is the DFT / 64^2.
#include "hls_fft_rt.h"
#include <ap_fixed.h>
#include <hls_stream.h>
#include <complex>

typedef ap_fixed<16, 1> sample_t;
typedef std::complex<sample_t> cplx_t;

template <int LOGN>
struct fft_cfg : hls::ip_fft::params_t {
    static const unsigned max_nfft           = LOGN;
    static const unsigned config_width       = (LOGN <= 6) ? 8 : 16;
    static const unsigned input_width        = 16;
    static const unsigned output_width       = 16;
    static const unsigned phase_factor_width = 16;
    static const unsigned ordering_opt       = hls::ip_fft::natural_order;
    static const unsigned scaling_opt        = hls::ip_fft::scaled;
    static const unsigned rounding_opt       = hls::ip_fft::convergent_rounding;
    static const unsigned arch_opt           = hls::ip_fft::pipelined_streaming_io;
};

template <int LOGN>
void fft1d(cplx_t xn[1 << LOGN], cplx_t xk[1 << LOGN], int dir, int sch) {
    hls::stream<hls::ip_fft::config_t<fft_cfg<LOGN> > > cfg;
    hls::stream<hls::ip_fft::status_t<fft_cfg<LOGN> > > st;
    hls::ip_fft::config_t<fft_cfg<LOGN> > c;
    c.setDir(dir != 0);
    c.setSch(sch);
    cfg.write(c);
    hls::fft<fft_cfg<LOGN> >(xn, xk, st, cfg);
    st.read();
}

void fft2d64(cplx_t in[64][64], cplx_t out[64][64]) {
#pragma HLS interface ap_memory port=in
#pragma HLS interface ap_memory port=out
#pragma HLS interface ap_ctrl_none port=return

    cplx_t row[64], rowf[64];
    cplx_t tmp[64][64];

    // rows
    for (int r = 0; r < 64; ++r) {
        for (int c = 0; c < 64; ++c) row[c] = in[r][c];
        fft1d<6>(row, rowf, 1, 0x2A);          // 1/64
        for (int c = 0; c < 64; ++c) tmp[c][r] = rowf[c];   // transpose
    }
    // columns (already transposed)
    for (int c = 0; c < 64; ++c) {
        for (int r = 0; r < 64; ++r) row[r] = tmp[c][r];
        fft1d<6>(row, rowf, 1, 0x2A);
        for (int r = 0; r < 64; ++r) out[r][c] = rowf[r];   // transpose back
    }
}
