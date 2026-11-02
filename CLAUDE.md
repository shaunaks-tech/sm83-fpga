# CLAUDE.md — gameboy_fpga (Smart Glasses + FPGA Game Boy)

This repo combines two projects into one wearable:

1. **Smart glasses controller (ESP32):** head-gesture recognition (MPU-6050 + TFLM) to
   answer/decline phone calls and handle notifications, plus a HUD.
2. **FPGA Game Boy (DMG):** a from-scratch Game Boy implemented in RTL, rendering to the
   glasses display.

The ESP32 is the **system controller**. The FPGA is a **Game Boy coprocessor** that owns
the display pipeline. They talk over SPI.

---

## Golden rules

- **The FPGA Game Boy must stay buildable and testable standalone.** Nothing in `rtl/gb/`
  may depend on the ESP32 being present. Integration logic lives in `rtl/top/` and
  `rtl/link/` only.
- **The ESP32 firmware must work with the FPGA absent or held in reset.** Calls and
  notifications are the priority feature; the game is optional.
- **`docs/interface.md` is the contract.** Any change to the SPI register map, framing,
  or pinout updates that doc *in the same change*, on both sides.
- **No commercial ROMs or Nintendo boot ROM in the repo.** Use test/homebrew ROMs only
  (see Testing). `roms/` is gitignored except `roms/test/`.
- Don't "fix" a failing test ROM by special-casing it. Find the actual timing/logic bug.
- Prefer small, reviewable changes. When touching RTL, run the relevant sim before
  claiming it works.

---

## Hardware

| Part | Role | Notes |
|---|---|---|
| ESP32 (classic, WROOM/WROVER) | System controller | **Must be classic ESP32** if using Bluetooth HFP — ESP32-S3/C3 are BLE-only (see Calls) |
| MPU-6050 | Head-gesture IMU | I2C to ESP32 |
| FPGA board | Game Boy core | **TODO: fill in board + part** (e.g. iCE40UP5K / ECP5) |
| Color display | Glasses display, owned by FPGA | **TODO: part.** Needs ≥160×144. SSD1306 (128×64 mono) is too small for the game |
| SSD1306 OLED | Legacy HUD | Optional; may be retired once the color display carries the HUD |
| Mic + speaker/bone-conduction (I2S) | Call audio | Only needed for HFP audio-on-glasses |
| Input for gameplay | Joypad | BLE gamepad → ESP32, or wired buttons. **Head gestures are not used for gameplay** |
| SPI flash (FPGA side) | ROM storage | Holds the cartridge ROM image |

**Physical layout assumption:** FPGA + battery live in a tethered pocket/belt pack; the
glasses frame carries the display, IMU, and audio. Keep weight/heat on the frame minimal.

Pinouts live in `docs/pinout.md`. Never hardcode a pin in more than one place —
firmware uses `firmware/main/board.h`, RTL uses the constraints file.

---

## Repo layout

```
gameboy_fpga/
├── CLAUDE.md
├── docs/
│   ├── interface.md        # ESP32 <-> FPGA SPI protocol (source of truth)
│   ├── pinout.md
│   └── architecture.md
├── rtl/
│   ├── gb/                 # Standalone Game Boy: cpu/ (SM83), ppu/, apu/, timer/, mmu/, cart/ (MBC1/3/5)
│   ├── video/              # Display driver, scaler, overlay compositor (GB PPU lives in gb/ppu/)
│   ├── link/               # SPI slave + register file for ESP32 control
│   ├── lib/                # Shared primitives (CDC synchronizers, etc.)
│   └── top/                # Top levels: top_sim.sv (Verilator), top_standalone.sv, top_glasses.sv
├── constraints/            # .pcf / .lpf per board
├── sim/
│   ├── verilator/          # Makefile + sim_main.cpp harness, runs ROMs headless, dumps frames to PNG
│   └── cocotb/             # Unit tests per block
├── firmware/               # ESP-IDF project
│   ├── main/
│   │   ├── board.h
│   │   ├── imu_task.c      # MPU-6050 sampling
│   │   ├── gesture_task.c  # TFLM inference
│   │   ├── call_task.c     # HFP / ANCS call control
│   │   ├── fpga_link.c     # SPI master, mirrors docs/interface.md
│   │   └── input_task.c    # Gamepad -> joypad register
│   └── components/
├── ml/
│   ├── data/               # Raw IMU captures (gitignored if large)
│   ├── train.py
│   └── export_tflm.py      # -> firmware/main/model_data.cc
└── roms/test/              # Blargg, mooneye-test-suite, dmg-acid2
```

---

## Architecture

### Ownership
- **FPGA owns the color display.** Video path: GB PPU (160×144, 2bpp) → line buffer →
  palette → overlay compositor → scaler → display driver.
- **ESP32 owns everything else:** gestures, calls, Bluetooth, power, and system mode.

### Overlay
The ESP32 writes a small overlay layer (caller ID, "Answer? nod / shake", battery,
notifications) into an FPGA overlay buffer via SPI. The compositor draws it over the
game or over a blank HUD background. This is how a call interrupts gameplay.

### System modes (ESP32 is the state machine)
- `HUD` — FPGA shows overlay only; GB core held in reset or clock-gated.
- `GAME` — GB core running; joypad fed from ESP32.
- `CALL_PROMPT` — incoming call. **Pause the GB core** (freeze clock enable, don't reset),
  show prompt, enable gesture inference.
- `IN_CALL` — overlay shows call state; game stays paused.
- Returning from a call resumes `GAME` exactly where it paused.

### ESP32 <-> FPGA link (summary — full spec in docs/interface.md)
- ESP32 = SPI master, FPGA = slave. Register-mapped: `[cmd/addr byte][len][payload]`.
- Registers: `CTRL` (run/pause/reset), `JOYPAD` (8 bits), `MODE`, `STATUS`,
  `OVERLAY_WR` (burst into overlay buffer), `ROM_WR` (burst into flash/RAM for ROM load).
- FPGA exposes an `IRQ` line to the ESP32 (e.g. ROM load done, error).
- Joypad register is sampled by the GB core on its own clock — handle CDC with a
  2-FF synchronizer; never feed raw SPI-domain signals into `rtl/gb/`.

---

## Calls (be precise about what's possible)

- **Answering via Bluetooth HFP (Hands-Free Profile):** requires **Bluetooth Classic**
  → classic ESP32 only. ESP-IDF provides an HFP client (HF role). Gives answer/reject/
  hang-up *and* call audio routed to the glasses (needs I2S mic + speaker).
- **Answering via iOS ANCS over BLE:** works on BLE-only chips. Supports accept/decline
  on incoming-call notifications, but **audio stays on the phone**.
- Pick one per hardware revision and record it in `docs/architecture.md`. Don't
  implement both until one works end to end.
- Running BLE (gamepad) + Classic (HFP) concurrently uses ESP32 coexistence — expect
  latency/throughput hits. Test gamepad input latency during an active HFP link.

## Gestures (TinyML)

- Classes: `nod` (answer), `shake` (decline), `idle`, plus any others added later.
  `idle` must dominate the training set — false-positive answers are worse than misses.
- Pipeline: IMU at fixed rate → sliding window → TFLM model → debounce/confidence
  threshold → event to `call_task`.
- Gesture inference only needs to run in `CALL_PROMPT` (and HUD actions if added).
  Disable it in `GAME` to save power and avoid accidental triggers.
- Model changes: retrain in `ml/`, regenerate `model_data.cc` with `export_tflm.py`,
  and report accuracy + confusion matrix + tensor arena size in the commit/PR.
- Keep TFLM tensor arena and model size documented in `firmware/main/gesture_task.c`.

---

## Toolchains & commands

Developed on an Apple Silicon Mac — use the open-source FPGA flow (Vivado/Quartus
don't run natively on macOS ARM).

**TODO: confirm FPGA flow and fill in exact targets.** Expected:

```bash
# RTL
make -C sim/verilator ROM=roms/test/cpu_instrs.gb      # headless run, serial/frame output
make -C sim/cocotb                                     # block-level unit tests
make -C rtl synth BOARD=<board>                        # yosys
make -C rtl pnr   BOARD=<board>                        # nextpnr
make -C rtl prog  BOARD=<board>                        # openFPGALoader

# Firmware (ESP-IDF)
cd firmware && idf.py build
idf.py -p /dev/cu.usbserial-* flash monitor

# ML
cd ml && python train.py && python export_tflm.py
```

Toolchain: oss-cad-suite (Yosys, nextpnr, Verilator, openFPGALoader, iverilog).

---

## Testing

### Game Boy core — required before claiming correctness
- **CPU:** Blargg `cpu_instrs`, `instr_timing`, `mem_timing`.
- **Timing/edge cases:** mooneye-test-suite (acceptance tests for timer, interrupts, PPU).
- **PPU:** `dmg-acid2` — compare frame dump against the reference image.
- The Verilator harness should support: run N frames, dump framebuffer to PNG, capture
  serial port output (Blargg prints results over serial), exit code on pass/fail.
- Boot: skip the boot ROM (initialize post-boot register state) or use an
  open-source boot ROM. Never commit Nintendo's.

### Integration
- Loopback test for the SPI link: write/readback every register.
- Mode-transition test: `GAME → CALL_PROMPT → IN_CALL → GAME` resumes with identical
  CPU state (compare PC/registers via a debug readback register).

### Firmware
- Gesture model evaluated offline on held-out IMU captures before flashing.
- Log gesture confidence over UART during development; keep logging behind a Kconfig flag.

---

## Conventions

- **RTL:** SystemVerilog, synthesizable subset that Yosys accepts. One module per file,
  file name = module name. `snake_case` signals, `_n` suffix for active-low, `_q`/`_d`
  for registered/next-state. Active-high synchronous reset unless the block says otherwise.
  Every clock-domain crossing is commented and uses a synchronizer module from `rtl/lib/`.
- **GB core clocking:** run from a single master clock with clock-enable for the
  4.194304 MHz GB rate. Don't generate derived clocks in fabric. Pause = deassert
  clock enable.
- **Firmware:** C, ESP-IDF style, FreeRTOS tasks communicate via queues/event groups —
  no shared globals across tasks without a mutex. Each task's stack size is justified
  in a comment.
- **Commits:** prefix with area — `rtl/gb:`, `rtl/video:`, `rtl/link:`, `fw:`, `ml:`,
  `docs:`.

---

## Open decisions (ask before assuming)

- FPGA board/part and whether the DMG core fits (LUTs, block RAM for 8 KB VRAM + 8 KB WRAM).
- Color display part, interface (SPI vs parallel), and refresh strategy.
- HFP (classic ESP32, audio on glasses) vs ANCS (BLE-only, audio on phone).
- Gameplay input: BLE gamepad vs wired buttons on the pack.
- Whether the SSD1306 stays or the color display fully replaces it.