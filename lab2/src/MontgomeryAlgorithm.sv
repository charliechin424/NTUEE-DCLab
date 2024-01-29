module Montgomery_Algorithm(
	input i_clk,
	input i_rst,
	input i_start,
	input [255:0] N,
	input [255:0] a,
	input [255:0] b,
	output [255:0] m,
	output o_finished
);

parameter S_IDLE = 0;
parameter S_RUN = 1;
parameter S_FINISH = 2;

logic [257:0] m_w, m_r;
logic o_finished_w, o_finished_r;

logic [8:0] counter_w, counter_r;
logic [1:0] state_w, state_r;

assign m = m_r[255:0];
assign o_finished = o_finished_r;

always_comb begin
	m_w = m_r;
	o_finished_w = o_finished_r;
	state_w = state_r;
	counter_w = counter_r;

	case (state_r) 

		S_IDLE: begin
			m_w = 0;
			o_finished_w = 0;
			counter_w = 0;
			if (i_start) begin
				state_w = S_RUN;
			end else begin
				state_w = S_IDLE;
			end
		end

		S_RUN: begin
			if(a[counter_r] == 1 && (m_r[0] + b[0]) == 1) begin
				m_w = (m_r + b + N) >> 1;
			end else if (a[counter_r] == 1 && (m_r[0] + b[0]) != 1) begin
				m_w = (m_r + b) >> 1;
			end else if (a[counter_r] != 1 && m_r[0] == 1) begin
				m_w = (m_r + N) >> 1;
			end else if (a[counter_r] != 1 && m_r[0] != 1) begin
				m_w = m_r >> 1;
			end else begin
				m_w = m_r;
			end

			counter_w = counter_r + 1;

			if (counter_r == 255) begin
				state_w = S_FINISH;
			end else begin
				state_w = S_RUN;
			end
		end

		S_FINISH: begin
			if (m_r >= N) begin
				m_w = m_r - N;
			end else begin
				m_w = m_r;
			end
			state_w = S_IDLE;
			o_finished_w = 1;
		end

	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
	if(i_rst)
	begin
		m_r <= 0;
		o_finished_r <= 0;
		state_r <= 0;
		counter_r <= 0;
	end
	else
	begin
		m_r <= m_w;
		o_finished_r <= o_finished_w;
		state_r <= state_w;
		counter_r <= counter_w;
	end
end

endmodule