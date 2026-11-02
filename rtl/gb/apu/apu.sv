`default_nettype none

module apu (
    input  logic        clk,
    input  logic        rst_n,

    // Register bus
    input  logic [15:0] addr,
    input  logic [7:0]  din,
    input  logic         wr_en,
    input  logic         rd_en,

    output logic [15:0] audio_out
);

    // TODO: Implement APU channel synthesis

    assign audio_out = 16'h0000;

endmodule

`default_nettype wire
