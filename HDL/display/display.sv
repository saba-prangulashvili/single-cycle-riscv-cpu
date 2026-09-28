module display(
    input logic clk_50,

    input logic ext_we,
    input logic[11:0] ext_wadr,
    input logic[7:0]  ext_wdata,

    output logic[3:0] VGA_R,
    output logic[3:0] VGA_G,
    output logic[3:0] VGA_B,

    output logic VGA_HS = 1'b1,
    output logic VGA_VS = 1'b1
);

    logic clk_25 = 1'b0;
    always_ff @(posedge clk_50) begin
        clk_25 <= ~clk_25;
    end

    localparam[9:0] H_LAST_PIXEL = 10'd799;
    localparam[9:0] V_LAST_PIXEL = 10'd524;

    localparam[9:0] H_VISIBLE_PIXELS = 10'd640;     // 8*80
    localparam[9:0] V_VISIBLE_PIXELS = 10'd480;     // 16*30

    localparam[9:0] H_SYNC_BEGIN = 10'd656;
    localparam[9:0] H_SYNC_END = 10'd752;
    localparam[9:0] V_SYNC_BEGIN = 10'd490;
    localparam[9:0] V_SYNC_END = 10'd492;

    localparam[3:0] COLOR_ON = 4'hF;
    localparam[3:0] COLOR_OFF = 4'h0;

    logic[9:0] h_cnt = 10'b0;
    logic[9:0] v_cnt = 10'b0;
    always_ff @(posedge clk_50) begin
        if(clk_25) begin
            if(h_cnt == H_LAST_PIXEL) begin
                h_cnt <= 10'b0;
                if(v_cnt == V_LAST_PIXEL) 
                    v_cnt <= 10'b0;
                else
                    v_cnt <= v_cnt + 1'b1;
            end
            else
                h_cnt <= h_cnt + 1'b1;
        end
    end

    logic h_sync_0, v_sync_0;
    assign h_sync_0 = ~((h_cnt >= H_SYNC_BEGIN) && (h_cnt < H_SYNC_END));
    assign v_sync_0 = ~((v_cnt >= V_SYNC_BEGIN) && (v_cnt < V_SYNC_END));
    logic h_sync_1 = 1'b1;
    logic v_sync_1 = 1'b1;
    always_ff @(posedge clk_50) begin
        if (clk_25) begin
            h_sync_1 <= h_sync_0;
            v_sync_1 <= v_sync_0;
            VGA_HS   <= h_sync_1;
            VGA_VS   <= v_sync_1;
        end
    end

    logic[7:0]  ascii_code;
    logic[11:0] char_adr;
    dispMem dm(
        .clk(clk_50),

        .we(ext_we),
        .wadr(ext_wadr),
        .wdata(ext_wdata),

        .radr(char_adr),
        .re(clk_25),

        .rdata(ascii_code)
    );

    
    logic text_pixel_on;
    textRenderer tr(
        .clk(clk_50),
        .pixel_en(clk_25),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .ascii_code(ascii_code),

        .char_adr(char_adr),
        .pixel_on(text_pixel_on)
    );

    logic pixel_visible_0;
    assign pixel_visible_0 = (h_cnt < H_VISIBLE_PIXELS) && (v_cnt < V_VISIBLE_PIXELS);
    logic pixel_visible_1 = 1'b0;
    logic pixel_visible = 1'b0;
        always @(posedge clk_50) begin
        if (clk_25) begin
            pixel_visible_1 <= pixel_visible_0;
            pixel_visible <= pixel_visible_1;
        end
    end

    logic pixel_on;
    assign pixel_on = pixel_visible && text_pixel_on;

    assign VGA_R = (pixel_on) ? COLOR_ON : COLOR_OFF;
    assign VGA_G = (pixel_on) ? COLOR_ON : COLOR_OFF;
    assign VGA_B = (pixel_on) ? COLOR_ON : COLOR_OFF;
endmodule