`default_nettype none

module sm83_alu (
    input logic [7:0] a,
    input logic [7:0] b,
    input logic [3:0] op,
    input logic [3:0] flags_in,
    output logic [7:0] result,
    output logic [3:0] flags_out
);


    typedef enum logic [3:0] {
        ALU_ADD = 4'b0000,
        ALU_ADC = 4'b0001,
        ALU_SUB = 4'b0010,
        ALU_SBC = 4'b0011,
        ALU_AND = 4'b0100,
        ALU_XOR = 4'b0101,
        ALU_OR  = 4'b0110,
        ALU_CP  = 4'b0111,
        ALU_INC = 4'b1000,
        ALU_DEC = 4'b1001
    } alu_op_t;

    logic carry_in;
    assign carry_in = flags_in[0];

    logic cin;
    assign cin = carry_in & ((op == ALU_ADC) | (op == ALU_SBC));

    logic [8:0] sum_full, diff_full;
    logic [4:0] sum_lo, diff_lo;
    assign sum_full  = {1'b0, a}       + {1'b0, b}       + {8'b0, cin};
    assign sum_lo    = {1'b0, a[3:0]}  + {1'b0, b[3:0]}  + {4'b0, cin};
    assign diff_full = {1'b0, a}       - {1'b0, b}       - {8'b0, cin};
    assign diff_lo   = {1'b0, a[3:0]}  - {1'b0, b[3:0]}  - {4'b0, cin};

    always_comb begin
        result    = 8'h00;
        flags_out = flags_in;
        case (op)
            ALU_ADD,
            ALU_ADC: begin
                result    = sum_full[7:0];
                flags_out = {1'b0, 1'b0, sum_lo[4], sum_full[8]};
            end
            ALU_SUB,
            ALU_SBC,
            ALU_CP: begin
                result    = diff_full[7:0];
                flags_out = {1'b0, 1'b1, diff_lo[4], diff_full[8]};
            end
            ALU_AND: begin
                result    = a & b;
                flags_out = {1'b0, 1'b0, 1'b1, 1'b0};
            end
            ALU_XOR: begin
                result    = a ^ b;
                flags_out = 4'b0000;
            end
            ALU_OR: begin
                result    = a | b;
                flags_out = 4'b0000;
            end
            ALU_INC: begin
                result    = a + 8'd1;
                flags_out = {1'b0, 1'b0, (a[3:0] == 4'hF), flags_in[0]};
            end
            ALU_DEC: begin
                result    = a - 8'd1;
                flags_out = {1'b0, 1'b1, (a[3:0] == 4'h0), flags_in[0]};
            end
            default: ;
        endcase

        if (op <= ALU_DEC) flags_out[3] = (result == 8'h00);
    end

endmodule
`default_nettype wire
