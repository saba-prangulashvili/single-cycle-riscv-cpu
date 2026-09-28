module dispMem(
    input logic clk,

    input logic we,
    input logic[11:0] wadr,
    input logic[7:0] wdata,

    input logic re,
    input logic[11:0] radr,
    output logic[7:0] rdata
);

    logic[7:0] mem[0:2399];
    integer i;
    initial begin
        for (i = 0; i < 2400; i = i + 1)
            mem[i] = 8'h20;
    end

    always @(posedge clk) begin
        if (we)
            mem[wadr] <= wdata;
    end

    always @(posedge clk) begin
        if (re)
            rdata <= mem[radr];
    end
endmodule