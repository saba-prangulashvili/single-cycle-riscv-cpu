module mux2(
    input logic[31:0] d0,
    input logic[31:0] d1,
    input logic s,

    output logic[31:0] y
);
    assign y = s ? d1 : d0;
endmodule

//---

module mux3(
    input logic[31:0] d0,
    input logic[31:0] d1,
    input logic[31:0] d2,
    input logic[1:0] s,

    output logic[31:0] y
);
    assign y = 
        (s == 2'b00) ? d0 :
        (s == 2'b01) ? d1 :
        (s == 2'b10) ? d2 :
        32'b0;
endmodule