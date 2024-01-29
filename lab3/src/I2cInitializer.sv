module I2cInitializer(
	input i_rst_n,
	input i_clk,
	input i_start,
	output o_finished,
	output o_sclk, 
	inout io_sdat, 
	output o_oen // you are outputing (you are not outputing only when you are acknowledging.) 
); 

localparam S_START = 0;
localparam S_WRITE= 1;
localparam S_TRANSMIT=2;
localparam S_ACK=3;
localparam S_FINISH=4;
localparam S_IDLE=5;

localparam Left_Line_In = 24'b0011_0100_000_0000_0_1001_0111;
localparam Right_Line_In = 24'b0011_0100_000_0001_0_1001_0111;
localparam Left_Headphone_Out = 24'b0011_0100_000_0010_0_0111_1001;
localparam Right_Headphone_Out = 24'b0011_0100_000_0011_0_0111_1001;
localparam Analogue_Audio_Path_Control  = 24'b0011_0100_000_0100_0_0001_0101;
localparam Digital_Audio_Path_Control  = 24'b0011_0100_000_0101_0_0000_0000;
localparam Power_Down_Control = 24'b0011_0100_000_0110_0_0000_0000;
localparam Digital_Audio_Interface_Format = 24'b0011_0100_000_0111_0_0100_0010;
localparam Sampling_Control = 24'b0011_0100_000_1000_0_0001_1001;
localparam Active_Control = 24'b0011_0100_000_1001_0_0000_0001;

logic [0:23] config_data [0:9];

assign config_data[9] = Left_Line_In;
assign config_data[8] = Right_Line_In;
assign config_data[7] = Left_Headphone_Out;
assign config_data[6] = Right_Headphone_Out;
assign config_data[5] = Analogue_Audio_Path_Control;
assign config_data[4] = Digital_Audio_Path_Control;
assign config_data[3] = Power_Down_Control;
assign config_data[2] = Digital_Audio_Interface_Format;
assign config_data[1] = Sampling_Control;
assign config_data[0] = Active_Control;

logic [2:0] state_r, state_w; 

logic finished_r, finished_w;
logic sclk_r, sclk_w;
logic sdat_r, sdat_w;
logic oen_r, oen_w;

logic [4:0] bitcounter_w, bitcounter_r;  
logic [3:0] datcounter_w, datcounter_r; 
logic [1:0] wait_clock_w, wait_clock_r;

assign o_finished = finished_r;
assign o_sclk = sclk_r;
assign io_sdat = sdat_r;
assign o_oen = oen_r;

always_comb begin
	state_w = state_r;
	finished_w = 0;
	sclk_w = 1; 
	sdat_w = sdat_r; 
	oen_w = oen_r;
	bitcounter_w = bitcounter_r;
	datcounter_w = datcounter_r;
	wait_clock_w = wait_clock_r;

	case(state_r)

		S_IDLE: begin
			if (wait_clock_r == 0) begin
				wait_clock_w = 1;
			end else if (datcounter_w < 4'd10) begin
				bitcounter_w = 0;
				wait_clock_w = 0;
				sdat_w = 1;
				state_w = S_START;
			end else begin
				finished_w = 1;
			end
		end

		S_START: begin 
			sdat_w = 0;
			state_w = S_WRITE;
		end

		S_WRITE:
		begin
			sclk_w = 1'b0;
			oen_w = 1'b1;
			state_w = S_TRANSMIT;
			sdat_w = config_data[datcounter_r][bitcounter_r];
		end

		S_TRANSMIT:
		begin
			if ((bitcounter_r + 1) % 8 == 0 ) begin
				state_w = S_ACK;
				if ((bitcounter_r + 1) == 24) begin 
					datcounter_w = datcounter_r + 3'd1;
					bitcounter_w = 24;
				end else begin
					bitcounter_w = bitcounter_r + 5'd1;
				end
			end else begin
				state_w = S_WRITE;
				bitcounter_w = bitcounter_r + 5'd1;
			end
		end

		S_ACK: begin
			sdat_w = 1'bz;
			oen_w = 0;
			if (wait_clock_r == 0) begin	
				wait_clock_w = 1;
				sclk_w = 1'b0;
			end else begin
				wait_clock_w = 0;
				sclk_w = 1;
				if (bitcounter_r == 24) begin
					state_w = S_FINISH;
				end else begin
					state_w = S_WRITE;
				end
			end
		end

		S_FINISH: begin
			oen_w = 1;
			if(wait_clock_r <= 1) begin
				wait_clock_w = wait_clock_r + 1;
				sdat_w = 0;
			end else begin
				wait_clock_w = 0;
				sdat_w = 1;
				state_w = S_IDLE;
			end
		end

	endcase
end

always_ff @(negedge i_clk or negedge i_rst_n) 
begin
	if (!i_rst_n)
	begin
		state_r <= S_IDLE;
		bitcounter_r <= 5'd0;
		datcounter_r <= 3'd0;
		finished_r <= 0;
		sclk_r <= 1; 
		sdat_r <= 0; 
		oen_r <= 0;
		wait_clock_r <= 0;
	end
	else
	begin
		state_r   <= state_w;
		bitcounter_r <= bitcounter_w;
		datcounter_r <= datcounter_w;
		finished_r <= finished_w;
		sclk_r <= sclk_w; 
		sdat_r <= sdat_w; 
		oen_r <= oen_w;
		wait_clock_r <= wait_clock_w;
	end
end
endmodule