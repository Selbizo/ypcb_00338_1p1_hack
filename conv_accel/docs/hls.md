# HLS-ядра (Vitis HLS + Vitis Vision)

## Что проверено

| Ядро | Интерфейс | Результат |
|---|---|---|
| `passthrough` | AXI4-Stream 24 бит, free-running | II=1, Fmax ~1052 МГц, IP собран |
| `conv2d` (5×5 RGB, `xf::cv::filter2D`) | AXI4-Stream 24 бит + AXI-Lite | **II=1**, Fmax **331 МГц** (цель 250 МГц), 4K-кадр ~33 мс |

`conv2d` на 4K (2160×3840): 8 383 187 тактов на кадр при 250 МГц → **33.5 мс → ~30 fps**
(ровно столько, сколько даёт линк x4 Gen2; см. `platform.md`).

Оценка ресурсов `conv2d` с **константными** коэффициентами: ~30 BRAM18 (линейные
буферы), ~5.6K LUT, 6 DSP (постоянные коэффициенты HLS свернул в сдвиги/сложения).
С **runtime**-коэффициентами появятся реальные умножители (~75 DSP) — это
ожидаемо и в бюджет чипа укладывается с запасом.

## Важно: пути с пробелами

**Vitis HLS не принимает пробелы в пути проекта.** Репозиторий лежит в
`/mnt/data/FPGA projects/...`, поэтому все `build.tcl` собирают в
`/tmp/conv_accel_hls/<kernel>/`, а готовый IP копируют в `hw/ip_repo/`.
Заголовки Vitis Vision для `conv2d` тоже копируются в `/tmp` (4 МБ).

## Библиотека

Vitis Vision 2024.2 (наследник xfOpenCV), только `vision/L1/include` (~4 МБ):

```bash
./scripts/fetch_vision.sh     # пин на v2024.2_update3
```

В git не попадает.

## Сборка ядер

```bash
cd hls/kernels/<kernel>
vitis_hls -f build.tcl
```

Результат: `hw/ip_repo/<kernel>/component.xml` (и `.zip` рядом) — это готовый
IP для Vivado.

## Интерфейс слота (контракт платформы)

Каждое ядро должно иметь:

- `video_in`, `video_out` — `hls::stream<ap_axiu<24,1,1,1>>` (AXI4-Stream,
  24-бит RGB, 1 пиксель/такт; `TUSER` = SOF, `TLAST` = EOL);
- управление — AXI4-Lite (`rows`, `cols`, коэффициенты, `shift`, ...);
- целевая частота — 250 МГц (4 нс), II=1.

Тогда ядро вставляется в BD без изменения платформы.

## Замечания по Vitis Vision

- `xf::cv::Mat` в синтезе по умолчанию **стриминговый** (`_XFCVDEPTH_DEFAULT=2`),
  поэтому `filter2D` не держит кадр в памяти — только линейные буферы. 4K
  помещается.
- `xf::cv::filter2D<BORDER, K_W, K_H, SRC, DST, ROWS, COLS, NPC>(src, dst, short k[K*K], uchar shift)` —
  коэффициенты и `shift` **runtime**, размер `K` — параметр шаблона.
- `xf::cv::warpTransform` (аффинна/perspective) и `xf::cv::densePyrOpticalFlow`
  (плотный пирамидальный LK) доступны для будущей стабилизации.
- Runtime-коэффициенты в топе пока не выведены наружу: в `conv2d.cpp` они
  константные (Gaussian 5×5). Следующий шаг — 25 AXI-Lite регистров или
  регистровый BRAM.
