// 512-point fixed-point FFT (16-bit, Q1.15) through the generic hls::fft API.
// The build copies hls_fft.h and switches throttle_scheme to "realtime".
#include "hls_fft_rt.h"
#include <ap_fixed.h>
#include <hls_stream.h>
#include <complex>

typedef ap_fixed<16, 1> sample_t;
typedef std::complex<sample_t> cplx_t;

struct fft512_config : hls::ip_fft::params_t {
    static const unsigned max_nfft           = 9;   // 512
    static const unsigned input_width        = 16;
    static const unsigned output_width       = 16;
    static const unsigned phase_factor_width = 16;
    static const unsigned ordering_opt       = hls::ip_fft::natural_order;
    static const unsigned scaling_opt        = hls::ip_fft::scaled;
    static const unsigned rounding_opt       = hls::ip_fft::convergent_rounding;
    static const unsigned arch_opt           = hls::ip_fft::pipelined_streaming_io;
};

typedef hls::ip_fft::config_t<fft512_config> fft512_cfg_t;
typedef hls::ip_fft::status_t<fft512_config> fft512_status_t;

void fft512_fixed(cplx_t xn[512], cplx_t xk[512], int dir, int sch, int *ovflo) {
#pragma HLS interface ap_memory port=xn
#pragma HLS interface ap_memory port=xk
#pragma HLS interface s_axilite port=dir
#pragma HLS interface s_axilite port=sch
#pragma HLS interface s_axilite port=ovflo
#pragma HLS interface ap_ctrl_none port=return

    hls::stream<fft512_cfg_t> cfg;
    hls::stream<fft512_status_t> st;

    fft512_cfg_t c;
    c.setDir(dir != 0);
    c.setSch(sch);
    cfg.write(c);

    hls::fft<fft512_config>(xn, xk, st, cfg);

    fft512_status_t s = st.read();
    *ovflo = s.getOvflo();
}
