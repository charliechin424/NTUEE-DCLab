module AudPlayer(
	input 			i_rst_n,
	input 			i_bclk,
	input 			i_daclrck,
	input 			i_en, // enable AudPlayer only when playing audio, work with AudDSP
	input 	[15:0]	i_dac_data,
	output 			o_aud_dacdat
);

parameter S_IDLE = 2'b00;
parameter S_PLAY = 2'b01;
parameter S_PLAY_FINISH = 2'b10;

logic o_aud_dacdat_r, o_aud_dacdat_w;

logic [1:0] state_r, state_w;
logic [4:0] counter_r, counter_w;
logic [15:0] i_dac_data_r, i_dac_data_w;
logic en;

assign o_aud_dacdat = o_aud_dacdat_r;

always_comb begin
	i_dac_data_w = i_dac_data_r;
	o_aud_dacdat_w = o_aud_dacdat_r;
	state_w = state_r;
	counter_w = counter_r;

	case(state_r)

		S_IDLE: begin
			if(i_en) begin
				state_w = S_PLAY;
			end else begin
				state_w = S_IDLE;
			end
		end

		S_PLAY: begin
			if (en && i_daclrck) begin 
				if(counter_r == 5'd16) begin
					state_w = S_PLAY_FINISH;
					counter_w = 0;
					o_aud_dacdat_w = 0;
				end else begin
					o_aud_dacdat_w = i_dac_data_r[5'd15-counter_r];
					counter_w = counter_r + 1;
					state_w = S_PLAY;
				end
			end
		end

		S_PLAY_FINISH: begin
			state_w = S_IDLE;
		end

	endcase
end


always_ff @(negedge i_bclk or negedge i_rst_n) begin	
	if(!i_rst_n) begin
		state_r <= S_IDLE;
		o_aud_dacdat_r <= 0;
		counter_r <= 0;
	end else begin
		o_aud_dacdat_r <= o_aud_dacdat_w;
		state_r <= state_w;
		counter_r <= counter_w;
	end
end

always_ff @(posedge i_daclrck or negedge i_rst_n) begin	
	if(!i_rst_n)
	begin
		en <= 0;
		i_dac_data_r <= 0;
	end else begin
		en <= i_en;
		i_dac_data_r <= i_dac_data;
	end
end

endmodule