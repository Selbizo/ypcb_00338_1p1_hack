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
    // Conjugate the imaginary part: cv::dft (CPU reference) and xfft use
    // opposite DFT sign conventions, so the raw LUT phase would shift the
    // deblurred image by the motion vector.
    int im = -((32768-fi)*g_lut_im[i0] + fi*g_lut_im[i0+1]);
    ap_int<16> reb = re >> 15;
    ap_int<16> imb = im >> 15;
    sample_t sr, si;
    sr.range(23,8) = reb.to_uint(); sr.range(7,0) = 0;
    si.range(23,8) = imb.to_uint(); si.range(7,0) = 0;
    return cplx_t(sr, si);
}

// ---------------- 8-core streaming passes (sequential, no HLS dataflow) ----------------
// The external xfft cores run continuously; the kernel keeps a few frames in
// flight and interleaves sends with receives.  Frame k is one transform of
// 256 samples per lane (8 lanes).  A small inter-frame distance decouples the
// FFT pipeline latency from the loop and, unlike an HLS dataflow region, cannot
// deadlock on process start-up.
#define FWD_D 1
#define INV_D 3

// forward rows -> B (transposed), /256
static void row_pass(cplx_t A[N/8][N/8][8][8], cplx_t B[N/8][N/8][8][8],
                     hls::stream<axis_in_t> fin[8], hls::stream<axis_out_t> fout[8]) {
    for (int k = 0; k < N/8 + FWD_D; ++k) {
        if (k < N/8) {
            for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
                for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                    cplx_t v = A[k][c/8][p][c%8];
                    axis_in_t x; x.data = pack(v.real(), v.imag());
                    x.last = (c == N-1);
                    fin[p].write(x);
                }
            }
        }
        if (k >= FWD_D) {
            int kk = k - FWD_D;
            for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
                for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                    axis_out_t y = fout[p].read();
                    B[c/8][kk][c%8][p] = narrow(unpack(y.data), 8);
                }
            }
        }
    }
}

// columns: forward FFT -> G -> inverse FFT, two stages kept in flight
static void col_pass(cplx_t B[N/8][N/8][8][8], cplx_t A[N/8][N/8][8][8],
                     hls::stream<axis_in_t> fin[8], hls::stream<axis_out_t> fout[8],
                     hls::stream<axis_in_t> iin[8], hls::stream<axis_out_t> iout[8],
                     q15_t Ln, q15_t ct, q15_t st) {
    for (int k = 0; k < N/8 + FWD_D + INV_D; ++k) {
        if (k < N/8) {
            int c0 = 8 * k;
            for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
                for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                    cplx_t v = B[k][r/8][p][r%8];
                    axis_in_t x; x.data = pack(v.real(), v.imag());
                    x.last = (r == N-1);
                    fin[p].write(x);
                }
            }
        }
        if (k >= FWD_D && k - FWD_D < N/8) {
            int kk = k - FWD_D;
            int c0 = 8 * kk;
            for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
                for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                    axis_out_t y = fout[p].read();
                    cplx_t v = narrow(unpack(y.data), 8);
                    cplx_t z = cmul(v, gbin_lut(c0+p, r, Ln, ct, st));
                    axis_in_t x; x.data = pack(z.real(), z.imag());
                    x.last = (r == N-1);
                    iin[p].write(x);
                }
            }
        }
        if (k >= FWD_D + INV_D && k - FWD_D - INV_D < N/8) {
            int kk = k - FWD_D - INV_D;
            for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
                for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                    axis_out_t y = iout[p].read();
                    A[r/8][kk][r%8][p] = narrow(unpack(y.data), 4);
                }
            }
        }
    }
}

// ---------------- inverse rows -> valid 128x128 tile into the strip ----------------
static void inv_rows(cplx_t A[N/8][N/8][8][8],
                     hls::stream<axis_in_t> fin[8], hls::stream<axis_out_t> fout[8],
                     ap_uint<8> outst[128][W_MAX],
                     int ox, int oy, int vx, int width, int scale) {
    (void)width;
    for (int k = 0; k < N/8 + INV_D; ++k) {
        if (k < N/8) {
            for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
                for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                    cplx_t v = A[k][c/8][p][c%8];
                    axis_in_t x; x.data = pack(v.real(), v.imag());
                    x.last = (c == N-1);
                    fin[p].write(x);
                }
            }
        }
        if (k >= INV_D) {
            int kk = k - INV_D;
            cplx_t rowbuf[8][N];
#pragma HLS array_partition variable=rowbuf complete dim=1
            for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
                for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                    axis_out_t y = fout[p].read();
                    cplx_w_t u = unpack(y.data);
                    rowbuf[p][c] = cplx_t(sample_t(u.real() >> 4),
                                          sample_t(u.imag() >> 4));
                }
            }
            for (int c = ox; c < ox + 128; ++c) {
#pragma HLS pipeline II=1
                for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                    int r = 8*kk + p;
                    if (r >= oy && r < oy + 128) {
                        int v = (int)(rowbuf[p][c].real() * scale) + 128;
                        if (v < 0) v = 0;
                        if (v > 255) v = 255;
                        outst[r-oy][vx + c - ox] = (ap_uint<8>)v;
                    }
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
                   ap_int<32> params[3][256],
                   int out_scale,
                   int dbg[16]) {
#pragma HLS interface axis port=fwd_in
#pragma HLS interface axis port=fwd_out
#pragma HLS interface axis port=inv_in
#pragma HLS interface axis port=inv_out
#pragma HLS interface axis port=din
#pragma HLS interface axis port=dout
#pragma HLS interface s_axilite port=width
#pragma HLS interface s_axilite port=height
#pragma HLS interface s_axilite port=params
#pragma HLS interface s_axilite port=out_scale
#pragma HLS interface s_axilite port=dbg
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

        dbg[0] = 20 + vy / 128;   // entered block row
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

            dbg[1] = 30;
            // load block from the strip (8 rows / cycle)
            for (int r0 = 0; r0 < N; r0 += 8)
                for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
                    for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                        int rr = (by + r0 + p) % 256;
                        int yv = (int)strip[rr][bx + c];
                        ap_fixed<16, 8> d = yv - 128;
                        A[(r0+p)/8][c/8][(r0+p)%8][c%8] =
                            cplx_t(sample_t(d >> 8), sample_t(0));
                    }
                }

            dbg[2] = 40;
            q15_t Lnq, ctq, stq;
            Lnq.range(15, 0) = params[0][idx].range(15, 0);
            ctq.range(15, 0) = params[1][idx].range(15, 0);
            stq.range(15, 0) = params[2][idx].range(15, 0);
            idx++;

            dbg[3] = 50;
            row_pass(A, B, fwd_in, fwd_out);
            dbg[4] = 60;
            col_pass(B, A, fwd_in, fwd_out, inv_in, inv_out, Lnq, ctq, stq);
            dbg[5] = 70;
            inv_rows(A, inv_in, inv_out, outst, ox, oy, vx, width, out_scale);
            dbg[6] = 80;
        }

        dbg[7] = 90;
        // emit the valid rows of this block row
        for (int j = 0; j < 128; ++j)
            for (int c = 0; c < width; ++c) {
#pragma HLS pipeline II=1
                axis_frame_t o;
                o.data = (ap_uint<32>)outst[j][c];
                o.keep = -1;
                o.strb = -1;
                o.last = (c == width-1) && (j == 127) && (vy == last_vy);
                dout.write(o);
            }
        dbg[8] = 91;
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
                        ap_fixed<16, 8> d = yv - 128;
                        A[(r0+p)/8][c/8][(r0+p)%8][c%8] =
                            cplx_t(sample_t(d >> 8), sample_t(0));
                    }
                }
            q15_t Lnq, ctq, stq;
            Lnq.range(15, 0) = params[0][idx].range(15, 0);
            ctq.range(15, 0) = params[1][idx].range(15, 0);
            stq.range(15, 0) = params[2][idx].range(15, 0);
            idx++;
            row_pass(A, B, fwd_in, fwd_out);
            col_pass(B, A, fwd_in, fwd_out, inv_in, inv_out, Lnq, ctq, stq);
            inv_rows(A, inv_in, inv_out, outst, ox, oy, vx, width, out_scale);
        }
        // the main loop already emitted rows [0, covered); emit only the
        // remaining bottom rows from this tail pass
        int main_last = (last_vy / 128) * 128;
        int covered = main_last + 128;
        int j0 = covered - last_vy;
        if (j0 < 0) j0 = 0;
        if (j0 > 128) j0 = 128;
        for (int j = j0; j < 128; ++j)
            for (int c = 0; c < width; ++c) {
#pragma HLS pipeline II=1
                axis_frame_t o;
                o.data = (ap_uint<32>)outst[j][c];
                o.keep = -1;
                o.strb = -1;
                o.last = (c == width-1) && (j == 127);
                dout.write(o);
            }
    }
    dbg[9] = 99;
}
