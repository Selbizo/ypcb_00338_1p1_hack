# conv_accel/host — OpenCV C++ приложение

Front-end на OpenCV для видео-платформы на ПЛИС.

## Сборка

```bash
cd conv_accel/host
cmake -S . -B build
cmake --build build -j
```

## Запуск

```bash
# камера 0, окно, пока не нажать Esc
./build/conv_demo

# без окна (сохранит один PNG и напечатает статистику)
./build/conv_demo --headless --frames 60 --out /tmp

# без камеры, синтетическая картинка
./build/conv_demo --synthetic --headless --frames 30 --out /tmp
```

Опции: `--camera N`, `--width W`, `--height H`, `--frames N`, `--headless`,
`--synthetic`, `--verify`, `--out DIR`.

## Что делает (этап 0)

Кадр BGR → `H2C` DMA в DDR3 (`AXI 0x0`) → `C2H` DMA обратно → показ.
Это проверяет весь хост-тракт: OpenCV → XDMA → PCIe → DDR3 и обратно.
`--verify` сверяет выход с входом (для loopback должно быть 0).

## Архитектура

```
apps/conv_demo.cpp      приложение (камера, окно, статистика)
src/xdma.cpp            обёртка над /dev/xdma0_{h2c,c2h}_0 (offset = AXI адрес)
src/pipeline.cpp        IVideoPipeline: сейчас DdrLoopback, дальше VDMA+kernel
tests/dma_pattern.c     низкоуровневый тест DDR3 (без OpenCV)
```

`IVideoPipeline::process(cv::Mat) -> cv::Mat` — точка расширения: реализация
VDMA+ядро подставится без изменения приложения.
