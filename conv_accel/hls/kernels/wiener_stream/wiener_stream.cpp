// Y-plane Wiener deconvolution over a full frame.
// 256x256 blocks, hop 128, per-block analytic sinc OTF, 8 parallel streaming
// hls::fft cores (the interface that synthesises cleanly), Y only.
#include <ap_fixed.h>
#include <ap_axi_sdata.h>
#include <hls_stream.h>
#include <complex>
#include <hls_math.h>
#include "hls_fft_rt.h"
#include "g_lut.h"

#ifndef N
#define N 256
#endif
#ifndef LOGN
#define LOGN 8
#endif
#define PAR 8
#define FRAMES (N / PAR)
#define W_MAX 1920
#define IN_W 24
#define OUT_W (IN_W + LOGN + 1)
#define WIDE_W (((OUT_W + 7) / 8) * 8)
#define WIDE_I (WIDE_W - IN_W + 1)

typedef ap_fixed<IN_W, 1> sample_t;
typedef std::complex<sample_t> cplx_t;
typedef ap_fixed<WIDE_W, WIDE_I> wide_t;
typedef std::complex<wide_t> cplx_w_t;
typedef ap_fixed<16, 1> q15_t;

typedef ap_axis<32, 0, 0, 0> axis_frame_t;

// ---------------- FFT config (unscaled, realtime, 8 parallel cores) --------
struct fft_cfg : hls::ip_fft::params_t {
    static const unsigned max_nfft           = LOGN;
    static const unsigned config_width       = 8;
    static const unsigned input_width        = IN_W;
    static const unsigned output_width       = OUT_W;
    static const unsigned phase_factor_width = 16;
    static const unsigned ordering_opt       = hls::ip_fft::natural_order;
    static const unsigned scaling_opt        = hls::ip_fft::unscaled;
    static const unsigned rounding_opt       = hls::ip_fft::convergent_rounding;
    static const unsigned arch_opt           = hls::ip_fft::pipelined_streaming_io;
};
typedef hls::ip_fft::config_t<fft_cfg> cfg_t;
typedef hls::ip_fft::status_t<fft_cfg> st_t;

static void fft_core(hls::stream<cplx_t> &in, hls::stream<cplx_w_t> &out,
                     int n, int dir) {
#pragma HLS inline off
    for (int i = 0; i < n; ++i) {
        hls::stream<cfg_t> cfg;
        hls::stream<st_t> st;
        cfg_t c;
        c.setDir(dir != 0);
        cfg.write(c);
        hls::fft<fft_cfg>(in, out, st, cfg);
        // no st.read(): unscaled / ovflo=false core emits no status word
    }
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

// ---------------- streaming helpers ----------------
static void load_rows(cplx_t A[N/8][N/8][8][8], hls::stream<cplx_t> in[PAR]) {
    for (int r0 = 0; r0 < N; r0 += PAR)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                in[p].write(A[(r0+p)/8][c/8][(r0+p)%8][c%8]);
            }
        }
}

static void store_rows(hls::stream<cplx_w_t> out[PAR], cplx_t B[N/8][N/8][8][8]) {
    for (int r0 = 0; r0 < N; r0 += PAR)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                B[c/8][(r0+p)/8][c%8][(r0+p)%8] = narrow(out[p].read(), 8);
            }
        }
}

static void load_cols(cplx_t B[N/8][N/8][8][8], hls::stream<cplx_t> in[PAR]) {
    for (int c0 = 0; c0 < N; c0 += PAR)
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                in[p].write(B[(c0+p)/8][r/8][(c0+p)%8][r%8]);
            }
        }
}

static void apply_g(hls::stream<cplx_w_t> in[PAR], hls::stream<cplx_t> out[PAR],
                    q15_t Ln, q15_t ct, q15_t st) {
    for (int c0 = 0; c0 < N; c0 += PAR)
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                cplx_t v = narrow(in[p].read(), 8);
                out[p].write(cmul(v, gbin_lut(c0+p, r, Ln, ct, st)));
            }
        }
}

static void store_cols(hls::stream<cplx_w_t> out[PAR], cplx_t A[N/8][N/8][8][8]) {
    for (int c0 = 0; c0 < N; c0 += PAR)
        for (int r = 0; r < N; ++r) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                A[r/8][(c0+p)/8][r%8][(c0+p)%8] = narrow(out[p].read(), 4);
            }
        }
}

static void load_rows2(cplx_t A[N/8][N/8][8][8], hls::stream<cplx_t> in[PAR]) {
    load_rows(A, in);
}

static void store_tile(hls::stream<cplx_w_t> out[PAR], ap_uint<8> outst[128][W_MAX],
                       int ox, int oy, int vx) {
    for (int r0 = 0; r0 < N; r0 += PAR)
        for (int c = 0; c < N; ++c) {
#pragma HLS pipeline II=1
            for (int p = 0; p < PAR; ++p) {
#pragma HLS unroll
                int r = r0 + p;
                sample_t val = narrow(out[p].read(), 4).real();
                if (r >= oy && r < oy + 128 && c >= ox && c < ox + 128) {
                    int v = (int)(val * 1280) + 128;
                    if (v < 0) v = 0;
                    if (v > 255) v = 255;
                    outst[r - oy][vx + c - ox] = (ap_uint<8>)v;
                }
            }
        }
}

// ---------------- one 256x256 block 2D Wiener ----------------
static void block_wiener(cplx_t A[N/8][N/8][8][8], cplx_t B[N/8][N/8][8][8],
                         q15_t Ln, q15_t ct, q15_t st,
                         ap_uint<8> outst[128][W_MAX],
                         int ox, int oy, int vx) {
    {
#pragma HLS dataflow
        hls::stream<cplx_t>   fin[PAR];
        hls::stream<cplx_w_t> fout[PAR];
        load_rows(A, fin);
        fft_core(fin[0], fout[0], FRAMES, 1);
        fft_core(fin[1], fout[1], FRAMES, 1);
        fft_core(fin[2], fout[2], FRAMES, 1);
        fft_core(fin[3], fout[3], FRAMES, 1);
        fft_core(fin[4], fout[4], FRAMES, 1);
        fft_core(fin[5], fout[5], FRAMES, 1);
        fft_core(fin[6], fout[6], FRAMES, 1);
        fft_core(fin[7], fout[7], FRAMES, 1);
        store_rows(fout, B);
    }
    {
#pragma HLS dataflow
        hls::stream<cplx_t>   cin[PAR];
        hls::stream<cplx_w_t> cout_f[PAR];
        hls::stream<cplx_t>   cinv[PAR];
        hls::stream<cplx_w_t> cout_i[PAR];
        load_cols(B, cin);
        fft_core(cin[0], cout_f[0], FRAMES, 1);
        fft_core(cin[1], cout_f[1], FRAMES, 1);
        fft_core(cin[2], cout_f[2], FRAMES, 1);
        fft_core(cin[3], cout_f[3], FRAMES, 1);
        fft_core(cin[4], cout_f[4], FRAMES, 1);
        fft_core(cin[5], cout_f[5], FRAMES, 1);
        fft_core(cin[6], cout_f[6], FRAMES, 1);
        fft_core(cin[7], cout_f[7], FRAMES, 1);
        apply_g(cout_f, cinv, Ln, ct, st);
        fft_core(cinv[0], cout_i[0], FRAMES, 0);
        fft_core(cinv[1], cout_i[1], FRAMES, 0);
        fft_core(cinv[2], cout_i[2], FRAMES, 0);
        fft_core(cinv[3], cout_i[3], FRAMES, 0);
        fft_core(cinv[4], cout_i[4], FRAMES, 0);
        fft_core(cinv[5], cout_i[5], FRAMES, 0);
        fft_core(cinv[6], cout_i[6], FRAMES, 0);
        fft_core(cinv[7], cout_i[7], FRAMES, 0);
        store_cols(cout_i, A);
    }
    {
#pragma HLS dataflow
        hls::stream<cplx_t>   iin[PAR];
        hls::stream<cplx_w_t> iout[PAR];
        load_rows2(A, iin);
        fft_core(iin[0], iout[0], FRAMES, 0);
        fft_core(iin[1], iout[1], FRAMES, 0);
        fft_core(iin[2], iout[2], FRAMES, 0);
        fft_core(iin[3], iout[3], FRAMES, 0);
        fft_core(iin[4], iout[4], FRAMES, 0);
        fft_core(iin[5], iout[5], FRAMES, 0);
        fft_core(iin[6], iout[6], FRAMES, 0);
        fft_core(iin[7], iout[7], FRAMES, 0);
        store_tile(iout, outst, ox, oy, vx);
    }
}

// ---------------- top ----------------
void wiener_stream(hls::stream<axis_frame_t> &din, hls::stream<axis_frame_t> &dout,
                   int width, int height,
                   ap_int<32> params[3][256]) {
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

            q15_t Lnq, ctq, stq;
            Lnq.range(15, 0) = params[0][idx].range(15, 0);
            ctq.range(15, 0) = params[1][idx].range(15, 0);
            stq.range(15, 0) = params[2][idx].range(15, 0);
            idx++;

            block_wiener(A, B, Lnq, ctq, stq, outst, ox, oy, vx);
        }

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
            q15_t Lnq, ctq, stq;
            Lnq.range(15, 0) = params[0][idx].range(15, 0);
            ctq.range(15, 0) = params[1][idx].range(15, 0);
            stq.range(15, 0) = params[2][idx].range(15, 0);
            idx++;
            block_wiener(A, B, Lnq, ctq, stq, outst, ox, oy, vx);
        }
        for (int j = 0; j < 128; ++j)
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
}
