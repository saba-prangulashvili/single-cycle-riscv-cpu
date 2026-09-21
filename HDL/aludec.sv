module aludec(
    input logic[1:0] alu_op,
    input logic[2:0] funct3,
    input logic funct7b5,
    input logic opcodeb5,

    output logic[2:0] alu_mode
);

    assign alu_mode = 
    (alu_op == 2'b00)  ? 3'b000 :     // add
    (alu_op == 2'b01)  ? 3'b001 :     // sub
    (funct3 == 3'b000) ? (funct7b5 & opcodeb5 ? 3'b001 : 3'b000) : //sub or add/addi           
    (funct3 == 3'b010) ? 3'b101 :     // slt, slti
    (funct3 == 3'b110) ? 3'b011 :     // or, ori 
    (funct3 == 3'b111) ? 3'b010 :     // and, andi
    3'b0;

endmodule