#include <ap_fixed.h>
#include <complex>
#include <cmath>
#include <cstdio>
#include <cstdlib>
typedef ap_fixed<16,1> sample_t;
typedef std::complex<sample_t> cplx_t;
void fft512_bfp(cplx_t xn[512], cplx_t xk[512], int dir, int *blkexp);
int main(){
    const int N=512; cplx_t xn[N], xk[N]; std::complex<double> ref[N];
    for(int n=0;n<N;n++){
        double re=0.40*std::cos(2*M_PI*3.0*n/N)+0.20*(std::rand()/(double)RAND_MAX-0.5);
        double im=0.30*std::sin(2*M_PI*7.0*n/N)+0.20*(std::rand()/(double)RAND_MAX-0.5);
        xn[n]=cplx_t(sample_t(re),sample_t(im));
    }
    for(int n=0;n<N;n++) ref[n]=std::complex<double>(xn[n].real().to_double(),xn[n].imag().to_double());
    int blkexp=0; fft512_bfp(xn,xk,1,&blkexp);
    double num=0,den=0;
    for(int k=0;k<N;k++){
        std::complex<double> s(0,0);
        for(int n=0;n<N;n++){double ph=-2*M_PI*k*n/N; s+=ref[n]*std::complex<double>(std::cos(ph),std::sin(ph));}
        std::complex<double> y(xk[k].real().to_double(),xk[k].imag().to_double());
        num+=(y*std::conj(s)).real(); den+=std::norm(s);
    }
    double alpha=num/den;
    double err2=0,ref2=0;
    for(int k=0;k<N;k++){
        std::complex<double> s(0,0);
        for(int n=0;n<N;n++){double ph=-2*M_PI*k*n/N; s+=ref[n]*std::complex<double>(std::cos(ph),std::sin(ph));}
        std::complex<double> y(xk[k].real().to_double(),xk[k].imag().to_double());
        err2+=std::norm(y-alpha*s); ref2+=std::norm(alpha*s);
    }
    printf("BFP blkexp=%d  1/alpha=%.2f  2^blkexp=%.0f  SNR=%.1f dB\n",
        blkexp, 1.0/alpha, std::pow(2.0,blkexp), 10*std::log10(ref2/err2));
    return 0;
}
