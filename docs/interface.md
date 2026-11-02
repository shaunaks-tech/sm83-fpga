# ESP32 <-> FPGA SPI Interface

**This document is the contract.** Any change to framing, the register map, or pinout
updates this file in the same change, on both sides (`firmware/main/fpga_link.c` and
`rtl/link/`).

Status: DRAFT — nothing below is decided until marked.

## Physical

- ESP32 = SPI master, FPGA = SPI slave.
- Signals: SCLK, MOSI, MISO, CS_n, IRQ (FPGA -> ESP32), FPGA_RESET_n (ESP32 -> FPGA).
- SPI mode: TODO (CPOL/CPAL)
- Max clock: TODO
- Pin assignments: see `pinout.md`.

## Framing

`[cmd/addr byte][len][payload...]`

- TODO: read/write bit position, address width, max `len`, burst semantics, byte order.

## Register map

| Addr | Name | R/W | Width | Description |
|---|---|---|---|---|
| TODO | `CTRL` | RW | | run / pause / reset |
| TODO | `JOYPAD` | RW | 8 | button state, synchronized into GB clock domain |
| TODO | `MODE` | RW | | HUD / GAME / CALL_PROMPT / IN_CALL |
| TODO | `STATUS` | R | | ROM loaded, error flags, etc. |
| TODO | `OVERLAY_WR` | W | burst | write into overlay buffer |
| TODO | `ROM_WR` | W | burst | load ROM into flash/RAM |
| TODO | `DBG_*` | R | | PC/registers readback for mode-transition test |

## IRQ

- Asserted on: ROM load done, error. TODO: active level, clear mechanism.

## Overlay buffer format

- TODO: dimensions, pixel format, addressing.
