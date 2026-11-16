#include <ap_fixed.h>
#include <complex>
#include <cmath>
#include <cstdio>
#include <cstdlib>
typedef ap_fixed<24,1> sample_t;
typedef std::complex<sample_t> cplx_t;
typedef ap_fixed<32,9> wide_t;
typedef std::complex<wide_t> cplx_w_t;
void wiener_block_u(cplx_t in[128][128], cplx_w_t out[128][128],
                    float L, float th, float nsr, float gs, int mode);
static const int N = 128;
static double L, TH, NSR, GS;
static std::complex<double> gcpu(int kx, int ky) {
    int sx = (kx < N/2) ? kx : kx - N;
    int sy = (ky < N/2) ? ky : ky - N;
    double a  = (L/N) * (sx*std::cos(TH) + sy*std::sin(TH));
    double pa = M_PI * a;
    double s  = (std::fabs(a) < 1e-9) ? 1.0 : std::sin(pa)/pa;
    double d  = s*s + NSR;
    return std::complex<double>(GS*s*std::cos(pa)/d, GS*s*std::sin(pa)/d);
}
int main() {
    cplx_t in[N][N]; cplx_w_t out[N][N];
    std::complex<double> x[N][N], R[N][N], F[N][N], P[N][N], Q[N][N], Y[N][N];
    L=20.0; TH=0.30; NSR=0.01; GS=0.05;
    for (int r=0;r<N;r++) for (int c=0;c<N;c++) {
        double v = 0.15 + 0.25*std::cos(2*M_PI*(3.0*c+5.0*r)/N)
                 + 0.10*std::sin(2*M_PI*(11.0*c-7.0*r)/N)
                 + 0.05*((double)std::rand()/RAND_MAX-0.5);
        in[r][c] = cplx_t(sample_t(v), sample_t(0.0));
        x[r][c]  = std::complex<double>(in[r][c].real().to_double(), 0.0);
    }
    for (int r=0;r<N;r++) for (int kx=0;kx<N;kx++) {
        std::complex<double> s(0,0);
        for (int c=0;c<N;c++) { double ph=-2*M_PI*kx*c/N; s+=x[r][c]*std::complex<double>(std::cos(ph),std::sin(ph)); }
        R[r][kx]=s;
    }
    for (int kx=0;kx<N;kx++) for (int ky=0;ky<N;ky++) {
        std::complex<double> s(0,0);
        for (int r=0;r<N;r++) { double ph=-2*M_PI*ky*r/N; s+=R[r][kx]*std::complex<double>(std::cos(ph),std::sin(ph)); }
        F[ky][kx]=s;
    }
    for (int ky=0;ky<N;ky++) for (int kx=0;kx<N;kx++) P[ky][kx]=F[ky][kx]*gcpu(kx,ky);
    for (int kx=0;kx<N;kx++) for (int r=0;r<N;r++) {
        std::complex<double> s(0,0);
        for (int ky=0;ky<N;ky++) { double ph=2*M_PI*ky*r/N; s+=P[ky][kx]*std::complex<double>(std::cos(ph),std::sin(ph)); }
        Q[r][kx]=s;
    }
    for (int r=0;r<N;r++) for (int c=0;c<N;c++) {
        std::complex<double> s(0,0);
        for (int kx=0;kx<N;kx++) { double ph=2*M_PI*kx*c/N; s+=Q[r][kx]*std::complex<double>(std::cos(ph),std::sin(ph)); }
        Y[r][c]=s/(double)(N*N);
    }
    wiener_block_u(in,out,(float)L,(float)TH,(float)NSR,(float)GS,1);
    { double num0=0,den0=0;
      for (int r=0;r<N;r++) for (int c=0;c<N;c++) { double o=out[r][c].real().to_double(); double ref=x[r][c].real(); num0+=o*ref; den0+=ref*ref; }
      double a0=num0/den0, e2=0,r2=0,im=0;
      for (int r=0;r<N;r++) for (int c=0;c<N;c++) { double o=out[r][c].real().to_double(); double ref=a0*x[r][c].real(); double e=o-ref; e2+=e*e; r2+=ref*ref; double oi=out[r][c].imag().to_double(); if (std::fabs(oi)>im) im=std::fabs(oi); }
      std::printf("roundtrip: PSNR = %.1f dB  alpha = %.6g  max|imag| = %.5f\n", 10*std::log10(r2/e2), a0, im);
    }
    wiener_block_u(in,out,(float)L,(float)TH,(float)NSR,(float)GS,0);
    double num=0,den=0;
    for (int r=0;r<N;r++) for (int c=0;c<N;c++) {
        double o=out[r][c].real().to_double();
        num+=o*Y[r][c].real(); den+=Y[r][c].real()*Y[r][c].real();
    }
    double alpha=num/den;
    double err2=0,ref2=0,maxe=0,imax=0,ormax=0;
    for (int r=0;r<N;r++) for (int c=0;c<N;c++) {
        double o=out[r][c].real().to_double();
        double oi=out[r][c].imag().to_double();
        double ref=alpha*Y[r][c].real();
        double e=o-ref;
        err2+=e*e; ref2+=ref*ref;
        if (std::fabs(e)>maxe) maxe=std::fabs(e);
        if (std::fabs(oi)>imax) imax=std::fabs(oi);
        if (std::fabs(o)>ormax) ormax=std::fabs(o);
    }
    std::printf("unscaled wiener_block %dx%d: fit PSNR = %.1f dB  alpha = %.6g (1/alpha = %.4g)\n",
        N,N,10*std::log10(ref2/err2),alpha,1.0/alpha);
    std::printf("  max|out| = %.3f  max|err| = %.5f  max|imag| = %.5f\n", ormax, maxe, imax);
    return 0;
}
