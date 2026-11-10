// conv2d.cpp - 5x5 RGB convolution on the platform kernel slot.
//
// Vitis Vision xf::cv::filter2D, streaming Mats (line buffers only, no
// full-frame buffer), 24-bit RGB, 1 pixel/clock.
//
// Interface (platform kernel slot):
//   video_in / video_out : AXI4-Stream 24 bit (TUSER = SOF, TLAST = EOL)
//   rows, cols, shift    : AXI4-Lite control
//
// Coefficients are currently compile-time (Gaussian 5x5, sum = 273, shift 8).
// Runtime coefficients will be added as 25 AXI-Lite registers.
#include <hls_stream.h>
#include <ap_axi_sdata.h>

#include "common/xf_common.hpp"
#include "common/xf_infra.hpp"
#include "imgproc/xf_custom_convolution.hpp"

#define MAX_H 2160
#define MAX_W 3840

typedef ap_axiu<24, 1, 1, 1> axis_t;  // 24-bit RGB + TUSER/TID/TDEST

void conv2d(hls::stream<axis_t>& video_in,
            hls::stream<axis_t>& video_out,
            int rows,
            int cols,
            int shift) {
#pragma HLS INTERFACE axis      port = video_in
#pragma HLS INTERFACE axis      port = video_out
#pragma HLS INTERFACE s_axilite port = rows
#pragma HLS INTERFACE s_axilite port = cols
#pragma HLS INTERFACE s_axilite port = shift
#pragma HLS INTERFACE s_axilite port = return

#pragma HLS DATAFLOW

    xf::cv::Mat<XF_8UC3, MAX_H, MAX_W, XF_NPPC1> src(rows, cols);
    xf::cv::Mat<XF_8UC3, MAX_H, MAX_W, XF_NPPC1> dst(rows, cols);

    // 5x5 Gaussian (sum 273), normalized by >> shift
    short int k[25] = {1, 4, 7, 4, 1, 4, 16, 26, 16, 4, 7, 26, 41, 26, 7, 4, 16, 26, 16, 4, 1, 4, 7, 4, 1};

    xf::cv::AXIvideo2xfMat<24, XF_8UC3, MAX_H, MAX_W, XF_NPPC1>(video_in, src);
    xf::cv::filter2D<XF_BORDER_REPLICATE, 5, 5, XF_8UC3, XF_8UC3, MAX_H, MAX_W, XF_NPPC1>(src, dst, k,
                                                                                          (unsigned char)shift);
    xf::cv::xfMat2AXIvideo<24, XF_8UC3, MAX_H, MAX_W, XF_NPPC1>(dst, video_out);
}
