module imem(
    input logic[31:0] adr,
    output logic[31:0] data
);
    logic[31:0] mem[0:1023];
    initial $readmemh("main.txt",mem);
    assign data = mem[adr[31:2]];
endmodule