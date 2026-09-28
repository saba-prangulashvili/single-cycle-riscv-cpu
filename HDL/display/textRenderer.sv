module textRenderer(
    input logic clk,
    input logic pixel_en,
    input logic[9:0] h_cnt,
    input logic[9:0] v_cnt,
    input logic[7:0] ascii_code,

    output logic[11:0] char_adr,
    output logic pixel_on
);
    logic [6:0] col;
    assign col = h_cnt[9:3];
    logic [5:0] row;
    assign row = v_cnt[9:4];
    assign char_adr = (row * 80) + col;

    logic [3:0] ascii_row;
    assign ascii_row = v_cnt[3:0]; //v_cnt % 16
    logic[7:0]  font_row_pixels;
    fontMem fm(
        .clk(clk),
        .re(pixel_en),
        .ascii_code(ascii_code),
        .ascii_row(ascii_row),

        .row_pixels(font_row_pixels)
    );

    logic [2:0] sub_col_0;
    assign sub_col_0 = h_cnt[2:0];
    logic[2:0] sub_col_1 = 3'b0;
    logic[2:0] sub_col = 3'b0;

    always @(posedge clk) begin
        if (pixel_en) begin
            sub_col_1 <= sub_col_0;
            sub_col <= sub_col_1;
        end
    end

    assign pixel_on = font_row_pixels[~sub_col];

endmodule