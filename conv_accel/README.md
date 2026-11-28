# conv_accel — платформа аппаратного ускорения видео (YPCB-00338-1P1)

Базовая платформа для видео-пайплайнов на карте **YPCB-00338-1P1** (Xilinx
Kintex-7 XC7K480T-FFG1156-2, PCIe, DDR3), которую дальше наращиваем фичами
(свёртка, optical flow, стабилизация и т.д.).

## Что уже работает (этап 0)

- PCIe: XDMA, **линк x4 Gen2** (5 GT/s × 4). Плата умеет x8 Gen2, но слот,
  в котором она стоит, — x4 Gen3, поэтому тренируется x4 Gen2.
- Драйвер `xdma` (Xilinx, v2025.2.0) собран и работает.
- DMA в DDR3 и обратно: **~1.53 ГБ/с** в каждую сторону, паттерн 64 МБ
  проверен побайтово (DDR3 с ECC работает).
- Загрузка из BPI-флеша (синхронный BPI, `CONFIGRATE 33`) — проверена.
- HLS-цепочка проверена: `passthrough` и `conv2d` (Vitis Vision `filter2D`
  5×5 RGB) синтезируются с **II=1**; `conv2d` на 4K — ~33 мс/кадр при 250 МГц,
  оценка Fmax 331 МГц. IP лежат в `hw/ip_repo/`.
- Vitis Vision 2024.2 подтянут (`hls/third_party/vision`).
- **Деблюр (Y-Wiener) целиком на FPGA**: 16 × xfft + потоковое ядро,
  1080p, ~95 мс на кадр (`deblur_bench`, включая PCIe-обмен), 10.6 fps.

## Стенд сравнения бэкендов

Одна задача деблюра — четыре реализации за общим API: **CPU, OpenCL,
CUDA, FPGA**. Стенд меряет медианное время, fps и PSNR относительно CPU:

```bash
./host/build/deblur_bench --in blur.png --iters 7 --warmup 2 \
    --dx 9 --dy 0 --exposure 1 --nsr 0.01
```

Подробное объяснение «для неспециалиста», устройство стенда, результаты
замеров и как добавить свой бэкенд — в [`docs/benchmark.md`](docs/benchmark.md).

## Деблюр видео

`deblur_video` оценивает движение по соседним кадрам (GFTT + LK +
`estimateAffine2D`) и применяет выбранный бэкенд. Смещение между кадрами —
это `velocity * frame_interval`, а смаз на кадре — `velocity * shutter_time`.
Поэтому длину PSF нельзя брать прямо из межкадрового смещения: нужен
коэффициент `D = shutter_time / frame_interval`:

```bash
# выдержка 1 мс, 30 fps -> D ≈ 0.03; PSF в 33 раза короче смещения кадров
./host/build/deblur_video --in video.mp4 --out out.mp4 \
    --backend fpga --shutter 0.001 --nsr 0.01

# то же через угол выдержки (180° = половина периода кадра)
./host/build/deblur_video --in video.mp4 --shutter-angle 180

# если D уже известно
./host/build/deblur_video --in video.mp4 --exposure 0.03
```

Для `--shutter` D пересчитывается по фактическим меткам времени кадров
(`CAP_PROP_POS_MSEC`), поэтому переменный frame rate не ломает оценку.
`--dump-psf DIR` сохраняет PSF по блокам и печатает `L` в пикселях — по нему
видно, совпадает ли оценка с реальным смазом.

## Что дальше

1. Включить в XDMA AXI-Lite master (user BAR) — путь для регистров.
2. Добавить в BD `axi_vdma` + слот для ядра (`ip_repo`) + адреса; собрать.
3. M0: passthrough сквозь VDMA/DDR3 — проверить тракт целиком.
4. M1: `conv2d` в слоте, сверить с `cv::filter2D`.
5. Стабилизация: `warpTransform` + `densePyrOpticalFlow`.

## Структура

```
conv_accel/
├── hw/           Vivado-проект платформы (accel.xpr)
├── hls/          HLS-ядра (Vitis Vision), third_party/vision — библиотека
├── host/         C++/OpenCV приложение и обвязка
├── scripts/      сборка, mcs, прошивка, переподключение драйвера
└── docs/         карта адресов, особенности платы и т.п.
```

## Быстрый старт

```bash
# 1. Библиотека Vitis Vision (только заголовки, ~4 МБ, в git не попадает)
./scripts/fetch_vision.sh

# 2. Сборка железа (Vivado 2024.2)
vivado -mode batch -source scripts/build_hw.tcl

# 3. .mcs для флеша
vivado -mode batch -source scripts/make_mcs.tcl

# 4. Прошивка флеша через JTAG (нужен подключённый кабель)
vivado -mode batch -source scripts/flash.tcl

# 5. После ЛЮБОЙ переконфигурации ПЛИС (JTAG/boot) — переподключить устройство
sudo ./scripts/reprobe.sh
```

Проверка тракта без железячных фильтров:

```bash
gcc -O2 -o /tmp/dmatest host/tests/dma_pattern.c
sudo /tmp/dmatest 25165824 0     # 24 МБ туда-обратно в DDR3 @ AXI 0x0
```

## Важные особенности

- **После переконфигурации ПЛИС** (JTAG или `boot_hw_device`) PCIe config-space
  сбрасывается, а ядро об этом не узнаёт → BAR'ы «пропадают». Лечится
  `scripts/reprobe.sh` (remove + rescan + reload драйвера). При **холодной
  загрузке** из флеша проблемы нет — BIOS видит карту сразу.
- **JTAG-прошивка**: битстрим собран с `STARTUPCLK = Cclk` (правильно для
  загрузки из флеша), поэтому по JTAG startup не завершается и Vivado ругается
  `End of startup status: LOW`. Для JTAG-отладки собирайте вариант с
  `BITSTREAM.STARTUP.STARTUPCLK JtagClk` (см. `docs/platform.md`).
- Тайминг закрыт с очень малым запасом: **WNS +0.011 нс**. При добавлении
  логики возможна повторная оптимизация.
- Во флеш кладём только `.mcs` (BPIX16), не `.bin`/`.bit`.

Подробности — в `docs/platform.md`.

## Документация

- [`docs/tutorial.md`](docs/tutorial.md) — **учебник**: как проект
  строился шаг за шагом, алгоритм, HLS, BD, хост, отладка, ускорение,
  чек-листы и «грабли».
- [`docs/benchmark.md`](docs/benchmark.md) — стенд сравнения
  CPU / OpenCL / CUDA / FPGA.
- [`docs/platform.md`](docs/platform.md) — плата, линк, DDR3, флеш.
- [`docs/architecture_multi_backend.md`](docs/architecture_multi_backend.md) —
  карта адресов и история работ.
