module alu(
    input logic[31:0] a,b,
    input logic[2:0] mode,
    output logic[31:0] result,
    output logic is_zero
);

    assign result = (mode == 3'b000) ? (a + b) :
                (mode == 3'b001) ? (a - b) :
                (mode == 3'b010) ? (a & b) :
                (mode == 3'b011) ? (a | b) :
                (mode == 3'b101) ? (($signed(a) < $signed(b)) ? 32'd1 : 32'd0)
                : 32'b0;
    
    assign is_zero = (result == 32'b0);

endmodule