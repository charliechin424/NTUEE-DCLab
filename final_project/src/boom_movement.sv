module boom_movement (
    input   clk,
    input   rst_n,
    
    input   [1:0]   player1_direct,
    input   [1:0]   player2_direct,

    input   [5:0]   head_x1,
    input   [5:0]   head_y1,

    input   [5:0]   head_x2,
    input   [5:0]   head_y2,
    input   [24:0]  speed,
    
    input   boom_active1,
    input   boom_active2,

    input  boom_display,

    output o_outside1,
    output o_outside2,
    output o_outside3,

    //Player1
    output [5:0]    o_boom1_x,
    output [5:0]    o_boom1_y,
    output [5:0]    o_boom2_x,
    output [5:0]    o_boom2_y,
    output [5:0]    o_boom3_x,
    output [5:0]    o_boom3_y,

    // output o_clk_cnt,

    output  o_ready_next_boom
);

localparam UP    = 2'd0;
localparam DOWN  = 2'd1;
localparam LEFT  = 2'd2;
localparam RIGHT = 2'd3;

parameter S_WAIT = 0;
parameter S_PLAYER1_ACT  = 1;
parameter S_PLAYER2_ACT  = 2;

logic ready_next_boom, ready_next_boom_nxt;
logic [31:0] clk_cnt, clk_cnt_nxt; 

logic [5:0] boom1_x, boom1_x_nxt;
logic [5:0] boom1_y, boom1_y_nxt;
logic [5:0] boom2_x, boom2_x_nxt;
logic [5:0] boom2_y, boom2_y_nxt;
logic [5:0] boom3_x, boom3_x_nxt;
logic [5:0] boom3_y, boom3_y_nxt;

logic outside1, outside1_nxt;
logic outside2, outside2_nxt;
logic outside3, outside3_nxt;

logic [1:0] direct1, direct1_nxt;
logic [1:0] direct2, direct2_nxt;

assign o_boom1_x = boom1_x;
assign o_boom1_y = boom1_y;
assign o_boom2_x = boom2_x;
assign o_boom2_y = boom2_y;
assign o_boom3_x = boom3_x;
assign o_boom3_y = boom3_y;
assign o_ready_next_boom = ready_next_boom;
assign o_outside1 = outside1;
assign o_outside2 = outside2;
assign o_outside3 = outside3;

logic all_out, all_out_nxt;

logic [1:0] state, state_nxt;

always_comb begin
    state_nxt = state;
    clk_cnt_nxt = clk_cnt;
    boom1_x_nxt = boom1_x;
    boom1_y_nxt = boom1_y;
    boom2_x_nxt = boom2_x;
    boom2_y_nxt = boom2_y;
    boom3_x_nxt = boom3_x;
    boom3_y_nxt = boom3_y;
    direct1_nxt = direct1;
    direct2_nxt = direct2;
    case (state)
        S_WAIT : begin
            clk_cnt_nxt = 0;
            boom1_x_nxt = 0;
            boom1_y_nxt = 0;
            boom2_x_nxt = 0;
            boom2_y_nxt = 0;
            boom3_x_nxt = 0;
            boom3_y_nxt = 0;
            if (boom_active1) begin
                case (player1_direct)
                    UP: begin
                        boom1_x_nxt = head_x1 - 2;
								boom1_y_nxt = head_y1;
								boom2_x_nxt = head_x1;
                        boom2_y_nxt = head_y1 - 2;
                        boom3_x_nxt = head_x1 + 2;  
								boom3_y_nxt = head_y1;
                    end 

                    DOWN: begin
                        boom1_x_nxt = head_x1 + 2;
								boom1_y_nxt = head_y1;
								boom2_x_nxt = head_x1;
                        boom2_y_nxt = head_y1 + 2;
                        boom3_x_nxt = head_x1 - 2;
								boom3_y_nxt = head_y1;
                    end

                    LEFT: begin
								boom1_x_nxt = head_x1;
                        boom1_y_nxt = head_y1 + 2;
                        boom2_x_nxt = head_x1 - 2;
								boom2_y_nxt = head_y1;
								boom3_x_nxt = head_x1;
                        boom3_y_nxt = head_y1 - 2;    
                    end

                    RIGHT: begin
								boom1_x_nxt = head_x1;
                        boom1_y_nxt = head_y1 - 2;
                        boom2_x_nxt = head_x1 + 2;
								boom2_y_nxt = head_y1;
								boom3_x_nxt = head_x1;
                        boom3_y_nxt = head_y1 + 2;
                    end 
                endcase
                direct1_nxt = player1_direct; 
                state_nxt = S_PLAYER1_ACT;
            end else if (boom_active2) begin
                case (player2_direct)
                        UP: begin
                            boom1_x_nxt = head_x2 - 2;
									 boom1_y_nxt = head_y2;
									 boom2_x_nxt = head_x2;
                            boom2_y_nxt = head_y2 - 2;
                            boom3_x_nxt = head_x2 + 2;  
									 boom3_y_nxt = head_y2; 
                        end 

                        DOWN: begin
                            boom1_x_nxt = head_x2 + 2;
									 boom1_y_nxt = head_y2;
									 boom2_x_nxt = head_x2;
                            boom2_y_nxt = head_y2 + 2;
                            boom3_x_nxt = head_x2 - 2;
									 boom3_y_nxt = head_y2; 
                        end

                        LEFT: begin
									 boom1_x_nxt = head_x2;
                            boom1_y_nxt = head_y2 + 2;
                            boom2_x_nxt = head_x2 - 2;
									 boom2_y_nxt = head_y2;
									 boom3_x_nxt = head_x2;
                            boom3_y_nxt = head_y2 - 2;    
                        end

                        RIGHT: begin
									 boom1_x_nxt = head_x2;
                            boom1_y_nxt = head_y2 - 2;
                            boom2_x_nxt = head_x2 + 2;
									 boom2_y_nxt = head_y2;
									 boom3_x_nxt = head_x2;
                            boom3_y_nxt = head_y2 + 2;
                        end 
                    endcase
                direct2_nxt = player2_direct;
                state_nxt = S_PLAYER2_ACT;
            end else begin
                state_nxt = S_WAIT;
            end
        end 

        S_PLAYER1_ACT : begin
            clk_cnt_nxt = clk_cnt + 1;
            if (all_out) begin
                state_nxt = S_WAIT;
            end else begin
                if (clk_cnt == speed)  begin
                    clk_cnt_nxt = 0;
                    case (direct1)
                        UP: begin
                            boom1_x_nxt = boom1_x - 1;
                            boom2_y_nxt = boom2_y - 1;
                            boom3_x_nxt = boom3_x + 1;  
                        end 

                        DOWN: begin
                            boom1_x_nxt = boom1_x + 1;
                            boom2_y_nxt = boom2_y + 1;
                            boom3_x_nxt = boom3_x - 1;
                        end

                        LEFT: begin
                            boom1_y_nxt = boom1_y + 1;
                            boom2_x_nxt = boom2_x - 1;
                            boom3_y_nxt = boom3_y - 1;    
                        end

                        RIGHT: begin
                            boom1_y_nxt = boom1_y - 1;
                            boom2_x_nxt = boom2_x + 1;
                            boom3_y_nxt = boom3_y + 1;
                        end 
                    endcase
                end
            end
        end

        S_PLAYER2_ACT : begin
            clk_cnt_nxt = clk_cnt + 1;
            if (all_out) begin
                state_nxt = S_WAIT;
            end else begin
                if (clk_cnt == speed)  begin
                    clk_cnt_nxt = 0;
                    case (direct2)
                        UP: begin
                            boom1_x_nxt = boom1_x - 1;
                            boom2_y_nxt = boom2_y - 1;
                            boom3_x_nxt = boom3_x + 1;  
                        end 

                        DOWN: begin
                            boom1_x_nxt = boom1_x + 1;
                            boom2_y_nxt = boom2_y + 1;
                            boom3_x_nxt = boom3_x - 1;
                        end

                        LEFT: begin
                            boom1_y_nxt = boom1_y + 1;
                            boom2_x_nxt = boom2_x - 1;
                            boom3_y_nxt = boom3_y - 1;    
                        end

                        RIGHT: begin
                            boom1_y_nxt = boom1_y - 1;
                            boom2_x_nxt = boom2_x + 1;
                            boom3_y_nxt = boom3_y + 1;
                        end 
                    endcase
                end
            end
        end
    endcase
end

always_comb begin
    if (all_out && !ready_next_boom) begin
        ready_next_boom_nxt = 1;
    end else begin
        ready_next_boom_nxt = 0;
    end
end

always_comb begin
    if (outside1 && outside2 && outside3) begin
        all_out_nxt = 1;
    end else  begin
        all_out_nxt = 0;
    end
end

always_comb begin
    if (state == S_WAIT) begin
        outside1_nxt = 0;
    end else if ((boom1_x > 38 || boom1_x < 0 || boom1_y > 28 || boom1_y < 0) && !boom_display) begin
        outside1_nxt = 1;
    end else if (all_out) begin
        outside1_nxt = 0;
    end else begin
        outside1_nxt = outside1;
    end

    if (state == S_WAIT) begin
        outside2_nxt = 0;
    end else if ((boom2_x > 38 || boom2_x < 0 || boom2_y > 28 || boom2_y < 0) && !boom_display) begin
        outside2_nxt = 1;
    end else if (all_out) begin
        outside2_nxt = 0;
    end else begin
        outside2_nxt = outside2;
    end

    if (state == S_WAIT) begin
        outside3_nxt = 0;
    end else if ((boom3_x > 38 || boom3_x < 0 || boom3_y > 28 || boom3_y < 0) && !boom_display) begin
        outside3_nxt = 1;
    end else if (all_out) begin
        outside3_nxt = 0;
    end else begin
        outside3_nxt = outside3;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state  <= S_WAIT;
        ready_next_boom <= 0;
        all_out <= 0;
        boom1_x <= 0;
        boom1_y <= 0;
        boom2_x <= 0;
        boom2_y <= 0;
        boom3_x <= 0;
        boom3_y <= 0;
        clk_cnt <= 0;
        outside1 <= 0;
        outside2 <= 0;
        outside3 <= 0;
        direct1 <= 0;
        direct2 <= 0;
    end
    else begin
        state <= state_nxt;
        ready_next_boom <= ready_next_boom_nxt;
        all_out <= all_out_nxt;
        boom1_x <= boom1_x_nxt;
        boom1_y <= boom1_y_nxt;
        boom2_x <= boom2_x_nxt;
        boom2_y <= boom2_y_nxt;
        boom3_x <= boom3_x_nxt;
        boom3_y <= boom3_y_nxt;
        clk_cnt <= clk_cnt_nxt;
        outside1 <= outside1_nxt;
        outside2 <= outside2_nxt;
        outside3 <= outside3_nxt;
        direct1 <= direct1_nxt;
        direct2 <= direct2_nxt;
    end
end

endmodule