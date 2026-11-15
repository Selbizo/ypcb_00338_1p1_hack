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

---

# VDMA: диагностика (14.11.2026)

## Что проверено и исключено

- **Клоки/ресеты VDMA**: все пять `*aclk` и `axi_resetn` — на
  `xdma_0_axi_aclk` / `xdma_0_axi_aresetn`; SmartConnect S01/S02/S03 — домен
  `aclk3`. ILA с тактированием от `m_axi_mm2s_aclk` пишет — клок живой.
- **Frame sync / genlock**: в IP было `c_use_fsync=1`, `c_use_s2mm_fsync=2`
  (`s2mm_tuser`), `c_include_internal_genlock=1`. Выключено (`0`), пересобрано,
  прошито — **поведение не изменилось**.
- **Адресация**: `vdma_0/Data_MM2S` и `Data_S2MM` видят MIG c0 (2G @ 0x0);
  `0x1000_0000` валиден. Проверено и на 64x64 @ 0x0 — то же самое.
- **Loopback**: `M_AXIS_MM2S -> S_AXIS_S2MM` напрямую (ядро убрано),
  интерфейсная связь есть в сгенерированном `top.v`.
- **Каналы (ILA, netlist insertion, без правки BD)**:
  - `m_axi_mm2s_arready = 1` (SmartConnect готов),
  - `m_axis_mm2s_tready_i = 1` (S2MM готов принимать),
  - **`m_axi_mm2s_arvalid = 0`**, `m_axi_mm2s_rvalid = 0`,
    `m_axis_mm2s_tvalid_i = 0` — VDMA **вообще не начинает читать память**.
- **Внутренний командный поток `U0/s_axis_mm2s_cmd_*`**: `cmd_tvalid` — ровно
  **один такт**, в данных видно `0x0780` (= HSIZE 1920) и бит 23 = 1; после
  этого DataMover не выдаёт ни одного AR.

## Поведение регистров (аномалии)

- CR после сброса = `0x00010082` (TailEn=1, GenlockSrc=1, FRMCNT=1), поле
  FRMCNT (23:16) **не обнуляется** (запись 0 игнорируется), SR зеркалит это
  поле — то есть счётчик кадров в SR здесь не является индикатором прогресса.
- `VSIZE/HSIZE/STRIDE/START` пишутся и читаются корректно.
- Порядок запуска как в драйвере Xilinx (`CR |= RUNSTOP`, **потом** запись
  VSIZE) → мгновенный `SR=0x14011` (Halted + Datamover internal error) на
  **обоих** каналах, при любых размерах кадра (16x16 … 640x480) и адресах.
- Порядок «VSIZE, потом RUNSTOP» → ошибки нет, но и передачи нет
  (`SR=0x00010000` навсегда, `arvalid=0`).

## Вывод

Проблема не в SmartConnect, не в клоках, не в fsync и не в loopback: **VDMA
принимает команду и не выдаёт ни одного AXI-чтения**. Дальше проверять:
1) поля команды DataMover (TYPE/EOF/DSA) и её адрес — снять полные 49 бит
   `s_axis_mm2s_cmd_tdata` и/или `mm2s_*` регистры внутри
   `MM2S_REGISTER_MODULE_I`;
2) конфигурацию IP: `C_M_AXIS_MM2S_TDATA_WIDTH=24` при MM width 64 (24 не
   делит 64) — попробовать 32-битный поток и/или `num_fstores=1`,
   `linebuffer_depth=512`;
3) альтернатива — заменить VDMA на **AXI DMA (simple mode)**: для
   покадрового DMA он проще; но он требует поток 8/16/32/64 бит (24 не
   поддерживается), т.е. ядра придётся перевести на 32 бита (RGBX).

## Командное слово VDMA (ILA на внутренние регистры)

Снято с работающего кристалла (триггер по `s_axis_mm2s_cmd_tvalid`):

| сигнал | значение |
|---|---|
| `reg_module_hsize_reg` | 0x0780 = 1920 ✓ |
| `GEN_NUM_FSTORES_3.reg_module_start_address1_i_reg` | 0x1000_0000 ✓ |
| `reg_module_vsize_reg` | 0x1E0 до старта, 0 в момент команды |
| `s_axis_mm2s_cmd_tdata[15:0]` | 0x0780 (= hsize) |
| `s_axis_mm2s_cmd_tdata[23]` | 1 |
| `s_axis_mm2s_cmd_tdata[48:32]` | 0 |
| `cmd_tvalid` | ровно 1 такт, затем снимается (команда принята) |
| `m_axi_mm2s_arvalid` | 0 |

Вывод: **внутренние регистры и командное слово корректны** (адрес, размер
строки), команда уходит в DataMover и подтверждается, но DataMover не выдаёт
ни одного AR и возвращает internal error. То есть проблема не в
программировании регистров, а в самом блоке DataMover/его конфигурации.

Наиболее вероятный конфигурационный фактор: поток 24 бита при памяти 64 бита
(24 не делит 64). Следующий шаг — пересборка с `C_M_AXIS_MM2S_TDATA_WIDTH=32`
и `C_S_AXIS_S2MM_TDATA_WIDTH=32` (плюс `C_NUM_FSTORES=1`,
`linebuffer_depth=512`), кадры тогда RGBX.

## Проверено после этого (тоже не помогло)

- Поток **32 бита** (`c_m_axis_mm2s_tdata_width`/`c_s_axis_s2mm_tdata_width` = 32),
  `c_num_fstores=1`, `linebuffer_depth=512`, `thresh=64` — пересобрано,
  прошито: `SR=0x14011` на обоих каналах, данных нет.
- **Полностью чистая пересборка** (`accel.gen`/`accel.runs`/`accel.cache`
  удалены) — WNS +0.017, поведение то же.

То есть проблема не в артефактах сборки и не в ширине потока. Команда
корректна, DataMover её принимает и сразу возвращает internal error.
Дальше имеет смысл либо моделирование VDMA отдельным тестбенчем, либо
переход на AXI DMA (simple mode, поток 32 бита).

---

# AXI DMA вместо VDMA (рабочее решение)

VDMA так и не удалось заставить выдавать AXI-чтения (см. выше), поэтому для M0
он заменён на **AXI DMA 7.1 в simple mode**:

- `c_include_sg=0`, `c_micro_dma=0`;
- MM (память) 64 бита, поток **32 бита** (RGBX);
- `c_addr_width=32`;
- `c_sg_length_width=26` — **обязательно**: с дефолтными 14 битами
  максимальная длина трансфера 16383 байта, и всё, что больше, молча
  зависает (`SR=0`, канал «busy» навсегда);
- `M_AXI_MM2S` → `axi_smc/S02_AXI`, `M_AXI_S2MM` → `axi_smc/S03_AXI`,
  `S_AXI_LITE` → `axi_lite/M00_AXI` (адрес 0x0 в user BAR, 64K);
- оба мастер-пространства (`Data_MM2S`/`Data_S2MM`) должны иметь сегмент
  MIG c0 (0x0, 2G) — иначе адрес не декодируется;
- `M_AXIS_MM2S` → `S_AXIS_S2MM` (заглушка вместо ядра).

## Регистры и последовательность (simple mode)

| канал | CR | SR | адрес | длина |
|---|---|---|---|---|
| MM2S (TX) | 0x00 | 0x04 | 0x18 (+MSB 0x1C) | 0x28 |
| S2MM (RX) | 0x30 | 0x34 | 0x48 (+MSB 0x4C) | 0x58 |

1. `CR=4` на оба канала, дождаться self-clear.
2. `SR=0x7FFFFFFF` (W1C) на оба.
3. Адреса: `SRC_ADDR`, `DST_ADDR`.
4. `RX CR=1`, `RX LENGTH=n`, затем `TX CR=1`, `TX LENGTH=n`
   (запись LENGTH и запускает трансфер; читается как 0).
5. Опрос: `SR` бит 1 (idle) и бит 9 (IOC); ошибки — биты 0x770.

## Измерено (host `conv_demo --dma --verify`)

| кадр | up | down | процесс | итог |
|---|---|---|---|---|
| 640x480 BGR | 0.8 мс | 1.3 мс | 2.1 мс | 114 fps |
| 1280x720 | 2.4 мс | 3.7 мс | 6.1 мс | 63 fps |
| 1920x1080 | 5.4 мс | 8.2 мс | 13.6 мс | 30 fps |
| 3840x2160 | 21.4 мс | 31.3 мс | 52.7 мс | 7.6 fps |

Loopback проверен бит-в-бит на всех размерах (включая 4K, 33 МБ за трансфер).

## Следующий шаг

Вставить ядро между `M_AXIS_MM2S` и `S_AXIS_S2MM`. Ядра `passthrough`/`conv2d`
сейчас собраны под 24-битный AXIS — их нужно пересобрать под **32 бита**
(RGBX), либо поставить преобразователь 32→24→32.

---

# Ядро conv2d 5x5 (M1)

- `hls/kernels/conv2d/conv2d.cpp` переписано под **32-битный** поток (RGBX) и
  `XF_8UC4`; ядро `xf::cv::filter2D<XF_BORDER_REPLICATE,5,5>` с
  суммой коэффициентов 256 и `shift=8` (единичное усиление, без переполнения).
- `xf::cv::AXIvideo2xfMat`/`xfMat2AXIvideo` использовать нельзя: у AXI DMA нет
  TUSER (SOF), а TLAST только в конце трансфера. Поэтому свои `load_frame` /
  `store_frame` (кадр задаётся `rows*cols` из AXI-Lite).
- Регистры `s_axi_control`: `0x00` CTRL (bit0 ap_start, bit1 ap_done),
  `0x10` rows, `0x18` cols, `0x20` shift. Последовательность: записать
  rows/cols/shift → `ap_start=1` → запустить DMA → дождаться DMA и `ap_done`.
- Число тактов: II=1 на всех циклах (load/store/filter), оценка HLS ~179 МГц;
  в Vivado проект закрылся с WNS +0.015.

## Важно про адреса

**user BAR = 64 КБ** (`Region 0: size=64K`). Оба устройства должны лежать
внутри: AXI DMA — `0x0000` (4 КБ), ядро — `0x1000` (4 КБ). Попытка посадить
ядро на `0x10000` даёт выход за пределы отображённого BAR и SIGSEGV в
пользовательском процессе (и регистры ядра физически недоступны).

## Важно про прошивку

После `flash.tcl` (программирование флеша + `boot_hw_device`) плата может
остаться с `DONE=0`: `CRC_ERROR=0`, `INIT_COMPLETE=1`, `PLL/DCI ok`, но
`END_OF_STARTUP=0`. Лечится **холодным стартом по питанию** — после него
загрузка проходит. JTAG-программирование такого образа принципиально не
работает: в XDC оставлен `StartUpClk = Cclk` (нужен для BPI), поэтому
`program_hw_devices` даёт `End of startup status: LOW`.
