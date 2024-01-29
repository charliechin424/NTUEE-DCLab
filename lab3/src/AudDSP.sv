module AudDSP(
	input i_rst_n,
	input i_clk,
	input i_start,
	input i_pause,
	input i_stop,
	input [3:0] i_speed,
	input [1:0] i_mode,
	input i_daclrck, 
	input [15:0] i_data,
	output [15:0] o_dac_data,
	output [19:0] o_sram_addr
);

localparam S_IDLE = 0;
localparam S_PROC = 1;
localparam S_PAUSE= 2;

localparam m_original = 0;
localparam m_fast = 1;
localparam m_constant_interpolation = 2;
localparam m_linear_interpolation = 3;

logic [15:0] prev_data_r, prev_data_w, curr_data_r, curr_data_w;
logic [1:0] state_r, state_w;
logic [15:0] o_dac_data_r, o_dac_data_w;
logic [19:0] o_sram_addr_r, o_sram_addr_w;
logic [3:0] counter_r, counter_w;

assign o_dac_data = o_dac_data_r;
assign o_sram_addr = o_sram_addr_r;

always_comb begin
	prev_data_w = $signed(prev_data_r);
	curr_data_w = $signed(curr_data_r);
	state_w = state_r;
	o_dac_data_w = $signed(o_dac_data_r);
	o_sram_addr_w = o_sram_addr_r;
	counter_w = counter_r;

	case (state_r)
		S_IDLE: begin
			if(i_start) begin
				state_w = S_PROC;
			end
		end

		S_PROC: begin
			if (i_pause) begin
				state_w = S_PAUSE;
			end else begin 
				case(i_mode)

					m_original: begin
						curr_data_w = $signed(i_data);
						o_dac_data_w = i_data;
						o_sram_addr_w = o_sram_addr_r + 1;
					end

					m_fast: begin
						curr_data_w = $signed(i_data);
						o_dac_data_w = i_data;
						o_sram_addr_w = o_sram_addr_r + i_speed;
					end

					m_constant_interpolation: begin
						o_dac_data_w = $signed(i_data);
						if (counter_r == 0) begin
							curr_data_w = $signed(i_data);
							o_sram_addr_w = o_sram_addr_r + 1;
							counter_w = counter_r + 1; 
						end else if (counter_r == i_speed - 1) begin
							counter_w = 0;
							o_sram_addr_w = o_sram_addr_r;
						end else begin
							counter_w = counter_r + 1; 
							o_sram_addr_w = o_sram_addr_r;
						end
					end

					m_linear_interpolation: begin
						if (counter_r == 4'd0) begin
							curr_data_w = $signed(i_data);
							prev_data_w = $signed(curr_data_r);
							o_dac_data_w = $signed(curr_data_r);
							o_sram_addr_w = o_sram_addr_r + 1;
							counter_w = counter_r + 1;
						end else begin
							o_sram_addr_w = o_sram_addr_r;
							o_dac_data_w = ($signed(prev_data_r) * $signed(i_speed - counter_r) + $signed(curr_data_r) * $signed(counter_r)) / $signed(i_speed);
							if (counter_r == i_speed - 1) begin
								counter_w = 0; 
							end else begin
								counter_w = counter_r + 1;
							end
						end
					end

				endcase
			end
		end

		S_PAUSE: begin 	
			if(!i_pause) begin 
				state_w = S_PROC;
			end else begin
				state_w = S_PAUSE;
			end
		end
	endcase
end
 
always_ff @(negedge i_daclrck or negedge i_rst_n or posedge i_stop) begin
	if (!i_rst_n || i_stop)
	begin 
		prev_data_r <= 0; 
		curr_data_r <= 0;
		state_r <= S_IDLE;
		o_dac_data_r <= 0;
		o_sram_addr_r <= 0;
		counter_r <= 0;
	end else begin
		prev_data_r <= $signed(prev_data_w);
		curr_data_r <= $signed(curr_data_w);
		state_r <= state_w;
		o_dac_data_r <= $signed(o_dac_data_w);
		o_sram_addr_r <= o_sram_addr_w;
		counter_r <= counter_w;
	end
end

endmodule 