/*
 * dma_pattern.c - DDR3 round-trip test for the XDMA platform.
 *
 *   gcc -O2 -o dmatest dma_pattern.c
 *   sudo ./dmatest [bytes] [axi_offset]
 *
 * Default: 1 MiB at AXI address 0x0 (DDR3 controller 0, see docs/platform.md).
 * Writes a pattern through /dev/xdma0_h2c_0, reads it back through
 * /dev/xdma0_c2h_0, compares, prints throughput.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#include <stdint.h>

static double now(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

int main(int argc, char **argv) {
    size_t len = (argc > 1) ? (size_t)atoll(argv[1]) : (1u << 20);
    unsigned long long off = (argc > 2) ? strtoull(argv[2], NULL, 0) : 0;
    char *buf, *rb;

    if (posix_memalign((void **)&buf, 4096, len) || posix_memalign((void **)&rb, 4096, len)) {
        perror("memalign");
        return 1;
    }
    for (size_t i = 0; i < len; i++) buf[i] = (char)(i * 31u + 7u);
    memset(rb, 0, len);

    int fh = open("/dev/xdma0_h2c_0", O_RDWR);
    if (fh < 0) { perror("open h2c"); return 1; }
    errno = 0;
    double t0 = now();
    ssize_t w = pwrite(fh, buf, len, (off_t)off);
    double t1 = now();
    printf("H2C: wrote %zd / %zu bytes in %.3f ms (%.1f MB/s) errno=%d %s\n",
           w, len, (t1 - t0) * 1e3, (w > 0) ? (w / 1e6) / (t1 - t0) : 0.0, errno, strerror(errno));
    close(fh);

    int fc = open("/dev/xdma0_c2h_0", O_RDWR);
    if (fc < 0) { perror("open c2h"); return 1; }
    errno = 0;
    double t2 = now();
    ssize_t r = pread(fc, rb, len, (off_t)off);
    double t3 = now();
    printf("C2H: read  %zd / %zu bytes in %.3f ms (%.1f MB/s) errno=%d %s\n",
           r, len, (t3 - t2) * 1e3, (r > 0) ? (r / 1e6) / (t3 - t2) : 0.0, errno, strerror(errno));
    close(fc);

    if (w != (ssize_t)len || r != (ssize_t)len) return 2;

    size_t bad = 0, first = (size_t)-1;
    for (size_t i = 0; i < len; i++)
        if (buf[i] != rb[i]) { if (!bad) first = i; bad++; }

    if (bad) {
        printf("MISMATCH: %zu bytes, first at %zu (0x%02x vs 0x%02x)\n",
               bad, first, (unsigned char)buf[first], (unsigned char)rb[first]);
        return 3;
    }
    printf("OK: pattern matched %zu bytes\n", len);
    return 0;
}
