module extendImm(
    input logic[1:0] imm_src,
    input logic[31:7] instr,

    output logic[31:0] imm_ext
);

    assign imm_ext = 
    (imm_src == 2'b00) ? {{20{instr[31]}}, instr[31:20]} :                                       // I type
    (imm_src == 2'b01) ? {{20{instr[31]}}, instr[31:25], instr[11:7]} :                          // S type
    (imm_src == 2'b10) ? {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0} :          // B type
    (imm_src == 2'b11) ? {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0} :        // J type
    32'b0;

endmodule