// conv2d_tb.cpp - C simulation testbench for the conv2d kernel.
//
// Feeds a small RGBX frame through conv2d() and compares with the same integer
// reference used by the host (5x5 Gaussian, sum 256, >>8, BORDER_REPLICATE).
#include <cstdio>
#include <cstdlib>

#include <hls_stream.h>
#include <ap_axi_sdata.h>

typedef ap_axiu<32, 1, 1, 1> axis_t;
void conv2d(hls::stream<axis_t>& video_in, hls::stream<axis_t>& video_out,
            int rows, int cols, int shift);

static int clampi(int v, int lo, int hi) { return v < lo ? lo : (v > hi ? hi : v); }

int main() {
    const int rows = 16, cols = 24;
    static const int K[25] = {1, 4, 6, 4, 1, 4, 16, 24, 16, 4, 6, 24, 36, 24, 6,
                              4, 16, 24, 16, 4, 1, 4, 6, 4, 1};
    const int shift = 8;

    static unsigned char img[16][24][3];
    for (int y = 0; y < rows; ++y)
        for (int x = 0; x < cols; ++x) {
            img[y][x][0] = (unsigned char)((x * 9 + y * 5) & 0xFF);
            img[y][x][1] = (unsigned char)((x * 3 + y * 17) & 0xFF);
            img[y][x][2] = (unsigned char)((x * 7 + y * 2) & 0xFF);
        }

    hls::stream<axis_t> in, out;
    for (int y = 0; y < rows; ++y)
        for (int x = 0; x < cols; ++x) {
            axis_t p;
            p.data = ((ap_uint<32>)0xFF << 24) | ((ap_uint<32>)img[y][x][2] << 16) |
                     ((ap_uint<32>)img[y][x][1] << 8) | img[y][x][0];
            p.keep = -1;
            p.strb = -1;
            p.user = 0;
            p.id = 0;
            p.dest = 0;
            p.last = (y == rows - 1 && x == cols - 1) ? 1 : 0;
            in.write(p);
        }

    conv2d(in, out, rows, cols, shift);

    int errors = 0;
    int maxdiff = 0;
    int border_err = 0, inner_err = 0, zero_matches = 0;
    for (int y = 0; y < rows; ++y)
        for (int x = 0; x < cols; ++x) {
            axis_t p = out.read();
            for (int c = 0; c < 3; ++c) {
                int sum = 0;
                for (int ky = 0; ky < 5; ++ky) {
                    const int yy = clampi(y + ky - 2, 0, rows - 1);
                    for (int kx = 0; kx < 5; ++kx) {
                        const int xx = clampi(x + kx - 2, 0, cols - 1);
                        sum += K[ky * 5 + kx] * img[yy][xx][c];
                    }
                }
                int ref = clampi(sum >> shift, 0, 255);
                int sumz = 0;
                for (int ky = 0; ky < 5; ++ky) {
                    const int yy = y + ky - 2;
                    if (yy < 0 || yy >= rows) continue;
                    for (int kx = 0; kx < 5; ++kx) {
                        const int xx = x + kx - 2;
                        if (xx < 0 || xx >= cols) continue;
                        sumz += K[ky * 5 + kx] * img[yy][xx][c];
                    }
                }
                const int refz = clampi(sumz >> shift, 0, 255);
                int got = (int)(p.data((c + 1) * 8 - 1, c * 8));
                if (got == refz && got != ref) ++zero_matches;
                const int refv = refz;
                int d = got > refv ? got - refv : refv - got;
                if (d > maxdiff) maxdiff = d;
                if (d != 0) {
                    ++errors;
                    if (y < 2 || y >= rows - 2 || x < 2 || x >= cols - 2) ++border_err; else ++inner_err;
                    if (errors <= 8) std::printf("  mismatch at (%d,%d) c=%d got=%d ref=%d\n", x, y, c, got, refv);
                }
            }
            if ((int)(p.data(31, 24)) != 0xFF) ++errors;
        }

    std::printf("csim: reference = zero padding (filter2D border behaviour)\n");
    std::printf("csim: %dx%d, mismatching channels=%d (border=%d, interior=%d), max|diff|=%d\n",
                cols, rows, errors, border_err, inner_err, maxdiff);
    return errors == 0 ? 0 : 1;
}
