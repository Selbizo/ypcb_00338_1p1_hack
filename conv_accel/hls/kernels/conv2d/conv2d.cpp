// conv2d.cpp - 5x5 RGB convolution on the platform kernel slot (M1).
//
// The platform stream is 32 bits/pixel (RGBX) because the AXI DMA in simple
// mode only supports power-of-two stream widths. Internally the pixels are
// XF_8UC3: the X byte is stripped on input and set back to 0xFF on output.
// (xf::cv::filter2D packs its result for 1 or 3 planes only, XF_8UC4 gives 0.)
//
// AXI DMA has no TUSER (SOF) and only asserts TLAST at the end of a transfer,
// so xf::cv::AXIvideo2xfMat/xfMat2AXIvideo cannot be used; the frame is
// delimited by rows*cols from AXI4-Lite.
//
//   video_in  : AXI4-Stream 32 bit (X ignored)
//   video_out : AXI4-Stream 32 bit (X = 0xFF, TLAST on the last pixel)
//   rows, cols: frame geometry (AXI4-Lite)
//   coeff[25] : 5x5 coefficients (AXI4-Lite, 0x40..: two 16-bit values per word)
//   shift     : out = clamp((sum k*p) >> shift)
#include <hls_stream.h>
#include <ap_axi_sdata.h>

#include "common/xf_common.hpp"
#include "common/xf_infra.hpp"
#include "imgproc/xf_custom_convolution.hpp"

#define MAX_H 2160
#define MAX_W 3840
#define KSIZE 5

typedef ap_axiu<32, 1, 1, 1> axis_t;

template <int TYPE, int ROWS, int COLS, int NPC>
static void load_frame(hls::stream<axis_t>& in, xf::cv::Mat<TYPE, ROWS, COLS, NPC>& img) {
#pragma HLS INLINE off
    const int rows = img.rows;
    const int cols = img.cols;
    int idx = 0;
load_rows:
    for (int i = 0; i < rows; ++i) {
    load_cols:
        for (int j = 0; j < cols; ++j) {
#pragma HLS PIPELINE II = 1
            axis_t p = in.read();
            ap_uint<24> rgb = p.data(23, 0);
            img.write(idx++, rgb);
        }
    }
}

template <int TYPE, int ROWS, int COLS, int NPC>
static void store_frame(xf::cv::Mat<TYPE, ROWS, COLS, NPC>& img, hls::stream<axis_t>& out) {
#pragma HLS INLINE off
    const int rows = img.rows;
    const int cols = img.cols;
    const int total = rows * cols;
    int idx = 0;
store_rows:
    for (int i = 0; i < rows; ++i) {
    store_cols:
        for (int j = 0; j < cols; ++j) {
#pragma HLS PIPELINE II = 1
            axis_t p;
            ap_uint<24> rgb = img.read(idx);
            p.data = ((ap_uint<32>)0xFF << 24) | (ap_uint<32>)rgb;
            p.keep = -1;
            p.strb = -1;
            p.user = 0;
            p.id = 0;
            p.dest = 0;
            ++idx;
            p.last = (idx == total) ? 1 : 0;
            out.write(p);
        }
    }
}

void conv2d(hls::stream<axis_t>& video_in,
            hls::stream<axis_t>& video_out,
            int rows,
            int cols,
            int shift,
            short int coeff[KSIZE * KSIZE]) {
#pragma HLS INTERFACE axis      port = video_in
#pragma HLS INTERFACE axis      port = video_out
#pragma HLS INTERFACE s_axilite port = rows
#pragma HLS INTERFACE s_axilite port = cols
#pragma HLS INTERFACE s_axilite port = shift
#pragma HLS INTERFACE s_axilite port = coeff
#pragma HLS INTERFACE s_axilite port = return

#pragma HLS DATAFLOW

    xf::cv::Mat<XF_8UC3, MAX_H, MAX_W, XF_NPPC1> src(rows, cols);
    xf::cv::Mat<XF_8UC3, MAX_H, MAX_W, XF_NPPC1> dst(rows, cols);

    load_frame(video_in, src);
    xf::cv::filter2D<XF_BORDER_REPLICATE, KSIZE, KSIZE, XF_8UC3, XF_8UC3, MAX_H, MAX_W, XF_NPPC1>(
        src, dst, coeff, (unsigned char)shift);
    store_frame(dst, video_out);
}
