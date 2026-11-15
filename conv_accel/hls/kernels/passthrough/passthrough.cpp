// passthrough.cpp - platform bring-up kernel (M0/M1 wiring check).
//
// Free-running AXI4-Stream video passthrough, 32-bit RGBX (1 pixel/beat).
//   video_in  : AXI4-Stream 32 bit
//   video_out : AXI4-Stream 32 bit
// No AXI4-Lite: the frame is delimited by the producer's TLAST, which is
// simply forwarded.
#include <hls_stream.h>
#include <ap_axi_sdata.h>

typedef ap_axiu<32, 1, 1, 1> axis_t;  // 32-bit RGBX pixel + TUSER/TLAST

void passthrough(hls::stream<axis_t>& video_in, hls::stream<axis_t>& video_out) {
#pragma HLS INTERFACE axis port = video_in
#pragma HLS INTERFACE axis port = video_out
#pragma HLS INTERFACE ap_ctrl_none port = return

    axis_t p;
    do {
#pragma HLS PIPELINE II = 1
        p = video_in.read();
        video_out.write(p);
    } while (1);
}
