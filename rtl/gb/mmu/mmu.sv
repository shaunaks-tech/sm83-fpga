`default_nettype none

module mmu (
    input  logic        clk,
    input  logic        rst_n,

    // CPU bus
    input  logic [15:0] addr,
    input  logic [7:0]  din,
    input  logic         wr_en,
    input  logic         rd_en,
    output logic [7:0]  cpu_din,

    // External peripherals (PPU VRAM/OAM ports)
    input  logic [12:0] vram_addr,
    output logic [7:0]  vram_dout,
    input  logic [7:0]  oam_addr,
    output logic [7:0]  oam_dout,

    // Serial debug port
    output logic [7:0]  serial_char,
    output logic        serial_valid
);

    // TODO: Implement MMU routing and banking
    //   $0000-$7FFF ROM
    //   $8000-$9FFF VRAM
    //   $A000-$BFFF Cartridge RAM
    //   $C000-$DFFF WRAM
    //   $FE00-$FE9F OAM
    //   $FF01-$FF02 Serial (SB/SC)
    //   $FF80-$FFFE HRAM

    assign cpu_din      = 8'h00;
    assign vram_dout    = 8'h00;
    assign oam_dout     = 8'h00;
    assign serial_char  = 8'h00;
    assign serial_valid = 1'b0;

endmodule

`default_nettype wire
