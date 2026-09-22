module top(
        input  logic        clk,
        input  logic [1:0]  KEY
);

    logic rst, reset;
    always_ff @(posedge clk) begin
        rst <= ~KEY[0];
        reset <= rst;
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
    cpu cpu(
        .clk (clk),
        .reset (reset),
        .instr (instr),
        .mem_data (dmem_data),

        .pc (pc),
        .mem_we (mem_we),
        .reg2 (reg2),
        .alu_result (alu_result)
    );

    logic[31:0] dmem_data;
    dmem dmem(
        .clk (clk),
        .adr (alu_result),
        .we (mem_we),
        .wd (reg2),

        .rd (dmem_data)
    );

endmodule