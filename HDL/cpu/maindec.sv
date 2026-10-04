module maindec(
    input logic[6:0] op,
    
    output logic reg_we,
    output logic[1:0] imm_src,
    output logic alu_src,
    output logic mem_we,
    output logic mem_re,
    output logic[1:0] result_src,
    output logic branch,
    output logic[1:0] alu_op,
    output logic jump,
    output logic jalr
);

    
 logic[12:0] ctrl;
    assign {reg_we, imm_src, alu_src, mem_we, mem_re, result_src, branch, alu_op, jump, jalr} = ctrl;

    assign ctrl =
        (op == 7'b0000011) ? 13'b1_00_1_0_1_01_0_00_0_0 :       // lw
        (op == 7'b0100011) ? 13'b0_01_1_1_0_00_0_00_0_0 :       // sw
        (op == 7'b0110011) ? 13'b1_00_0_0_0_00_0_10_0_0 :       // add, sub, and, or, slt
        (op == 7'b1100011) ? 13'b0_10_0_0_0_00_1_01_0_0 :       // beq
        (op == 7'b0010011) ? 13'b1_00_1_0_0_00_0_10_0_0 :       // addi
        (op == 7'b1101111) ? 13'b1_11_0_0_0_10_0_00_1_0 :       // jal
        (op == 7'b1100111) ? 13'b1_00_1_0_0_10_0_00_0_1 :       // jalr
        13'b0;

endmodule