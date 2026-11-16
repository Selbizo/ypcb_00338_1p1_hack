#include "hls_fft_rt.h"
#include <ap_fixed.h>
#include <hls_stream.h>
#include <complex>

typedef ap_fixed<16, 1> sample_t;
typedef std::complex<sample_t> cplx_t;

struct fft512_bfp_config : hls::ip_fft::params_t {
    static const unsigned max_nfft           = 9;
    static const unsigned config_width       = 8;
    static const unsigned input_width        = 16;
    static const unsigned output_width       = 16;
    static const unsigned phase_factor_width = 16;
    static const unsigned ordering_opt       = hls::ip_fft::natural_order;
    static const unsigned scaling_opt        = hls::ip_fft::block_floating_point;
    static const unsigned rounding_opt       = hls::ip_fft::convergent_rounding;
    static const unsigned arch_opt           = hls::ip_fft::pipelined_streaming_io;
};
typedef hls::ip_fft::config_t<fft512_bfp_config> cfg_t;
typedef hls::ip_fft::status_t<fft512_bfp_config> st_t;

void fft512_bfp(cplx_t xn[512], cplx_t xk[512], int dir, int *blkexp) {
#pragma HLS interface ap_memory port=xn
#pragma HLS interface ap_memory port=xk
#pragma HLS interface s_axilite port=dir
#pragma HLS interface s_axilite port=blkexp
#pragma HLS interface ap_ctrl_none port=return
    hls::stream<cfg_t> cfg;
    hls::stream<st_t> st;
    cfg_t c; c.setDir(dir != 0);
    cfg.write(c);
    hls::fft<fft512_bfp_config>(xn, xk, st, cfg);
    st_t s = st.read();
    *blkexp = s.getBlkExp();
}
