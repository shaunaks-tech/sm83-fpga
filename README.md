# sm83-fpga

A Game Boy (DMG) written in SystemVerilog for an FPGA, driving the display of a pair of smart glasses.

- **Game Boy core:** SM83 CPU, timer, PPU, APU, memory map and cartridge mappers. It builds and tests on its own.
- **ESP32 controller:** reads head gestures from an MPU-6050 to answer or decline phone calls, and talks to the FPGA over SPI so a call can pause a game.

## Status

Early. The ALU is written and tested against a reference model. The CPU, MMU, PPU and APU are stubs.

## Layout

```
rtl/gb/       Game Boy core
rtl/video/    Display driver, scaler, overlay
rtl/link/     SPI slave for the ESP32
rtl/lib/      Shared primitives
rtl/top/      Top-level modules
sim/          Verilator and cocotb tests
firmware/     ESP-IDF project
ml/           Gesture model training
docs/         SPI interface, pinout, architecture
roms/test/    Test ROMs only
```

## Build

```
make -C sim/verilator sim
```

## Testing

Blargg `cpu_instrs`, `instr_timing` and `mem_timing`, the mooneye test suite, and `dmg-acid2`.

No commercial ROMs or boot ROM are included.
