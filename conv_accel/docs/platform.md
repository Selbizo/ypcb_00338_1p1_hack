# Платформа: факты, цифры, грабли

## Плата

| | |
|---|---|
| Карта | YPCB-00338-1P1 (DU-PCB-001-003), Kintex-7 **XC7K480T-FFG1156-2** |
| PCIe | x8 Gen2 (7-series hard block), слот у пользователя: x4 Gen3 (чипсетный) |
| Флеш | Micron **MT28GU512AAA** (512 Мбит, x16, 1.8 В), BPI |
| DDR3 | 2 канала, MIG с **ECC (72 бит)**, AXI 512 бит |
| Питание | только из слота PCIe, лимит слота ~26 Вт |

## Линк и DMA (измерено)

```
LnkCap: 5 GT/s, x8        (что умеет ПЛИС)
LnkSta: 5 GT/s, x4        (что даёт слот)
```

Тест `host/tests/dma_pattern.c` (паттерн → DDR3 → обратно, сверка):

| Размер | H2C | C2H |
|---|---|---|
| 1 МБ | 1414 МБ/с | 1446 МБ/с |
| 24 МБ | 1511 МБ/с | 1532 МБ/с |
| 64 МБ | 1532 МБ/с | 1541 МБ/с |

Для 4K30 RGB888 (25 МБ кадр) это ~33 мс на кадр в обе стороны — то есть
**4K30 упирается в линк** (как и планировали).

## Карта адресов (важно для DMA)

Драйвер `xdma` использует **смещение в `pwrite/pread` как AXI-адрес карты**.
Пространство мастера `xdma_0/M_AXI` (см. address editor в BD):

| AXI-адрес | Что |
|---|---|
| `0x0000_0000` | DDR3 контроллер 0 (до 2 ГБ) |
| `0x8000_0000` | DDR3 контроллер 1 (до 2 ГБ) |
| `0x6000_0000` | BPI-флеш (AXI EMC) — **исключён** из пространства XDMA |

Пример: `pwrite(/dev/xdma0_h2c_0, buf, len, 0x0)` пишет в DDR3 c0.

## Загрузка из флеша

Требуется **синхронный BPI** — плата разведена под него (используются ADV# и CLK
флеша). В `hw/accel.srcs/constrs_1/new/pcie_port.xdc`:

```tcl
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE   33    [current_design]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
```

С дефолтным асинхронным BPI флеш не читается (`BOOT_STATUS.WRAP_ERROR`).
С `CONFIGRATE 3` (дефолт) конфигурация занимает ~52 с, с 33 — ~5 с.

Прошивка флеша в Vivado требует служебный «indirect programming» битстрим
`bpi_xc7k480t_*.bit`; он лежит в
`<Vivado>/data/xicom/cfgmem/bitfile.zip`. В этой установке он был **не
распакован** (папка только для root) — файлы извлечены в
`<Vivado>/data/xicom/cfgmem/bitfile/`. При переустановке Vivado повторить.

## Грабли

### 1. После переконфигурации ПЛИС «пропадают» BAR'ы

`boot_hw_device` / JTAG-программирование сбрасывают PCIe config-space, BAR'ы
обнуляются, а ядро держит старые значения. Симптом: `lspci` показывает регион
`[virtual]`, драйвер падает с `Failed to detect XDMA config BAR`.

Лечение (без перезагрузки):

```bash
sudo sh -c 'echo 1 > /sys/bus/pci/devices/0000:04:00.0/remove'
sudo sh -c 'echo 1 > /sys/bus/pci/rescan'
sudo modprobe -r xdma && sudo modprobe xdma
```

При холодной загрузке проблемы нет: ПЛИС успевает сконфигурироваться до
перечисления шины BIOS'ом.

### 2. `End of startup status: LOW` при JTAG

Битстрим для флеша использует `STARTUPCLK = Cclk`. По JTAG CCLK не тактируется,
поэтому startup не завершается. Варианты:

- для JTAG-отладки собрать с `set_property BITSTREAM.STARTUP.STARTUPCLK JtagClk [current_design]`;
- либо прошивать с `-disable_eos_check` (но дизайн при этом не запустится — startup не пройдёт).

### 3. Тайминг

Последняя сборка: **WNS +0.011 нс** (0 нарушений). Запас почти нулевой —
после добавления логики проверять тайминг и при необходимости менять стратегию
реализации/частоты.

### 4. Ресурсы (после этапа 0)

| | занято | всего |
|---|---|---|
| LUT | 60 011 (20%) | 298 600 |
| FF | 62 109 (10%) | 597 200 |
| BRAM | 154.5 (16%) | 955 |
| DSP | 3 (0.16%) | 1920 |

Запас большой, кроме тайминга и питания (лимит слота).

## Воспроизводимость

- Проект: `hw/accel.xpr` (BD `top` скопирован из вендорского примера,
  `BlockSrcs`, отдельный OOC-ран `top_synth_1`).
- Изменение против вендорского примера: XDMA `PL_LINK_CAP_MAX_LINK_WIDTH = X8`,
  `PL_LINK_CAP_MAX_LINK_SPEED = 5.0_GT/s` + настройки загрузки в XDC.
- Vitis Vision 2024.2 (только `vision/L1/include`), фиксированная ревизия —
  `scripts/fetch_vision.sh`.
