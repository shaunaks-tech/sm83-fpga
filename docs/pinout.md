# Pinout

Single source of truth for pin assignments. Firmware mirrors this in
`firmware/main/board.h`; RTL mirrors it in `constraints/`. Never define a pin anywhere else.

## ESP32

| Signal | GPIO | Connects to | Notes |
|---|---|---|---|
| I2C SDA | TODO | MPU-6050 (+ SSD1306) | |
| I2C SCL | TODO | MPU-6050 (+ SSD1306) | |
| SPI SCLK | TODO | FPGA | |
| SPI MOSI | TODO | FPGA | |
| SPI MISO | TODO | FPGA | |
| SPI CS_n | TODO | FPGA | |
| FPGA IRQ | TODO | FPGA | input |
| FPGA RESET_n | TODO | FPGA | output |
| I2S BCLK/WS/DOUT/DIN | TODO | audio codec | HFP only |

## FPGA

TODO: depends on board choice.

| Signal | Pin | Notes |
|---|---|---|
