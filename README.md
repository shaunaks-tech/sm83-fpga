# sm83-fpga

A from-scratch Game Boy (DMG) in SystemVerilog, built to run on an FPGA and eventually drive the display in a pair of smart glasses.

The project is in two parts. The first is the Game Boy core itself: an SM83 CPU, timer, PPU, APU, memory map, and cartridge mappers. The second is an ESP32 that acts as the system controller for the glasses. It reads head gestures from an MPU-6050 to answer or decline phone calls, and talks to the FPGA over SPI so a call can interrupt a game. The core is meant to build and test on its own, with no ESP32 attached.

I'm writing the RTL myself as a way to learn how the hardware works, so progress is slow on purpose.

## Status

Early. Right now:

- `sm83_alu` is written and passes an exhaustive check of every operation (ADD, ADC, SUB, SBC, AND, XOR, OR, CP, INC, DEC) against a software model.
- The CPU, MMU, PPU, and APU are stubs with the ports defined and nothing behind them.
- The Verilator build runs, but there is no ROM loading yet.
- No hardware has been chosen. The FPGA board and the glasses display are still open.

The first milestone is passing Blargg's `cpu_instrs`. After that come the timer and interrupts, then the PPU and `dmg-acid2`.

Game Boy Color support is not planned for now. I may come back to it once the DMG core is solid.

## Layout

```
rtl/gb/       Game Boy core: cpu, ppu, apu, timer, mmu, cart
rtl/video/    Display driver, scaler, overlay (not started)
rtl/link/     SPI slave for the ESP32 (not started)
rtl/lib/      Shared pieces such as clock-crossing synchronizers
rtl/top/      Top-level modules
sim/          Verilator harness and cocotb tests
firmware/     ESP-IDF project for the ESP32 (not started)
ml/           Head-gesture model training (not started)
docs/         SPI interface, pinout, architecture notes
roms/test/    Test ROMs only
```

`docs/interface.md` is the contract between the FPGA and the ESP32. If the SPI protocol changes, that file changes in the same commit as the code on both sides.

## Building

You need Verilator. I use the open-source toolchain from oss-cad-suite since Vivado and Quartus don't run on Apple Silicon Macs.

Build the simulation:

```
make -C sim/verilator sim
```

Lint the ALU:

```
verilator --lint-only -Wall --top-module sm83_alu rtl/gb/cpu/sm83_alu.sv
```

FPGA synthesis and place-and-route targets aren't set up yet because there's no board.

## Testing plan

The core is only considered correct once it passes real test ROMs, not hand-picked cases:

- Blargg `cpu_instrs`, `instr_timing`, and `mem_timing` for the CPU
- mooneye-test-suite for timers, interrupts, and PPU edge cases
- `dmg-acid2` for the PPU, compared against the reference image

If a test ROM fails, the fix goes in the RTL. I don't special-case ROMs to make them pass.

## ROMs

No commercial ROMs and no Nintendo boot ROM are in this repo, and none ever should be. `roms/` is gitignored except for `roms/test/`, which is for freely distributable test ROMs. The core skips the boot ROM and starts from the post-boot register state.

## References

- Pan Docs, for hardware behavior
- Gekkio's Game Boy Complete Technical Reference, for opcode and timing details
- Blargg's test ROMs, mooneye-test-suite, and dmg-acid2
