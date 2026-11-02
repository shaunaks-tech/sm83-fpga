# Architecture

## Decisions log

Record each open decision from `CLAUDE.md` here once resolved, with date and reason.

| Decision | Choice | Date | Reason |
|---|---|---|---|
| Game Boy target | DMG first (GBC possibly later) | 2026-10-31 | Simplest path; get cpu_instrs/dmg-acid2 passing before adding CGB features |
| FPGA board / part | TODO | | |
| Color display part + interface | TODO | | |
| Calls: HFP vs ANCS | TODO | | |
| Gameplay input | TODO | | |
| SSD1306 kept or retired | TODO | | |

## Block diagram

TODO

## Clocking

- Single master clock; GB rate via clock enable. No derived clocks in fabric.

## Resource budget

TODO: LUTs, block RAM (VRAM, WRAM, line buffer, overlay buffer), after board is chosen.

## Gesture model

TODO: tensor arena size, model size, accuracy (also documented in `gesture_task.c`).
