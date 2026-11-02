`default_nettype none

module sm83_cpu (
    input  logic       clk,
    input  logic       rst_n,

    input  logic [7:0] din,
    input  logic [4:0] intr_req,

    output logic [15:0] addr,
    output logic [7:0]  dout,
    output logic        wr_en,
    output logic        rd_en,
    output logic        m_cycle_pulse,
    output logic [4:0]  intr_ack
);

    // Implement SM83 registers, ALU, and M-cycle FSM

    assign addr          = 16'h0000;
    assign dout           = 8'h00;
    assign wr_en          = 1'b0;
    assign rd_en           = 1'b0;
    assign m_cycle_pulse  = 1'b0;
    assign intr_ack       = 5'b00000;

    // Registers
    logic [7:0] A, F, B, C, D, E, H, L;
    logic [15:0] PC, SP;


    // Set register reset behavior
    always_ff @ (posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        A <= '0;
        B <= '0;
        C <= '0;
        F <= '0;
        C <= '0;
        D <= '0;
        E <= '0;
        H <= '0;
        L <= '0;
        PC <= '0;
        SP <= '0;
     end
    end


endmodule

`default_nettype wire
