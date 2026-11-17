// 256x256 Y-plane Wiener block with 8 forward + 8 inverse external xfft IPs.
// The FFT IPs are driven over AXI-Stream (1 sample/clock, continuous).
// Frame I/O is a 32-bit AXI-Stream (Y in the low byte); the host merges colour.
#include <ap_fixed.h>
#include <ap_axi_sdata.h>
#include <hls_stream.h>
#include <complex>
#include <math.h>
#include "g_lut.h"

#ifndef N
#define N 256
#endif
#define IN_W 24
#define OUT_W (IN_W + 8 + 1)          // 256-point unscaled: 33 bits
#define WIDE_W (((OUT_W + 7) / 8) * 8) // 40
#define WIDE_I (WIDE_W - IN_W + 1)     // 17

typedef ap_fixed<IN_W, 1> sample_t;
typedef std::complex<sample_t> cplx_t;
typedef ap_fixed<WIDE_W, WIDE_I> wide_t;
typedef std::complex<wide_t> cplx_w_t;

typedef ap_axis<48, 0, 0, 0> axis_in_t;   // 24-bit I + 24-bit Q
typedef ap_axis<80, 0, 0, 0> axis_out_t;  // 40-bit I + 40-bit Q
typedef ap_axis<32, 0, 0, 0> axis_frame_t;

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

#define LUT_A 96.0f
#define LUT_M 8192
static cplx_t gbin_lut(int kx, int ky, float L, float ct, float st) {
    int sx = (kx < N/2) ? kx : kx - N;
    int sy = (ky < N/2) ? ky : ky - N;
    float a = (L/(float)N) * (sx*ct + sy*st);
    float x = (a + LUT_A) * (LUT_M/(2.0f*LUT_A)) - 0.5f;
    int i0 = (int)x;
    if (i0 < 0) i0 = 0;
    if (i0 >= LUT_M - 1) i0 = LUT_M - 2;
    float f = x - (float)i0;
    if (f < 0.0f) f = 0.0f;
    if (f > 1.0f) f = 1.0f;
    float re = (1.0f-f)*g_lut_re[i0] + f*g_lut_re[i0+1];
    float im = (1.0f-f)*g_lut_im[i0] + f*g_lut_im[i0+1];
    return cplx_t(sample_t(re/32768.0f), sample_t(im/32768.0f));
}

// ---------------- forward row pass: A -> fwd FFTs -> B (transposed) ----------------
static void send_rows(cplx_t A[N/8][N/8][8][8], hls::stream<axis_in_t> out[8]) {
    for (int r0 = 0; r0 < N; r0 += 8)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                cplx_t v = A[(r0+p)/8][c/8][(r0+p)%8][c%8];
                axis_in_t x;
                x.data = pack(v.real(), v.imag());
                x.last = (c == N-1);
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
                cplx_w_t w = unpack(y.data);
                B[c/8][(r0+p)/8][c%8][(r0+p)%8] = narrow(w, 8);
            }
        }
}

static void row_pass(cplx_t A[N/8][N/8][8][8], cplx_t B[N/8][N/8][8][8],
                     hls::stream<axis_in_t> fin[8], hls::stream<axis_out_t> fout[8]) {
#pragma HLS dataflow
    send_rows(A, fin);
    recv_rows(fout, B);
}

// ---------------- column pass: B -> fwd -> G -> inv -> A ----------------
static void send_cols(cplx_t B[N/8][N/8][8][8], hls::stream<axis_in_t> out[8]) {
    for (int c0 = 0; c0 < N; c0 += 8)
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                cplx_t v = B[(c0+p)/8][r/8][(c0+p)%8][r%8];
                axis_in_t x;
                x.data = pack(v.real(), v.imag());
                x.last = (r == N-1);
                out[p].write(x);
            }
        }
}

static void recv_cols_g(hls::stream<axis_out_t> in[8], hls::stream<axis_in_t> out[8],
                        float L, float ct, float st) {
    for (int c0 = 0; c0 < N; c0 += 8)
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < 8; ++p) {
#pragma HLS unroll
                axis_out_t y = in[p].read();
                cplx_t v = narrow(unpack(y.data), 8);
                cplx_t z = cmul(v, gbin_lut(c0+p, r, L, ct, st));
                axis_in_t x;
                x.data = pack(z.real(), z.imag());
                x.last = (r == N-1);
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
                     float L, float ct, float st) {
#pragma HLS dataflow
    send_cols(B, fin);
    recv_cols_g(fout, iin, L, ct, st);
    recv_cols(iout, A);
}

// ---------------- inverse row pass: A -> inv FFTs -> frame out ----------------
static void inv_rows(cplx_t A[N/8][N/8][8][8],
                     hls::stream<axis_in_t> fin[8], hls::stream<axis_out_t> fout[8],
                     hls::stream<axis_frame_t> &dout) {
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
        for (int p = 0; p < 8; ++p) {
            for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
                float rv = rowbuf[p][c].real().to_float();
                int v = (int)(rv * 1280.0f) + 128;
                if (v < 0) v = 0;
                if (v > 255) v = 255;
                axis_frame_t o;
                o.data = (ap_uint<32>)v;
                o.last = (c == N-1) && (p == 7) && (r0 == N-8);
                dout.write(o);
            }
        }
    }
}

void wiener_stream(hls::stream<axis_in_t> fwd_in[8], hls::stream<axis_out_t> fwd_out[8],
                   hls::stream<axis_in_t> inv_in[8], hls::stream<axis_out_t> inv_out[8],
                   hls::stream<axis_frame_t> &din, hls::stream<axis_frame_t> &dout,
                   int Lq, int ctq, int stq) {
#pragma HLS interface axis port=fwd_in
#pragma HLS interface axis port=fwd_out
#pragma HLS interface axis port=inv_in
#pragma HLS interface axis port=inv_out
#pragma HLS interface axis port=din
#pragma HLS interface axis port=dout
#pragma HLS interface s_axilite port=Lq
#pragma HLS interface s_axilite port=ctq
#pragma HLS interface s_axilite port=stq
#pragma HLS interface s_axilite port=return

    static cplx_t A[N/8][N/8][8][8];
    static cplx_t B[N/8][N/8][8][8];
#pragma HLS array_partition variable=A complete dim=3
#pragma HLS array_partition variable=A complete dim=4
#pragma HLS array_partition variable=B complete dim=3
#pragma HLS array_partition variable=B complete dim=4

    for (int r = 0; r < N; ++r)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            axis_frame_t x = din.read();
            int y = (int)x.data.range(7, 0);
            A[r/8][c/8][r%8][c%8] = cplx_t(sample_t(y - 128) / 256, sample_t(0));
        }

    float L  = (float)Lq;
    float ct = (float)ctq / 32768.0f;
    float st = (float)stq / 32768.0f;

    row_pass(A, B, fwd_in, fwd_out);
    col_pass(B, A, fwd_in, fwd_out, inv_in, inv_out, L, ct, st);
    inv_rows(A, inv_in, inv_out, dout);
}
