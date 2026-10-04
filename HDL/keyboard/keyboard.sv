module keyboard(
    input logic clk,
    input logic reset,

    input logic ps2c,
    input logic ps2d,

    input logic re,

    output logic key_ready,
    output logic [7:0] key
);

    logic rx_done;
    logic [7:0] rx_data;

    ps2rx rx(
        .clk(clk),
        .reset(reset),
        .ps2c(ps2c),
        .ps2d(ps2d),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

    typedef enum logic {WAIT_MAKE, WAIT_BREAK} state_type;
    state_type state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= WAIT_MAKE;
            key_ready  <= 1'b0;
            key        <= 8'h00;
        end
        else begin
            if (re) key_ready <= 1'b0;

            if (rx_done) begin
                if (state == WAIT_MAKE) begin
                    if (rx_data == 8'hF0) begin
                        state <= WAIT_BREAK;
                    end
                    else begin
                        case (rx_data)
                            8'h1C: key <= "A";  8'h32: key <= "B";
                            8'h21: key <= "C";  8'h23: key <= "D";
                            8'h24: key <= "E";  8'h2B: key <= "F";
                            8'h34: key <= "G";  8'h33: key <= "H";
                            8'h43: key <= "I";  8'h3B: key <= "J";
                            8'h42: key <= "K";  8'h4B: key <= "L";
                            8'h3A: key <= "M";  8'h31: key <= "N";
                            8'h44: key <= "O";  8'h4D: key <= "P";
                            8'h15: key <= "Q";  8'h2D: key <= "R";
                            8'h1B: key <= "S";  8'h2C: key <= "T";
                            8'h3C: key <= "U";  8'h2A: key <= "V";
                            8'h1D: key <= "W";  8'h22: key <= "X";
                            8'h35: key <= "Y";  8'h1A: key <= "Z";

                            8'h45: key <= "0";  8'h16: key <= "1";
                            8'h1E: key <= "2";  8'h26: key <= "3";
                            8'h25: key <= "4";  8'h2E: key <= "5";
                            8'h36: key <= "6";  8'h3D: key <= "7";
                            8'h3E: key <= "8";  8'h46: key <= "9";

                            8'h0E: key <= "`";
                            8'h4E: key <= "-";
                            8'h55: key <= "=";
                            8'h5D: key <= 8'h5C;
                            8'h54: key <= "[";
                            8'h5B: key <= "]";
                            8'h4C: key <= ";";
                            8'h52: key <= "'";
                            8'h41: key <= ",";
                            8'h49: key <= ".";
                            8'h4A: key <= "/";

                            8'h29: key <= " ";
                            8'h5A: key <= 8'h0D;
                            8'h66: key <= 8'h08;
                            8'h76: key <= 8'h1B;
                            8'h0D: key <= 8'h09;

                            default: key <= "?";
                        endcase
                        key_ready <= 1'b1;
                    end
                end
                else begin
                    state <= WAIT_MAKE;
                end
            end
        end
    end

endmodule