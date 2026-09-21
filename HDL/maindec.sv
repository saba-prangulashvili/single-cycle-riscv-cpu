module maindec(
    input logic[6:0] op,
    
    output logic reg_we,
    output logic[1:0] imm_src,
    output logic alu_src,
    output logic mem_we,
    output logic[1:0] result_src,
    output logic branch,
    output logic[1:0] alu_op,
    output logic jump,
    output logic jalr
);

    
    logic[11:0] ctrl;
    assign {reg_we, imm_src, alu_src, mem_we, result_src, branch, alu_op, jump, jalr} = ctrl;

    assign ctrl =
        (op == 7'b0000011) ? 12'b1_00_1_0_01_0_00_0_0 :       // lw
        (op == 7'b0100011) ? 12'b0_01_1_1_00_0_00_0_0 :       // sw
        (op == 7'b0110011) ? 12'b1_00_0_0_00_0_10_0_0 :       // add, sub, and, or, slt
        (op == 7'b1100011) ? 12'b0_10_0_0_00_1_01_0_0 :       // beq
        (op == 7'b0010011) ? 12'b1_00_1_0_00_0_10_0_0 :       // addi
        (op == 7'b1101111) ? 12'b1_11_0_0_10_0_00_1_0 :       // jal
        (op == 7'b1100111) ? 12'b1_00_1_0_10_0_00_0_1 :       // jar
        12'b0;

endmodule