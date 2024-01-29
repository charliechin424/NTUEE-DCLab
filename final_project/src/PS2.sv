module PS2_key (
    input i_clk,
    input i_rst_n,
    input i_key_clk,
    input i_key_data,
    output o_P1_UP,
    output o_P1_DOWN,
    output o_P1_LEFT,
    output o_P1_RIGHT,
	output o_P2_UP,
    output o_P2_DOWN,
    output o_P2_LEFT,
    output o_P2_RIGHT
);

// direction output
logic	[3:0] Dir_P1;
assign o_P1_UP = Dir_P1[3];
assign o_P1_DOWN = Dir_P1[2];
assign o_P1_LEFT = Dir_P1[1];
assign o_P1_RIGHT = Dir_P1[0];

logic	[3:0] Dir_P2;
assign o_P2_UP = Dir_P2[3];
assign o_P2_DOWN = Dir_P2[2];
assign o_P2_LEFT = Dir_P2[1];
assign o_P2_RIGHT = Dir_P2[0];

logic	key_clk_r0 = 1'b1,key_clk_r1 = 1'b1; 
logic	key_data_r0 = 1'b1,key_data_r1 = 1'b1;

always_ff @ (posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		key_clk_r0 <= 1'b1;
		key_clk_r1 <= 1'b1;
		key_data_r0 <= 1'b1;
		key_data_r1 <= 1'b1;
	end else begin
		key_clk_r0 <= i_key_clk;
		key_clk_r1 <= key_clk_r0;
		key_data_r0 <= i_key_data;
		key_data_r1 <= key_data_r0;
	end
end
 
logic	key_clk_neg;
assign key_clk_neg = key_clk_r1 & (~key_clk_r0); 
 
logic				[3:0]	cnt; 
logic				[7:0]	temp_data;
logic						key_break = 1'b0;   
logic				[7:0]	key_byte = 1'b0;

always_ff @ (posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		cnt <= 4'd0;
		temp_data <= 8'd0;
		key_break <= 1'b0;
		key_byte <= 1'b0;
		Dir_P1 <= 0;
		Dir_P2 <= 0;
	end else if(key_clk_neg) begin 
		if(cnt >= 4'd10) cnt <= 4'd0;
		else cnt <= cnt + 1'b1;
		case (cnt)
			4'd0: ;	// init
			4'd1: temp_data[0] <= key_data_r1;
			4'd2: temp_data[1] <= key_data_r1;
			4'd3: temp_data[2] <= key_data_r1;
			4'd4: temp_data[3] <= key_data_r1;
			4'd5: temp_data[4] <= key_data_r1;
			4'd6: temp_data[5] <= key_data_r1;
			4'd7: temp_data[6] <= key_data_r1;
			4'd8: temp_data[7] <= key_data_r1;
			4'd9: ;
			4'd10: begin
				if(temp_data == 8'hf0) key_break <= 1'b1;	// 8'hf0 => release signal
				else if(!key_break) begin	
					// =================
					// ==    press    ==
					// =================
					key_byte <= temp_data; 
					case (temp_data) 
						// WSAD
						8'h1D : Dir_P1 <= 4'b1000;
						8'h1B : Dir_P1 <= 4'b0100;
						8'h1C : Dir_P1 <= 4'b0010;
						8'h23 : Dir_P1 <= 4'b0001;
						// IKJL
						8'h43 : Dir_P2 <= 4'b1000;
						8'h42 : Dir_P2 <= 4'b0100;
						8'h3B : Dir_P2 <= 4'b0010;
						8'h4B : Dir_P2 <= 4'b0001;
					endcase
				end 
				else begin
					// =================
					// ==   release   ==
					// =================
					key_break <= 1'b0;
					case (temp_data)
						// WSAD
						8'h1D : Dir_P1 <= 0;
						8'h1B : Dir_P1 <= 0;
						8'h1C : Dir_P1 <= 0;
						8'h23 : Dir_P1 <= 0;
						// IKJL
						8'h43 : Dir_P2 <= 0;
						8'h42 : Dir_P2 <= 0;
						8'h3B : Dir_P2 <= 0;
						8'h4B : Dir_P2 <= 0;
					endcase
				end
				temp_data <= 0;
			end
			default: ;
		endcase
	end
end

endmodule