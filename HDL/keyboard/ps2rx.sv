module ps2rx(
    input logic clk,
    input logic reset,
    input logic ps2c,
    input logic ps2d,

    output logic rx_done,
    output logic [7:0] rx_data
);
    logic [1:0] ps2c_reg;
    logic ps2c_fall_edge;

    typedef enum logic [1:0] {IDLE, RX, DONE} state;
    state state_reg, state_next;

    logic [3:0] n_reg, n_next;
    logic [10:0] b_reg, b_next;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            ps2c_reg <= 2'b11;
        else
            ps2c_reg <= {ps2c_reg[0], ps2c};
    end

    assign ps2c_fall_edge = (ps2c_reg == 2'b10);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            n_reg     <= 0;
            b_reg     <= 0;
        end else begin
            state_reg <= state_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
        end
    end

    always_comb begin
        state_next   = state_reg;
        rx_done = 1'b0;
        n_next       = n_reg;
        b_next       = b_reg;

        case (state_reg)
            IDLE:
                if (ps2c_fall_edge) begin
                    b_next     = {ps2d, b_reg[10:1]};
                    n_next     = 4'b1001;
                    state_next = RX;
                end
            RX:
                if (ps2c_fall_edge) begin
                    b_next = {ps2d, b_reg[10:1]};
                    if (n_reg == 0)
                        state_next = DONE;
                    else
                        n_next = n_reg - 1;
                end
            DONE: begin
                state_next   = IDLE;
                rx_done = 1'b1;
            end
        endcase
    end

    assign rx_data = b_reg[8:1];
endmodule