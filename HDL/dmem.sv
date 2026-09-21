module dmem(
    input logic clk,
    input logic[31:0] adr,
    input logic we,
    input logic[31:0] wd,
    output logic[31:0] rd
);

    logic[31:0] mem[0:63];
    assign rd = mem[adr[31:2]];

    always_ff @(posedge clk)
        if(we)
            mem[adr[31:2]] <= wd;
endmodule