module mem_decoder(
    input logic[31:0] adr,
    input logic write_en,
    input logic read_en,

    input logic key_ready,
    input logic[7:0] key,

    input logic[31:0] dmem_data,

    output logic dmem_we,
    output logic disp_we,
    output logic keyboard_re,

    output[31:0] mem_data
);

    assign dmem_we = (write_en & (adr < 32'd256));
    assign disp_we = (write_en & (adr >= 32'd256));
    assign keyboard_re = (read_en & (adr == 32'd244));

    assign mem_data = 
        (adr == 32'd248) ? {31'b0, key_ready} :
        (adr == 32'd244) ? {24'b0, key} :
        (adr < 32'd256) ? dmem_data :
        32'b0;

endmodule