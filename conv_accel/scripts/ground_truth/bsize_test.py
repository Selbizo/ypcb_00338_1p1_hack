import numpy as np, cv2, math
exec(open('gt3e.py').read().split('sharp = np.load')[0])
sharp=np.load('sharp3.npy')
H,W=sharp.shape; CP=np.array([W/2.0,H/2.0]); P=192
for D in (0.2,0.5):
    T=np.array([30*D,10*D]); Phi=0.1*D
    blur=render(sharp,T,Phi,128)
    bp=cv2.copyMakeBorder(blur,P,P,P,P,cv2.BORDER_REFLECT)
    yy,xx=np.mgrid[0:H,0:W]; rr=np.hypot(xx-CP[0],yy-CP[1])
    valid=(xx>=80)&(xx<W-80)&(yy>=80)&(yy<H-80)
    masks={"центр":valid&(rr<150),"400-700":valid&(rr>=400)&(rr<700),"углы":valid&(rr>=700)}
    def psnr(a,b,m=None):
        if m is not None: a,b=a[m],b[m]
        mse=np.mean((a.astype(np.float64)-b.astype(np.float64))**2)
        return 99.0 if mse==0 else 10*math.log10(255.0**2/mse)
    def rep(tag,im):
        print("  %-18s %7.2f %7.2f %7.2f %7.2f"%(tag,psnr(im,sharp,valid),
            *[psnr(im,sharp,m) for m in masks.values()]))
    print("D=%.1f"%D)
    rep("размыто",blur)
    for B,hop,nsr in ((512,256,1e-2),(256,128,1e-2),(256,64,1e-2),(256,128,3e-2)):
        im=deblur_wola(bp,B,hop,T,Phi,nsr)[P:P+H,P:P+W]
        rep("B%d h%d nsr%.0e"%(B,hop,nsr),im)
