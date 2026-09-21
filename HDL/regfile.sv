module regfile(
    input logic clk,
    input logic[4:0] a1, a2,
    input logic we,
    input logic[4:0] a3,
    input logic[31:0] wd,

    output logic[31:0] reg1, reg2
);

    logic[31:0] regs[31:0];

    assign reg1 = (a1 != 0) ? regs[a1] : 0;
    assign reg2 = (a2 != 0) ? regs[a2] : 0;

    always_ff @(posedge clk)
        if(we)
            regs[a3] <= wd;

endmodule