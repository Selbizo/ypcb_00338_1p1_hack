// Y-plane Wiener deconvolution over a full frame using 8 forward + 8 inverse
// external xfft IPs (AXI-Stream, 1 sample/clock).  Luma only: the host sends
// Y and merges the result back with the original chroma.
//
// Frame: width x height, block 256, hop 128 (50% overlap, valid = central 128).
// A 256-row strip buffer holds the current block rows; the frame is read once.
#include <ap_fixed.h>
#include <ap_axi_sdata.h>
#include <hls_stream.h>
#include <complex>
#include <hls_math.h>
#include "g_lut.h"

#ifndef N
#define N 256
#endif
#define W_MAX 1920
#define IN_W 24
#define OUT_W (IN_W + 8 + 1)
#define WIDE_W (((OUT_W + 7) / 8) * 8)
#define WIDE_I (WIDE_W - IN_W + 1)

typedef ap_fixed<IN_W, 1> sample_t;
typedef std::complex<sample_t> cplx_t;
typedef ap_fixed<WIDE_W, WIDE_I> wide_t;
typedef std::complex<wide_t> cplx_w_t;
typedef ap_fixed<16, 1> q15_t;

typedef ap_axis<48, 0, 0, 0> axis_in_t;
typedef ap_axis<80, 0, 0, 0> axis_out_t;
typedef ap_axis<32, 0, 0, 0> axis_frame_t;

// ---------------- bit packing / fixed point ----------------
static ap_uint<48> pack(sample_t re, sample_t im) {
    ap_uint<48> d;
    d.range(23, 0)  = re.range(23, 0).to_uint64();
    d.range(47, 24) = im.range(23, 0).to_uint64();
    return d;
}
static cplx_w_t unpack(ap_uint<80> d) {
    wide_t re, im;
    re.range(39, 0) = d.range(39, 0).to_uint64();
    im.range(39, 0) = d.range(79, 40).to_uint64();
    return cplx_w_t(re, im);
}
static cplx_t narrow(cplx_w_t v, int s) {
    return cplx_t(sample_t(v.real() >> s), sample_t(v.imag() >> s));
}
static cplx_t cmul(cplx_t a, cplx_t b) {
    return cplx_t(a.real()*b.real() - a.imag()*b.imag(),
                  a.real()*b.imag() + a.imag()*b.real());
}

// ---------------- analytic Wiener filter LUT ----------------
#define LUT_A 96.0f
#define LUT_M 8192
static cplx_t gbin_lut(int kx, int ky, q15_t Ln, q15_t ct, q15_t st) {
    int sx = (kx < N/2) ? kx : kx - N;
    int sy = (ky < N/2) ? ky : ky - N;
    ap_fixed<24,12> sum = (ap_fixed<24,12>)(sx*ct + sy*st);
    ap_fixed<24,12> a = Ln * sum;
    ap_fixed<32,20> x = (a + (ap_fixed<24,12>)96) * (ap_fixed<32,20>)42.6667f
                      - (ap_fixed<32,20>)0.5f;
    int i0 = x.to_int();
    if (i0 < 0) i0 = 0;
    if (i0 >= LUT_M-1) i0 = LUT_M-2;
    ap_fixed<32,20> fr = x - (ap_fixed<32,20>)i0;
    int fi = (int)(fr * 32768);
    int re = (32768-fi)*g_lut_re[i0] + fi*g_lut_re[i0+1];
    int im = (32768-fi)*g_lut_im[i0] + fi*g_lut_im[i0+1];
    ap_int<16> reb = re >> 15;
    ap_int<16> imb = im >> 15;
    sample_t sr, si;
    sr.range(23,8) = reb.to_uint(); sr.range(7,0) = 0;
    si.range(23,8) = imb.to_uint(); si.range(7,0) = 0;
    return cplx_t(sr, si);
}

// ---------------- 8-core streaming passes ----------------
static void send_rows(cplx_t A[N/8][N/8][8][8], hls::stream<axis_in_t> out[8]) {
    for (int r0 = 0; r0 < N; r0 += 8)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                cplx_t v = A[(r0+p)/8][c/8][(r0+p)%8][c%8];
                axis_in_t x; x.data = pack(v.real(), v.imag()); x.last = (c == N-1);
                out[p].write(x);
            }
        }
}
static void recv_rows(hls::stream<axis_out_t> in[8], cplx_t B[N/8][N/8][8][8]) {
    for (int r0 = 0; r0 < N; r0 += 8)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                axis_out_t y = in[p].read();
                B[c/8][(r0+p)/8][c%8][(r0+p)%8] = narrow(unpack(y.data), 8);
            }
        }
}
static void row_pass(cplx_t A[N/8][N/8][8][8], cplx_t B[N/8][N/8][8][8],
                     hls::stream<axis_in_t> fin[8], hls::stream<axis_out_t> fout[8]) {
#pragma HLS dataflow
    send_rows(A, fin);
    recv_rows(fout, B);
}
static void send_cols(cplx_t B[N/8][N/8][8][8], hls::stream<axis_in_t> out[8]) {
    for (int c0 = 0; c0 < N; c0 += 8)
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                cplx_t v = B[(c0+p)/8][r/8][(c0+p)%8][r%8];
                axis_in_t x; x.data = pack(v.real(), v.imag()); x.last = (r == N-1);
                out[p].write(x);
            }
        }
}
static void recv_cols_g(hls::stream<axis_out_t> in[8], hls::stream<axis_in_t> out[8],
                        q15_t Ln, q15_t ct, q15_t st) {
    for (int c0 = 0; c0 < N; c0 += 8)
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                axis_out_t y = in[p].read();
                cplx_t v = narrow(unpack(y.data), 8);
                cplx_t z = cmul(v, gbin_lut(c0+p, r, Ln, ct, st));
                axis_in_t x; x.data = pack(z.real(), z.imag()); x.last = (r == N-1);
                out[p].write(x);
            }
        }
}
static void recv_cols(hls::stream<axis_out_t> in[8], cplx_t A[N/8][N/8][8][8]) {
    for (int c0 = 0; c0 < N; c0 += 8)
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                axis_out_t y = in[p].read();
                A[r/8][(c0+p)/8][r%8][(c0+p)%8] = narrow(unpack(y.data), 4);
            }
        }
}
static void col_pass(cplx_t B[N/8][N/8][8][8], cplx_t A[N/8][N/8][8][8],
                     hls::stream<axis_in_t> fin[8], hls::stream<axis_out_t> fout[8],
                     hls::stream<axis_in_t> iin[8], hls::stream<axis_out_t> iout[8],
                     q15_t Ln, q15_t ct, q15_t st) {
#pragma HLS dataflow
    send_cols(B, fin);
    recv_cols_g(fout, iin, Ln, ct, st);
    recv_cols(iout, A);
}

// ---------------- inverse rows -> valid 128x128 tile into the strip ----------------
static void inv_rows(cplx_t A[N/8][N/8][8][8],
                     hls::stream<axis_in_t> fin[8], hls::stream<axis_out_t> fout[8],
                     ap_uint<8> outst[128][W_MAX],
                     int ox, int oy, int vx, int width) {
    send_rows(A, fin);
    for (int r0 = 0; r0 < N; r0 += 8) {
        cplx_t rowbuf[8][N];
#pragma HLS array_partition variable=rowbuf complete dim=1
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                axis_out_t y = fout[p].read();
                rowbuf[p][c] = cplx_t(sample_t(unpack(y.data).real() >> 4),
                                      sample_t(unpack(y.data).imag() >> 4));
            }
        }
        for (int c = ox; c < ox + 128; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                int r = r0 + p;
                if (r >= oy && r < oy + 128) {
                    int v = (int)(rowbuf[p][c].real() * 1280) + 128;
                    if (v < 0) v = 0;
                    if (v > 255) v = 255;
                    outst[r-oy][vx + c - ox] = (ap_uint<8>)v;
                }
            }
        }
    }
}

// ---------------- top ----------------
void wiener_stream(hls::stream<axis_in_t> fwd_in[8], hls::stream<axis_out_t> fwd_out[8],
                   hls::stream<axis_in_t> inv_in[8], hls::stream<axis_out_t> inv_out[8],
                   hls::stream<axis_frame_t> &din, hls::stream<axis_frame_t> &dout,
                   int width, int height,
                   float params[3][256]) {
#pragma HLS interface axis port=fwd_in
#pragma HLS interface axis port=fwd_out
#pragma HLS interface axis port=inv_in
#pragma HLS interface axis port=inv_out
#pragma HLS interface axis port=din
#pragma HLS interface axis port=dout
#pragma HLS interface s_axilite port=width
#pragma HLS interface s_axilite port=height
#pragma HLS interface s_axilite port=params
#pragma HLS interface s_axilite port=return

    static cplx_t A[N/8][N/8][8][8];
    static cplx_t B[N/8][N/8][8][8];
    static ap_uint<8> strip[256][W_MAX];
    static ap_uint<8> outst[128][W_MAX];
#pragma HLS array_partition variable=A complete dim=3
#pragma HLS array_partition variable=A complete dim=4
#pragma HLS array_partition variable=B complete dim=3
#pragma HLS array_partition variable=B complete dim=4
#pragma HLS array_partition variable=strip cyclic factor=8 dim=1
#pragma HLS array_partition variable=outst cyclic factor=8 dim=1

    int read_row = 0;
    int idx = 0;
    int last_vy = height - 128;
    bool done_last = ((last_vy % 128) == 0);

    for (int vy = 0; vy <= last_vy; vy += 128) {
        int by = vy - 64;
        if (by < 0) by = 0;
        if (by > height - N) by = height - N;
        int oy = vy - by;

        // fill the strip up to by+255
        while (read_row <= by + N - 1) {
            for (int c = 0; c < width; ++c) {
#pragma HLS pipeline II=1
                axis_frame_t x = din.read();
                strip[read_row % 256][c] = x.data.range(7, 0);
            }
            read_row++;
        }

        for (int vx = 0; vx <= width - 128; vx += 128) {
            int bx = vx - 64;
            if (bx < 0) bx = 0;
            if (bx > width - N) bx = width - N;
            int ox = vx - bx;

            // load block from the strip (8 rows / cycle)
            for (int r0 = 0; r0 < N; r0 += 8)
                for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
                    for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                        int rr = (by + r0 + p) % 256;
                        int yv = (int)strip[rr][bx + c];
                        A[(r0+p)/8][c/8][(r0+p)%8][c%8] =
                            cplx_t(sample_t(yv - 128) / 256, sample_t(0));
                    }
                }

            q15_t Lnq = params[0][idx];
            q15_t ctq = params[1][idx];
            q15_t stq = params[2][idx];
            idx++;

            row_pass(A, B, fwd_in, fwd_out);
            col_pass(B, A, fwd_in, fwd_out, inv_in, inv_out, Lnq, ctq, stq);
            inv_rows(A, inv_in, inv_out, outst, ox, oy, vx, width);
        }

        // emit the 128 valid rows
        for (int j = 0; j < 128; ++j)
            for (int c = 0; c < width; ++c) {
#pragma HLS pipeline II=1
                axis_frame_t o;
                o.data = (ap_uint<32>)outst[j][c];
                o.last = (c == width-1) && (j == 127) && (vy == last_vy);
                dout.write(o);
            }
    }

    if (!done_last) {
        int vy = last_vy;
        int by = vy - 64;
        if (by < 0) by = 0;
        if (by > height - N) by = height - N;
        int oy = vy - by;
        while (read_row <= by + N - 1) {
            for (int c = 0; c < width; ++c) {
#pragma HLS pipeline II=1
                axis_frame_t x = din.read();
                strip[read_row % 256][c] = x.data.range(7, 0);
            }
            read_row++;
        }
        for (int vx = 0; vx <= width - 128; vx += 128) {
            int bx = vx - 64;
            if (bx < 0) bx = 0;
            if (bx > width - N) bx = width - N;
            int ox = vx - bx;
            for (int r0 = 0; r0 < N; r0 += 8)
                for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
                    for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                        int rr = (by + r0 + p) % 256;
                        int yv = (int)strip[rr][bx + c];
                        A[(r0+p)/8][c/8][(r0+p)%8][c%8] =
                            cplx_t(sample_t(yv - 128) / 256, sample_t(0));
                    }
                }
            q15_t Lnq = params[0][idx];
            q15_t ctq = params[1][idx];
            q15_t stq = params[2][idx];
            idx++;
            row_pass(A, B, fwd_in, fwd_out);
            col_pass(B, A, fwd_in, fwd_out, inv_in, inv_out, Lnq, ctq, stq);
            inv_rows(A, inv_in, inv_out, outst, ox, oy, vx, width);
        }
        for (int j = 0; j < 128; ++j)
            for (int c = 0; c < width; ++c) {
#pragma HLS pipeline II=1
                axis_frame_t o;
                o.data = (ap_uint<32>)outst[j][c];
                o.last = (c == width-1) && (j == 127);
                dout.write(o);
            }
    }
}
