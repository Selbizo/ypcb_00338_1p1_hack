// passthrough.cpp - platform bring-up kernel.
//
// Free-running AXI4-Stream video passthrough, 24-bit RGB (1 pixel/beat).
// Used to validate the HLS -> IP -> BD -> VDMA -> host path before any real
// processing. Interface matches the platform "kernel slot":
//   video_in  : AXI4-Stream 24 bit (TUSER = SOF, TLAST = EOL)
//   video_out : AXI4-Stream 24 bit
#include <hls_stream.h>
#include <ap_axi_sdata.h>

typedef ap_axiu<24, 1, 1, 1> axis_t;  // 24-bit RGB pixel + TUSER/TID/TDEST

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
