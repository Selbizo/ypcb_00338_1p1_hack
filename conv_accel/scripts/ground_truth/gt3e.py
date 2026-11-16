import numpy as np, cv2, math
np.random.seed(3)
W, H = 1920, 1080
CP = np.array([W/2.0, H/2.0])
DX, DY, DA = 30.0, 10.0, 0.1
P = 192

def splat(K, sx, sy, w, B):
    x0, y0 = math.floor(sx), math.floor(sy)
    fx, fy = sx-x0, sy-y0
    K[int(y0)   % B, int(x0)   % B] += w*(1-fx)*(1-fy)
    K[int(y0)   % B, int(x0+1) % B] += w*fx*(1-fy)
    K[(int(y0)+1) % B, int(x0)   % B] += w*(1-fx)*fy
    K[(int(y0)+1) % B, int(x0+1) % B] += w*fx*fy

def psf_kernel(p0, T, Phi, B, N=192):
    K = np.zeros((B, B), np.float64)
    r0 = p0 - CP
    for i in range(N):
        u = i/(N-1)
        ph = u*Phi; co, si = math.cos(ph), math.sin(ph)
        R = np.array([[co, -si], [si, co]])
        s = u*T + R @ r0 - r0
        splat(K, s[0], s[1], 1.0/N, B)
    return K

def affine_W(u, T, Phi, c):
    ph = u*Phi; co, si = math.cos(ph), math.sin(ph)
    R = np.array([[co, -si], [si, co]])
    t = c + u*T - R @ c
    return np.array([[R[0,0], R[0,1], t[0]], [R[1,0], R[1,1], t[1]]])

def render(img, T, Phi, N):
    h, w = img.shape
    acc = np.zeros((h, w), np.float32)
    for i in range(N):
        u = i/(N-1)
        M = affine_W(u, T, Phi, CP).astype(np.float32)
        acc += cv2.warpAffine(img, M, (w, h), flags=cv2.INTER_LINEAR, borderMode=cv2.BORDER_REFLECT)
    return acc/N

def pad(i): return cv2.copyMakeBorder(i, P, P, P, P, cv2.BORDER_REFLECT)
def bstarts(total, B, hop):
    s = list(range(0, total-B+1, hop))
    if s[-1] != total-B: s.append(total-B)
    return s

def deblur_wola(img, B, hop, T, Phi, nsr, N=192):
    Hp, Wp_ = img.shape
    w1 = np.hanning(B)
    win = np.outer(w1, w1).astype(np.float32)
    out = np.zeros_like(img, np.float32); wsum = np.zeros_like(img, np.float32)
    for y0 in bstarts(Hp, B, hop):
        for x0 in bstarts(Wp_, B, hop):
            ctr = np.array([x0+B/2.0-P, y0+B/2.0-P])
            Hf = np.fft.fft2(psf_kernel(ctr, T, Phi, B, N))
            G = np.conj(Hf)/(np.abs(Hf)**2 + nsr)
            blk = img[y0:y0+B, x0:x0+B]
            rec = np.real(np.fft.ifft2(np.fft.fft2(blk)*G))
            out[y0:y0+B, x0:x0+B] += rec*win
            wsum[y0:y0+B, x0:x0+B] += win
    return np.clip(out/np.maximum(wsum, 1e-6), 0, 255)

sharp = np.load("sharp3.npy")
yy, xx = np.mgrid[0:H, 0:W]
rr = np.hypot(xx-CP[0], yy-CP[1])
valid = (xx >= 80) & (xx < W-80) & (yy >= 80) & (yy < H-80)
masks = {"центр": valid & (rr < 150),
         "150-400": valid & (rr >= 150) & (rr < 400),
         "400-700": valid & (rr >= 400) & (rr < 700),
         "углы": valid & (rr >= 700)}

def psnr(a, b, m=None):
    if m is not None: a, b = a[m], b[m]
    mse = np.mean((a.astype(np.float64)-b.astype(np.float64))**2)
    return 99.0 if mse == 0 else 10*math.log10(255.0**2/mse)

def evaluate(im):
    return [psnr(im, sharp, valid)] + [psnr(im, sharp, m) for m in masks.values()]

print("%5s %7s | %-24s | %-24s | %-24s" % ("D", "смаз", "размыто", "PSF сдвиг  nsr1e-2", "PSF сдвиг+вращ nsr1e-2"))
print("%5s %7s | %7s %7s %7s %7s | %7s %7s %7s %7s | %7s %7s %7s %7s" % (
    "", "угол", "всё", "ц", "400-700", "уг", "всё", "ц", "400-700", "уг", "всё", "ц", "400-700", "уг"))
print("-"*112)
for D in (0.1, 0.2, 0.3, 0.5):
    T = np.array([D*DX, D*DY], float); Phi = D*DA
    blur = render(sharp, T, Phi, 128)
    corner_len = np.linalg.norm(T + np.array([[math.cos(Phi)-1, -math.sin(Phi)],
                                              [math.sin(Phi), math.cos(Phi)]]) @ np.array([-960,-540]))
    bp = pad(blur)
    b = evaluate(blur)
    tr = evaluate(deblur_wola(bp, 512, 256, T, 0.0, 1e-2)[P:P+H, P:P+W])
    fu = evaluate(deblur_wola(bp, 512, 256, T, Phi, 1e-2)[P:P+H, P:P+W])
    pick = lambda v: (v[0], v[1], v[3], v[4])
    print("%5.2f %7.1f | %7.2f %7.2f %7.2f %7.2f | %7.2f %7.2f %7.2f %7.2f | %7.2f %7.2f %7.2f %7.2f" % (
        D, corner_len, *pick(b), *pick(tr), *pick(fu)))
    if D in (0.2, 0.5):
        np.save("sweep_blur_D%.1f.npy" % D, blur)
        np.save("sweep_full_D%.1f.npy" % D, deblur_wola(bp, 512, 256, T, Phi, 1e-2)[P:P+H, P:P+W])
        np.save("sweep_tr_D%.1f.npy" % D, deblur_wola(bp, 512, 256, T, 0.0, 1e-2)[P:P+H, P:P+W])

# visual for D=0.2 (likely real case)
blur = np.load("sweep_blur_D0.2.npy"); full = np.load("sweep_full_D0.2.npy"); tr = np.load("sweep_tr_D0.2.npy")
def grid(fn, tiles, y0, y1, x0, x1):
    th = []
    for name, im in tiles:
        t = cv2.cvtColor(np.clip(im,0,255).astype(np.uint8), cv2.COLOR_GRAY2BGR)[y0:y1, x0:x1]
        cv2.putText(t, name, (8,26), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (0,255,0), 2)
        th.append(t)
    while len(th)%2: th.append(np.zeros_like(th[0]))
    cv2.imwrite(fn, np.vstack([np.hstack(th[i:i+2]) for i in range(0,len(th),2)]))
grid("grid3e_D02_center.png", [("sharp", sharp), ("blurred D=.2", blur),
     ("deblur trans", tr), ("deblur trans+rot", full)], 200, 860, 520, 1400)
grid("grid3e_D02_corner.png", [("sharp", sharp), ("blurred D=.2", blur),
     ("deblur trans", tr), ("deblur trans+rot", full)], 120, 760, 120, 1020)
print("saved grid3e_D02_center.png / grid3e_D02_corner.png")
