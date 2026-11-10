# Следующий этап: user BAR + VDMA + слот ядра (M0/M1)

Текущее состояние (коммиты `ba1881d`, `1de1b01`): платформа этапа 0 работает,
хост-приложение на OpenCV собирается и гоняет кадр через DDR3. Ниже — что
делать дальше и на какие грабли я уже наступил.

## 1. Включить user BAR (AXI-Lite master у XDMA)

**Проблема:** параметр `XDMA_AXILITE_MASTER` **не выведен** в BD как
`CONFIG.*` — `set_property CONFIG.XDMA_AXILITE_MASTER` на `get_bd_cells xdma_0`
даёт `parameter does not exist`. Правка `.xci` напрямую сама по себе не
подхватывается: BD держит старую конфигурацию IP, пока IP не перегенерирован.

**Как сделать:**

- в GUI: `xdma_0` → *Re-customize IP* → PCIe to DMA Interface →
  включить **AXI-Lite Master** (~64 KB, BAR1) → OK;
  появятся `M_AXI_LITE` и адресное пространство `xdma_0/Data`;
- либо в Tcl: поправить `.xci`
  (`XDMA_AXILITE_MASTER = TRUE`, `AXILITE_MASTER_CONTROL = 0x4`,
  как в рабочем `XDMA_hello_world`), затем **перегенерировать IP**
  (удалить `accel.gen/.../top_xdma_0_0`, `reset_target`+`generate_target`),
  переоткрыть BD и проверить, что появился `M_AXI_LITE`.

После включения на хосте появится `/dev/xdma0_user` (mmap → регистры).

## 2. Проверить mmap

В Lite-пространстве повесить `axi_gpio` (32 бита, `C_ALL_OUTPUTS=1`):
записать значение, прочитать обратно (регистр выхода читается). Это проверка
пути регистров без VDMA.

## 3. Видео-тракт (M0)

```
DDR3 (кадр) --axi_vdma MM2S--> AXIS 24 бит --> ядро (passthrough) --> AXIS 24 бит
             <--axi_vdma S2MM-- DDR3 (результат)
регистры VDMA и ядра -- AXI-Lite (user BAR) -- хост
```

- `axi_vdma`: `c_include_sg=0` (simple mode), `c_m_axi_*_data_width=64`,
  `c_m_axis_mm2s_tdata_width=24`, `c_s_axis_s2mm_tdata_width=24`,
  `c_mm2s_linebuffer_depth=0` / `c_s2mm_linebuffer_depth=0`
  (линейные буферы у ядра), `c_num_fstores=3` (ping-pong).
- Мастера VDMA (MM2S/S2MM) — новые S-порты `axi_smc` (S02/S03), адреса DDR3
  те же: `0x0` (c0), `0x8000_0000` (c1).
- Буферы кадров в DDR3: вход `0x1000_0000`, выход `0x2000_0000`
  (720p BGR = 2.76 МБ на кадр, места с запасом).
- Ядро — `hw/ip_repo/passthrough` (уже собран), далее `conv2d`.
  Подключение: `vdma/m_axis_mm2s -> passthrough/video_in`,
  `passthrough/video_out -> vdma/s_axis_s2mm`.
- Управление (VDMA + ядро) — `axi_interconnect` в AXI-Lite режиме от
  `xdma_0/M_AXI_LITE`.

## 4. Хост (M0 → M1)

1. `H2C`: кадр → DDR3 `0x1000_0000`.
2. Записать регистры VDMA: `MM2S_DMACR`/`S2MM_DMACR` (run),
   `VSIZE`/`HSIZE`/`STRIDE`/`FRMDLY`, адреса кадров; `FRMCNT=1`.
3. Дождаться завершения (опрос `S2MM_DMASR`/`MM2S_DMASR` или прерывание).
4. `C2H`: результат ← DDR3 `0x2000_0000`.
5. Для `conv2d` — те же шаги плюс регистры ядра (`rows`, `cols`, `shift`).

API `IVideoPipeline::process(cv::Mat) -> cv::Mat` уже готов — добавляется
`VdmaKernelPipeline` рядом с `DdrLoopback`, приложение не меняется.

## Ограничения, о которых помнить

- Линк x4 Gen2, ~1.5 ГБ/с в одну сторону. 720p BGR: ~1.9 мс на передачу кадра,
  4K30 RGB — ровно на пределе (33 мс).
- Тайминг проекта уже на грани (WNS +0.011 нс): после добавления VDMA/ядра
  проверить и при необходимости сменить стратегию.
- После каждой прошивки/переконфигурации — `scripts/reprobe.sh`.
