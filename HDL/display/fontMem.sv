module fontMem(
    input logic clk,
    input logic re,
    input logic[7:0] ascii_code,
    input logic[3:0] ascii_row,     //2^4 = 16

    output logic[7:0] row_pixels
);

    // each character 8x16, 128 characters, 2048 = 128*16
    logic[7:0] mem[0:2047];
    initial begin
        $readmemh("fontMem.mem", mem);
    end 


    logic[10:0] adr;
    assign adr = {ascii_code[6:0], ascii_row};

    always @(posedge clk) begin
        if(re)
            row_pixels <= mem[adr];
    end

endmodule
