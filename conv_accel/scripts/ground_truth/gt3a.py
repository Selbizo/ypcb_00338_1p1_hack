import numpy as np, cv2, math
np.random.seed(3)
W, H = 1920, 1080
CP = np.array([W/2.0, H/2.0])

DX, DY, DA, D = 30.0, 10.0, 0.1, 0.5
T   = np.array([D*DX, D*DY], float)     # (15, 5)
PHI = D*DA                               # 0.05 rad

# ---------------- helpers ----------------
def affine_W(u, T, Phi, c):
    """forward affine matrix W_u(p) = c + uT + R(uPhi)(p-c)"""
    ph = u*Phi
    co, si = math.cos(ph), math.sin(ph)
    Rm = np.array([[co, -si], [si, co]])
    t = c + u*T - Rm @ c
    return np.array([[Rm[0,0], Rm[0,1], t[0]],
                     [Rm[1,0], Rm[1,1], t[1]]])

def Wp(u, p, T, Phi, c):
    ph = u*Phi
    co, si = math.cos(ph), math.sin(ph)
    Rm = np.array([[co, -si], [si, co]])
    return c + u*T + Rm @ (p - c)

def render(img, T, Phi, c, N):
    """blurred(x) = mean_u img(W_u^{-1}(x))  (cv2 inverts M, so pass M = W_u)"""
    h, w = img.shape[:2]
    acc = np.zeros((h, w), np.float32)
    for i in range(N):
        u = i/(N-1)
        M = affine_W(u, T, Phi, c).astype(np.float32)
        acc += cv2.warpAffine(img, M, (w, h), flags=cv2.INTER_LINEAR,
                              borderMode=cv2.BORDER_REFLECT)
    return acc/N

def splat(K, sx, sy, w, B):
    x0, y0 = math.floor(sx), math.floor(sy)
    fx, fy = sx-x0, sy-y0
    K[int(y0)   % B, int(x0)   % B] += w*(1-fx)*(1-fy)
    K[int(y0)   % B, int(x0+1) % B] += w*fx*(1-fy)
    K[(int(y0)+1) % B, int(x0)   % B] += w*(1-fx)*fy
    K[(int(y0)+1) % B, int(x0+1) % B] += w*fx*fy

def psf_kernel(p0, T, Phi, c, B, N):
    """kernel of displacements s_u = W_u(p0) - p0, splatted bilinearly (adjoint of warp)"""
    K = np.zeros((B, B), np.float64)
    for i in range(N):
        u = i/(N-1)
        s = Wp(u, p0, T, Phi, c) - p0
        splat(K, s[0], s[1], 1.0/N, B)
    return K

def psnr(a, b):
    mse = np.mean((a.astype(np.float64)-b.astype(np.float64))**2)
    return 99.0 if mse == 0 else 10*math.log10(255.0**2/mse)

def model_check(sharp, blurred, p0, B, N, T, Phi, c, margin=80):
    x0 = int(round(p0[0]-B/2)); y0 = int(round(p0[1]-B/2))
    x0 = max(0, min(W-B, x0)); y0 = max(0, min(H-B, y0))
    ctr = np.array([x0+B/2.0, y0+B/2.0])
    K = psf_kernel(ctr, T, Phi, c, B, N)
    sub = sharp[y0:y0+B, x0:x0+B]
    sb  = blurred[y0:y0+B, x0:x0+B]
    conv = np.real(np.fft.ifft2(np.fft.fft2(sub)*np.fft.fft2(K)))
    d = conv[margin:-margin, margin:-margin] - sb[margin:-margin, margin:-margin]
    disp = Wp(1.0, ctr, T, Phi, c) - ctr
    return np.mean(np.abs(d)), psnr(conv[margin:-margin, margin:-margin],
                                    sb[margin:-margin, margin:-margin]), ctr, np.linalg.norm(disp)

# ---------------- 0. tiny translation test (pipeline sanity) ----------------
S = 256
src8 = np.zeros((S, S), np.uint8)
cv2.putText(src8, "TEST", (30, 120), cv2.FONT_HERSHEY_SIMPLEX, 2.5, 255, 6, cv2.LINE_AA)
src8[160:200, 30:200] = 200
src = src8.astype(np.float32)
TT = np.array([5.0, 0.0])
bl = render(src, TT, 0.0, np.array([S/2.0, S/2.0]), 128)
Kt = psf_kernel(np.array([S/2.0, S/2.0]), TT, 0.0, np.array([S/2.0, S/2.0]), S, 128)
conv = np.real(np.fft.ifft2(np.fft.fft2(src)*np.fft.fft2(Kt)))
sl = slice(40, S-40)
print("tiny 5px shift: model-vs-render PSNR = %.2f dB  (mean|d|=%.4f)" % (
    psnr(conv[sl, sl], bl[sl, sl]), np.mean(np.abs(conv[sl, sl]-bl[sl, sl]))))

# ---------------- 1. scene ----------------
c = np.full((H, W), 90, np.uint8)
cv2.putText(c, "WIENER", (140, 320), cv2.FONT_HERSHEY_SIMPLEX, 5.0, 250, 12, cv2.LINE_AA)
cv2.putText(c, "ground truth test 2026", (140, 450), cv2.FONT_HERSHEY_SIMPLEX, 1.8, 15, 6, cv2.LINE_AA)
for i in range(8):
    cv2.rectangle(c, (140+215*i, 540), (250+215*i, 650), 240 if i % 2 else 20, -1)
    cv2.circle(c, (195+215*i, 760), 48, 240 if i % 2 else 20, -1)
cv2.putText(c, "small text", (1320, 930), cv2.FONT_HERSHEY_SIMPLEX, 1.0, 245, 3, cv2.LINE_AA)
yy, xx = np.mgrid[0:256, 0:256].astype(np.float32)
r2 = (xx-128.0)**2 + (yy-128.0)**2
zp = 127.5 + 127.5*np.sin(r2*(2*np.pi/2400.0))
c[790:1046, 60:316] = np.maximum(c[790:1046, 60:316], np.clip(zp, 0, 255).astype(np.uint8))
tex = cv2.GaussianBlur(np.random.randn(H, W).astype(np.float32), (0, 0), 1.2)
tex *= 8.0/np.std(tex)
sharp = np.clip(c.astype(np.float32) + tex, 0, 255).astype(np.float32)

N = 192
print("rendering translation-only ...")
blur_t = render(sharp, T, 0.0, CP, N)
print("rendering translation+rotation ...")
blur_f = render(sharp, T, PHI, CP, N)
np.save("sharp3.npy", sharp); np.save("blur_t3.npy", blur_t); np.save("blur_f3.npy", blur_f)
print("baseline PSNR: trans %.2f dB | full %.2f dB" % (psnr(blur_t, sharp), psnr(blur_f, sharp)))

# ---------------- 2. model vs render ----------------
pts = [(960, 540), (960, 300), (600, 540), (300, 300), (1300, 900), (1620, 780)]
print("\n%-14s %10s | %-22s | %-22s" % ("центр патча", "смаз, px", "только сдвиг", "сдвиг+вращение"))
for (x, y) in pts:
    mt, pt_, ct, dt = model_check(sharp, blur_t, np.array([x, y], float), 256, N, T, 0.0, CP)
    mf, pf, cf, df = model_check(sharp, blur_f, np.array([x, y], float), 256, N, T, PHI, CP)
    print("%-14s %10.1f | mean|d| %5.2f %6.2f dB | mean|d| %5.2f %6.2f dB" % (
        "(%d,%d)" % (x, y), df, mt, pt_, mf, pf))
