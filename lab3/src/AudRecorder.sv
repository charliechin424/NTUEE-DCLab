module AudRecorder (
	input i_rst_n,
	input i_bclk,
	input i_adclrck,
	input i_start,
	input i_pause,
	input i_stop,
	input i_aud_adcdata,
	output [19:0] o_sram_addr,
	output [15:0] o_data
);

parameter S_IDLE = 2'b00;
parameter S_NOT_RECORD = 2'b01;
parameter S_RECORD = 2'b10;
parameter S_RECORD_FINISHED = 2'b11;

logic [19:0] o_address_r, o_address_w;
logic [15:0] o_data_r, o_data_w;

logic [1:0] state_r, state_w;
logic [4:0] counter_r, counter_w;

logic pause_r; 
logic pause_w; 

logic stop_r; 
logic stop_w;

assign o_sram_addr = o_address_r;
assign o_data = o_data_r;

always_comb begin
	o_address_w = o_address_r;
	o_data_w = o_data_r;
	state_w = state_r;
	counter_w = counter_r;
	pause_w = i_pause;
	stop_w = stop_r;
    
	case(state_r)
		S_IDLE: begin
			if(i_start) begin
				if(i_adclrck) begin
					state_w = S_RECORD;
                end else begin
					state_w = S_NOT_RECORD;
                end
			end
		end

		S_NOT_RECORD: begin 
			counter_w = 5'd16;
			if(i_stop || stop_r)
				state_w = S_IDLE;
			else if(i_adclrck && !pause_r) begin
                o_data_w = 0;
				state_w = S_RECORD;
			end
		end

		S_RECORD: begin 
			if(i_stop) begin
				stop_w = 1;
            end

			o_data_w[counter_r-1] = i_aud_adcdata;
			counter_w = counter_r - 4'd1;

			if(counter_r == 0) begin
                o_address_w = o_address_r + 1;
				state_w = S_RECORD_FINISHED;
			end
		end

		S_RECORD_FINISHED: begin
			if(!i_adclrck) begin
				state_w = S_NOT_RECORD;
			end
		end
	endcase
end

always_ff @(posedge i_bclk or negedge i_rst_n) begin
	if(!i_rst_n) begin 
		o_address_r <= 0;
		o_data_r <= 0;
		state_r <= 0;
		counter_r <= 0;
		stop_r <= 0;
	end
	else begin
		o_address_r <= o_address_w;
		o_data_r <= o_data_w;
		state_r <= state_w;
		counter_r <= counter_w;
		stop_r <= stop_w;
	end
end

always_ff @(posedge i_adclrck or negedge i_rst_n) begin
	if(!i_rst_n)
		pause_r <= 0;
	else
		pause_r <= pause_w;
end

endmodule