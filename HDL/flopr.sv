module flopr(
    input logic clk,
    input logic reset,
    input logic[31:0] d,

    output logic[31:0] q = 0
);

    always_ff @(posedge clk, posedge reset) begin
        if(reset)
            q <= 0;
        else
            q <= d;
    end

endmodule