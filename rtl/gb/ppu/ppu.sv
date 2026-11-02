`default_nettype none

module ppu (
    input  logic       clk,
    input  logic       rst_n,

    input  logic [7:0] vram_din,
    input  logic [7:0] oam_din,

    output logic [12:0] vram_addr,
    output logic [7:0]  oam_addr,
    output logic [1:0]  pixel_color,
    output logic         pixel_valid,
    output logic         hsync,
    output logic         vsync,
    output logic         stat_intr,
    output logic         vblank_intr
);

    // TODO: Implement PPU scanline FSM and pixel FIFO

    assign vram_addr   = 13'h0000;
    assign oam_addr    = 8'h00;
    assign pixel_color = 2'b00;
    assign pixel_valid = 1'b0;
    assign hsync       = 1'b0;
    assign vsync        = 1'b0;
    assign stat_intr    = 1'b0;
    assign vblank_intr  = 1'b0;

endmodule

`default_nettype wire
