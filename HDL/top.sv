module top(
        input  logic        clk,
        input  logic[1:0]  KEY,

        input logic ps2c,
        input logic ps2d,

        output logic[3:0] VGA_R,
        output logic[3:0] VGA_G,
        output logic[3:0] VGA_B,

        output logic VGA_HS,
        output logic VGA_VS
);

    logic rst = 1'b0;
    logic reset = 1'b0;
    always_ff @(posedge clk) begin
        reset <= rst;
        rst <= ~KEY[0];
    end


    logic[31:0] pc;
    logic[31:0] instr;
    imem imem(
        .adr (pc),

        .data (instr)
    );


    logic[31:0] reg2;
    logic[31:0] alu_result;
    logic mem_we;
    logic mem_re;
    cpu cpu(
        .clk (clk),
        .reset (reset),
        .instr (instr),
        .mem_data (mem_data),

        .pc (pc),
        .mem_we (mem_we),
        .mem_re (mem_re),
        .reg2 (reg2),
        .alu_result (alu_result)
    );

    logic[31:0] dmem_data;
    dmem dmem(
        .clk (clk),
        .adr (alu_result),
        .we (dmem_we),
        .wd (reg2),

        .rd (dmem_data)
    );

    logic dmem_we;
    logic disp_we;
    logic keyboard_re;
    logic[31:0] mem_data;
    mem_decoder md(
        .adr(alu_result),
        .write_en(mem_we),
        .read_en(mem_re),

        .key_ready(key_ready),
        .key(key),

        .dmem_data(dmem_data),

        .dmem_we(dmem_we),
        .disp_we(disp_we),
        .keyboard_re(keyboard_re),

        .mem_data(mem_data)
    );

    logic key_ready;
    logic[7:0] key;
    keyboard kb(
        .clk(clk),
        .reset(reset),

        .ps2c(ps2c),
        .ps2d(ps2d),

        .re(keyboard_re),

        .key_ready(key_ready),
        .key(key)
    );

    display disp(
        .clk_50(clk),

        .ext_we(disp_we),
        .ext_wadr(alu_result[11:0] - 12'd256),
        .ext_wdata(reg2[7:0]),

        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),

        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS)
    );

endmodule