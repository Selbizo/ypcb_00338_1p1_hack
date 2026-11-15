// conv2d_tb.cpp - C simulation testbench for the conv2d kernel.
//
// Runs several 5x5 kernels through conv2d() and compares with the same integer
// reference as the host: sum of products, arithmetic shift, saturation to
// [0,255], zero padding at the borders.
#include <cstdio>
#include <cstdlib>

#include <hls_stream.h>
#include <ap_axi_sdata.h>

typedef ap_axiu<32, 1, 1, 1> axis_t;
void conv2d(hls::stream<axis_t>& video_in, hls::stream<axis_t>& video_out,
            int rows, int cols, int shift, short int coeff[25]);

static int clampi(int v, int lo, int hi) { return v < lo ? lo : (v > hi ? hi : v); }

struct Case {
    const char* name;
    short k[25];
    int shift;
};

int main() {
    const int rows = 16, cols = 24;

    static const Case cases[] = {
        {"gauss", {1, 4, 6, 4, 1, 4, 16, 24, 16, 4, 6, 24, 36, 24, 6,
                   4, 16, 24, 16, 4, 1, 4, 6, 4, 1}, 8},
        {"sharp", {0, 0, -1, 0, 0, 0, -1, -2, -1, 0, -1, -2, 17, -2, -1,
                   0, -1, -2, -1, 0, 0, 0, -1, 0, 0}, 0},
        {"edge", {0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, -1, 4, -1, 0,
                  0, 0, -1, 0, 0, 0, 0, 0, 0, 0}, 0},
    };

    static unsigned char img[16][24][3];
    for (int y = 0; y < rows; ++y)
        for (int x = 0; x < cols; ++x) {
            img[y][x][0] = (unsigned char)((x * 9 + y * 5) & 0xFF);
            img[y][x][1] = (unsigned char)((x * 3 + y * 17) & 0xFF);
            img[y][x][2] = (unsigned char)((x * 7 + y * 2) & 0xFF);
        }

    int failed = 0;
    for (const Case& c : cases) {
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

        short k[25];
        for (int i = 0; i < 25; ++i) k[i] = c.k[i];
        conv2d(in, out, rows, cols, c.shift, k);

        int errors = 0, maxdiff = 0;
        for (int y = 0; y < rows; ++y)
            for (int x = 0; x < cols; ++x) {
                axis_t p = out.read();
                for (int ch = 0; ch < 3; ++ch) {
                    int sum = 0;
                    for (int ky = 0; ky < 5; ++ky) {
                        const int yy = y + ky - 2;
                        if (yy < 0 || yy >= rows) continue;   // zero padding
                        for (int kx = 0; kx < 5; ++kx) {
                            const int xx = x + kx - 2;
                            if (xx < 0 || xx >= cols) continue;
                            sum += c.k[ky * 5 + kx] * img[yy][xx][ch];
                        }
                    }
                    const int ref = clampi(sum >> c.shift, 0, 255);
                    const int got = (int)(p.data((ch + 1) * 8 - 1, ch * 8));
                    const int d = got > ref ? got - ref : ref - got;
                    if (d > maxdiff) maxdiff = d;
                    if (d != 0) ++errors;
                }
                if ((int)(p.data(31, 24)) != 0xFF) ++errors;
            }
        std::printf("csim %-6s: mismatching channels=%d, max|diff|=%d\n", c.name, errors, maxdiff);
        if (errors) ++failed;
    }
    return failed == 0 ? 0 : 1;
}
