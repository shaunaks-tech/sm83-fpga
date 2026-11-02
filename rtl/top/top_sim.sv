`default_nettype none

module top_sim (
    input  logic       clk,
    input  logic       rst_n,

    output logic [7:0] serial_char,
    output logic        serial_valid,
    output logic [1:0]  pixel_color,
    output logic         pixel_valid,
    output logic         frame_sync
);

    // CPU <-> MMU bus
    logic [15:0] cpu_addr;
    logic [7:0]  cpu_dout;
    logic [7:0]  cpu_din;
    logic        cpu_wr_en;
    logic        cpu_rd_en;
    logic        cpu_m_cycle_pulse;
    logic [4:0]  intr_req;
    logic [4:0]  intr_ack;

    // PPU <-> MMU VRAM/OAM ports
    logic [12:0] vram_addr;
    logic [7:0]  vram_dout;
    logic [7:0]  oam_addr;
    logic [7:0]  oam_dout;
    logic        ppu_hsync;
    logic        ppu_vsync;
    logic        ppu_stat_intr;
    logic        ppu_vblank_intr;

    // APU register bus (shares CPU bus, no arbitration modeled yet)
    logic [15:0] apu_audio_out;

    assign intr_req = {3'b000, ppu_stat_intr, ppu_vblank_intr};

    sm83_cpu u_cpu (
        .clk           (clk),
        .rst_n         (rst_n),
        .din           (cpu_din),
        .intr_req      (intr_req),
        .addr          (cpu_addr),
        .dout          (cpu_dout),
        .wr_en         (cpu_wr_en),
        .rd_en         (cpu_rd_en),
        .m_cycle_pulse (cpu_m_cycle_pulse),
        .intr_ack      (intr_ack)
    );

    mmu u_mmu (
        .clk          (clk),
        .rst_n        (rst_n),
        .addr         (cpu_addr),
        .din          (cpu_dout),
        .wr_en        (cpu_wr_en),
        .rd_en        (cpu_rd_en),
        .cpu_din      (cpu_din),
        .vram_addr    (vram_addr),
        .vram_dout    (vram_dout),
        .oam_addr     (oam_addr),
        .oam_dout     (oam_dout),
        .serial_char  (serial_char),
        .serial_valid (serial_valid)
    );

    ppu u_ppu (
        .clk         (clk),
        .rst_n       (rst_n),
        .vram_din    (vram_dout),
        .oam_din     (oam_dout),
        .vram_addr   (vram_addr),
        .oam_addr    (oam_addr),
        .pixel_color (pixel_color),
        .pixel_valid (pixel_valid),
        .hsync       (ppu_hsync),
        .vsync       (ppu_vsync),
        .stat_intr   (ppu_stat_intr),
        .vblank_intr (ppu_vblank_intr)
    );

    apu u_apu (
        .clk       (clk),
        .rst_n     (rst_n),
        .addr      (cpu_addr),
        .din       (cpu_dout),
        .wr_en     (cpu_wr_en),
        .rd_en     (cpu_rd_en),
        .audio_out (apu_audio_out)
    );

    assign frame_sync = ppu_vsync;

endmodule

`default_nettype wire
