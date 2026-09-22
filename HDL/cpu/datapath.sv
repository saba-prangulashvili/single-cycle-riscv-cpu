module datapath(
    input logic clk,
    input logic reset,
    input logic[31:0] instr,
    input logic[31:0] mem_data,

    input logic reg_we,
    input logic[1:0] imm_src,
    input logic alu_src,
    input logic [1:0] result_src,
    input logic jalr,
    input logic pc_src,

    input logic[2:0] alu_mode,

    output logic[31:0] reg2,
    output logic[31:0] alu_result,
    output logic alu_zero,
    output logic[31:0] pc
);

    logic[31:0] imm_ext;
    extendImm exim(
        .imm_src(imm_src),
        .instr(instr[31:7]),

        .imm_ext(imm_ext)
    );

    logic[31:0] reg1;
    regfile rf(
        .clk(clk),
        .a1(instr[19:15]),
        .a2(instr[24:20]),
        .we(reg_we),
        .a3(instr[11:7]),
        .wd(result),

        .reg1(reg1),
        .reg2(reg2)
    );

    logic[31:0] b;
    mux2 m1(
        .d0(reg2),
        .d1(imm_ext),
        .s(alu_src),

        .y(b)
    );

    alu alu(
        .a(reg1),
        .b(b),
        .mode(alu_mode),

        .result(alu_result),
        .is_zero(alu_zero)
    );

    //----------
    flopr pc_reg(
        .clk(clk),
        .reset(reset),
        .d(pc_next),

        .q(pc)
    );

    logic[31:0] pc_plus_4 = pc + 32'd4;

    logic[31:0] pc_target = pc + imm_ext;

    logic[31:0] pc_next;
    mux3 pc_mux(
        .d0(pc_plus_4),
        .d1(pc_target),
        .d2(alu_result),
        .s({jalr, pc_src}),

        .y(pc_next)
    );
    //----------

    logic[31:0] result;
    mux3 result_mux(
        .d0(alu_result),
        .d1(mem_data),
        .d2(pc_plus_4),
        .s(result_src),

        .y(result)
    );


endmodule