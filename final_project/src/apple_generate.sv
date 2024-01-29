module apple_generate #(
	parameter Time = 0
) (
	input i_clk,  					
	input i_rst_n,					
	
	input [5:0] i_head_x1,			
	input [5:0] i_head_y1,			
	input [5:0] i_head_x2,
	input [5:0] i_head_y2,

	output [5:0] o_apple_x,		
	output [4:0] o_apple_y,		
	output o_apple_exist,

	output o_add_cube1,			
	output o_add_cube2
);

parameter S_WAIT = 0;
parameter S_GEN = 1;

parameter SECOND = 28'd25000000;

logic state_r, state_w;
logic [27:0] cnt_time_r, cnt_time_w;
logic [10:0]	random_num, random_num_nxt;  
logic add_cube1, add_cube_nxt1, add_cube2, add_cube_nxt2;
logic [5:0] apple_x, apple_x_nxt;
logic [4:0] apple_y, apple_y_nxt;

assign o_apple_x = apple_x;
assign o_apple_y = apple_y;
assign o_add_cube1 = add_cube1;
assign o_add_cube2 = add_cube2;

logic apple_cnt, apple_cnt_nxt;

always_comb begin
	random_num_nxt = random_num + 999 * (Time+1);
	state_w = state_r;
	cnt_time_w = cnt_time_r;
	add_cube_nxt1 = 0;
	add_cube_nxt2 = 0;
	apple_x_nxt = apple_x;
	apple_y_nxt = apple_y;

	case (state_r)
		S_WAIT: begin
			o_apple_exist = 0;
			if (cnt_time_r >= SECOND * Time + 500) begin
				state_w = S_GEN;
				cnt_time_w = 0;
				apple_x_nxt = (random_num[10:5] > 38) ? (random_num[10:5] - 25) : (random_num[10:5] == 0) ? 1 : random_num[10:5];
				apple_y_nxt = (random_num[4:0] > 28) ? (random_num[4:0] - 3) : (random_num[4:0] == 0) ? 1 :random_num[4:0];
			end
			else begin
				cnt_time_w = cnt_time_r + 1;
			end
		end
		S_GEN: begin
			o_apple_exist = 1;
			if(apple_x == i_head_x1 && apple_y == i_head_y1) begin
				// snake 1 eat
				state_w = S_WAIT;
				cnt_time_w = 0;
				add_cube_nxt1 = 1;
				add_cube_nxt2 = add_cube2;
			end else if (apple_x == i_head_x2 && apple_y == i_head_y2) begin
				// snake2 eat
				state_w = S_WAIT;
				cnt_time_w = 0;
				add_cube_nxt1 = add_cube1;
				add_cube_nxt2 = 1;
			end else begin
				add_cube_nxt1 = 0;
				add_cube_nxt2 = 0;
				apple_x_nxt = apple_x;
				apple_y_nxt = apple_y;
			end
		end
	endcase
end

	

always_ff@(posedge i_clk) begin
	random_num <= random_num_nxt;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		state_r <= S_WAIT;
		cnt_time_r = 0;
		apple_x <= 24;
		apple_y <= 10;
		add_cube1 <= 0;
		add_cube2 <= 0;
	end else begin
		state_r <= state_w;
		cnt_time_r <= cnt_time_w;
		apple_x <= apple_x_nxt;
		apple_y <= apple_y_nxt;
		add_cube1 <= add_cube_nxt1;
		add_cube2 <= add_cube_nxt2;
	end
end

endmodule