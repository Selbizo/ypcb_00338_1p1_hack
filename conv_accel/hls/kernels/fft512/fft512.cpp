// 512-point streaming FFT (Xilinx FFT IP via hls::fft) — feasibility probe.
// C model: floating point; synthesis: Vivado FFT IP, pipelined streaming I/O.
#include "hls_fft.h"
#include <hls_stream.h>
#include <complex>

struct fft512_config : hls::ip_fft::params_t {
    static const unsigned max_nfft           = 9;   // 512
    static const unsigned input_width        = 32;
    static const unsigned output_width       = 32;
    static const unsigned phase_factor_width = 24;
    static const unsigned ordering_opt       = hls::ip_fft::natural_order;
    static const unsigned scaling_opt        = hls::ip_fft::scaled;
    static const unsigned rounding_opt       = hls::ip_fft::convergent_rounding;
    static const unsigned arch_opt           = hls::ip_fft::pipelined_streaming_io;
};

typedef hls::ip_fft::config_t<fft512_config> fft512_config_t;
typedef hls::ip_fft::status_t<fft512_config> fft512_status_t;

void fft512(hls::stream<std::complex<float> > &in,
            hls::stream<std::complex<float> > &out,
            int dir) {
#pragma HLS interface axis port=in
#pragma HLS interface axis port=out
#pragma HLS interface s_axilite port=dir
#pragma HLS interface ap_ctrl_none port=return

    hls::stream<fft512_config_t> cfg;
    hls::stream<fft512_status_t> st;

    fft512_config_t c;
    c.setDir(dir != 0);
    cfg.write(c);

    hls::fft<fft512_config>(in, out, st, cfg);

    if (!st.empty()) {
        fft512_status_t s = st.read();
        (void)s;
    }
}
