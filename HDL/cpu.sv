module cpu(
    input logic reset,
    input logic clk,
    input logic[31:0] instr,
    input logic[31:0] mem_data,

    output logic mem_we,
    output logic[31:0] reg2,
    output logic[31:0] alu_result,
    output logic[31:0] pc
);

    //----------------------------------------
    logic reg_we, alu_src, branch, jump, jalr;
    logic[1:0] imm_src, result_src, alu_op;
    maindec md(
        .op (instr[6:0]),

        .reg_we(reg_we),
        .imm_src(imm_src),
        .alu_src(alu_src),
        .mem_we(mem_we),
        .result_src(result_src),
        .branch(branch),
        .alu_op(alu_op),
        .jump(jump),
        .jalr(jalr)
    );

    //----------------------------------------
    logic alu_zero;
    logic pc_src = (branch & alu_zero) | jump;

    //----------------------------------------
    logic[2:0] alu_mode;
    aludec ad(
        .alu_op(alu_op),
        .funct3(instr[14:12]),
        .funct7b5(instr[30]),
        .opcodeb5(instr[5]),

        .alu_mode(alu_mode)
    );

    //----------------------------------------
    datapath dp (
        .clk(clk),
        .reset(reset),
        .instr(instr),
        .mem_data(mem_data),

        .reg_we(reg_we),
        .imm_src(imm_src),
        .alu_src(alu_src),
        .result_src(result_src),
        .jalr(jalr),
        .pc_src(pc_src),

        .alu_mode(alu_mode),

        .reg2(reg2),
        .alu_result(alu_result),
        .alu_zero(alu_zero),
        .pc(pc)
    );

endmodule