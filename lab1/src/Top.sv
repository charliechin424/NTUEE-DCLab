module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	input        i_forward,
	input        i_backward,
	output [3:0] o_random_out,
	output [3:0] o_history_out,
	output [3:0] o_access_index_out,
	output [3:0] o_store_index_out
);

// ===== States =====
parameter S_IDLE = 1'b0;
parameter S_RUN  = 1'b1;

// ===== Output Buffer =====
logic [3:0] o_random_out_r;
logic [3:0] o_random_out_w;
logic [3:0] history_num_r [0:7];
// logic [3:0] history_num_w [0:4];

// ===== Register & Wires =====
logic state_r;
logic state_w;
logic [31:0] rands_r;
logic [31:0] rands_w;
logic [31:0] rands_tmp_r;
logic [31:0] rands_tmp_w;
logic rands_w6;
logic rands_w3;
logic rands_w4;
logic rands_w1;
logic rands_w31;
logic rands_w64;
logic rands_w6431;
logic [31:0]counter_r;
logic [31:0]counter_w;
logic [31:0]trigger_r;
logic [31:0]trigger_w;
logic[2:0] store_index_w;
logic[2:0] store_index_r; 
logic[2:0] access_index_w;
logic[2:0] access_index_r;
logic [3:0] o_history_out_w;
   
// ===== Output Assignments =====
assign o_random_out = o_random_out_r;
assign o_access_index_out = access_index_r + 3'd1;
assign o_store_index_out = store_index_r;
assign o_history_out = o_history_out_w;

always_comb begin 
	case(access_index_r)
		0: o_history_out_w = history_num_r[0];
		1: o_history_out_w = history_num_r[1];
		2: o_history_out_w = history_num_r[2];
		3: o_history_out_w = history_num_r[3];
		4: o_history_out_w = history_num_r[4];
		5: o_history_out_w = history_num_r[5];
		6: o_history_out_w = history_num_r[6];
		default: o_history_out_w = history_num_r[7];
	endcase
end


// ===== Combinational Circuit =====
always_comb begin
    // Default Values
	rands_w6       = rands_r[6];
	rands_w3       = rands_r[3];
	rands_w4       = rands_r[4];
	rands_w1       = rands_r[1];
	rands_w31      = rands_r[3] ^ rands_r[1];
	rands_w64     = rands_r[4] ^ rands_w[6];
	rands_w6431    = rands_w64 ^ rands_w31;
	rands_w        = rands_tmp_r;
	counter_w      = counter_r;
	trigger_w      = trigger_r;
	o_random_out_w = o_random_out_r;
	rands_tmp_w    = rands_tmp_r;
	access_index_w = access_index_r;
	store_index_w = store_index_r;

    // FSM
	case(state_r)
		S_IDLE:
		begin
    		if (i_start)
			begin
				counter_w = 32'd0;
				trigger_w = 32'd2500000;
				store_index_w = store_index_r + 3'b1;
        		state_w = S_RUN;
			end
			else
			begin
				state_w = state_r;
				rands_tmp_w = rands_tmp_r;
			end

			if (i_forward) begin
				access_index_w = (access_index_r == 3'd7) ? 3'd0 : access_index_r + 1;
			end 
			else if (i_backward) begin
				access_index_w = (access_index_r == 3'b0) ? 3'd7 : access_index_r - 1;
			end
			else begin
				access_index_w = access_index_r;
			end
		end
		

		S_RUN:
		begin
			if(trigger_r >= 32'd18000000)
			begin
				state_w = S_IDLE; 
			end
			else if(counter_r == trigger_r)
			begin
				counter_w = 32'd0;
				trigger_w = trigger_r + 32'd900000;
				rands_tmp_w[28:0] 	= rands_r[31:3];
				rands_tmp_w[29] 	= rands_w31;
				rands_tmp_w[30] 	= rands_w64;
				rands_tmp_w[31]   	= rands_w6431;
				state_w 			= state_r;
			end
			else
			begin
				o_random_out_w = rands_r[3:0];
				counter_w = counter_r + 32'd1;
				state_w = state_r;
			end
		end
	endcase
end

// ===== Sequential Circuits =====


always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n)
	begin
		o_random_out_r   <= 4'd0;
		state_r          <= S_IDLE;
		counter_r        <= 32'd0;
		trigger_r        <= 32'd0;
		rands_tmp_r      <= 32'b01001110101011010111011101010101;
		store_index_r    <= 1'b0;
		access_index_r   <= 1'b0;
		history_num_r[0] <= 0;
		history_num_r[1] <= 0;
		history_num_r[2] <= 0;
		history_num_r[3] <= 0;
		history_num_r[4] <= 0;
		history_num_r[5] <= 0;
		history_num_r[6] <= 0;
		history_num_r[7] <= 0;
	end
	else
	begin
		trigger_r      <= trigger_w;
		o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
		counter_r      <= counter_w;
		rands_r        <= rands_w;
		rands_tmp_r    <= rands_tmp_w;
		access_index_r <= access_index_w;
		store_index_r  <= store_index_w;
		case(store_index_r) 
			0: history_num_r[7] <= o_random_out_w;
			1: history_num_r[0] <= o_random_out_w;
			2: history_num_r[1] <= o_random_out_w;
			3: history_num_r[2] <= o_random_out_w;
			4: history_num_r[3] <= o_random_out_w;
			5: history_num_r[4] <= o_random_out_w;
			6: history_num_r[5] <= o_random_out_w;
			7: history_num_r[6] <= o_random_out_w;
		endcase
	end
end

endmodule