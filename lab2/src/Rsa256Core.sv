module Rsa256Core (
	input          i_clk,
	input          i_rst,
	input          i_start,
	input  [255:0] i_a, // cipher text y
	input  [255:0] i_d, // private key
	input  [255:0] i_n,
	output [255:0] o_a_pow_d, // plain text x
	output         o_finished
);

// operations for RSA256 decryption
// namely, the Montgomery algorithm


parameter S_IDLE = 0;
parameter S_PREP_ON = 1;
parameter S_PREP_WAIT = 2;
parameter S_MONT_ON = 3;
parameter S_MONT_WAIT = 4;
parameter S_CALC = 5;

logic [255:0] encryptdata_w, encryptdata_r;

logic [255:0] o_a_pow_d_w, o_a_pow_d_r;
logic o_finished_w, o_finished_r;

logic [2:0] state_w, state_r;
logic [255:0] t_w, t_r;
logic [255:0] m_w, m_r;
logic [8:0] counter_w, counter_r;
logic Prep_start_w, Prep_start_r;
logic Mont_t_start_w, Mont_t_start_r;
logic Mont_m_start_w, Mont_m_start_r;
logic [255:0] Mont_t_input_a_w, Mont_t_input_a_r;
logic [255:0] Mont_t_input_b_w, Mont_t_input_b_r;
logic [255:0] Mont_m_input_a_w, Mont_m_input_a_r;
logic [255:0] Mont_m_input_b_w, Mont_m_input_b_r;
logic [255:0] Prep_output;
logic [255:0] Mont_t_output;
logic [255:0] Mont_m_output;
logic Prep_finished;
logic Mont_t_finished;
logic Mont_m_finished;
logic t_finished_w, t_finished_r;
logic m_finished_w, m_finished_r;


assign o_a_pow_d = o_a_pow_d_r;
assign o_finished = o_finished_r;

ModuloProduct Prep(
	.clk(i_clk),
	.i_rst(i_rst),
	.i_str(Prep_start_r),
	.N(i_n),
	.a((257'b1<<256)),
	.b(encryptdata_r),
	.k(256),
	.m(Prep_output),
	.o_fin(Prep_finished)
);

Montgomery_Algorithm Mont_t(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(Mont_t_start_r),
	.N(i_n),
	.a(Mont_t_input_a_r),
	.b(Mont_t_input_b_r),
	.m(Mont_t_output),
	.o_finished(Mont_t_finished)
);

Montgomery_Algorithm Mont_m(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(Mont_m_start_r),
	.N(i_n),
	.a(Mont_m_input_a_r),
	.b(Mont_m_input_b_r),
	.m(Mont_m_output),
	.o_finished(Mont_m_finished)
);

always_comb begin
	o_a_pow_d_w = o_a_pow_d_r;
	o_finished_w = o_finished_r;
	state_w = state_r;
	t_w = t_r;
	m_w = m_r;
	counter_w = counter_r;
	Prep_start_w = Prep_start_r;
	Mont_t_start_w = Mont_t_start_r;
	Mont_m_start_w = Mont_m_start_r;
	Mont_t_input_a_w = Mont_t_input_a_r;
	Mont_t_input_b_w = Mont_t_input_b_r;
	Mont_m_input_a_w = Mont_m_input_a_r;
	Mont_m_input_b_w = Mont_m_input_b_r;
	encryptdata_w = encryptdata_r;
	t_finished_w = t_finished_r;
	m_finished_w = m_finished_r;

	case(state_r)

		S_IDLE: begin
			o_finished_w = 0;
			if(i_start) begin
				o_a_pow_d_w = 0;
				state_w = S_PREP_ON;
				t_w = 0;
				m_w = 0;
				counter_w = 0;
				Prep_start_w = 0;
				Mont_t_start_w = 0;
				Mont_m_start_w = 0;
				Mont_t_input_a_w = 0;
				Mont_t_input_b_w = 0;
				Mont_m_input_a_w = 0;
				Mont_m_input_b_w = 0;
				encryptdata_w = i_a;
				t_finished_w = 0;
				m_finished_w = 0;
			end
		end

		S_PREP_ON: begin
			Prep_start_w = 1;
			state_w = S_PREP_WAIT;
		end

		S_PREP_WAIT: begin
			Prep_start_w = 0;
			if(Prep_finished) begin
				t_w = Prep_output;
				m_w = 256'd1;
				state_w = S_MONT_ON;
			end
		end

		S_MONT_ON: begin
			if(i_d[counter_r] == 1) begin
				Mont_m_start_w = 1;
				Mont_m_input_a_w = m_r;
				Mont_m_input_b_w = t_r;
			end
			Mont_t_start_w = 1;
			Mont_t_input_a_w = t_r;
			Mont_t_input_b_w = t_r;
			state_w = S_MONT_WAIT;
		end

		S_MONT_WAIT: begin
			if(i_d[counter_r] == 1) begin
				Mont_m_start_w = 0;
				if(Mont_m_finished) begin
					m_w = Mont_m_output;
					m_finished_w = 1;
				end
			end
			
			Mont_t_start_w = 0;
			if(Mont_t_finished) begin
				t_w = Mont_t_output;
				t_finished_w = 1;
			end

			if( ( (i_d[counter_r] == 0) && (t_finished_r) ) || ( (i_d[counter_r]==1) && (m_finished_r) && (t_finished_r) ) ) begin
				state_w = S_CALC;
				t_finished_w = 0;
				m_finished_w = 0;
			end
		end
		
		S_CALC: begin
			if(counter_r < 255) begin
				state_w = S_MONT_ON;
				counter_w = counter_r + 1;
			end else begin
				o_a_pow_d_w = m_r;
				o_finished_w = 1;
				state_w = S_IDLE;
			end
		end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin	
	if(i_rst)
	begin
		o_a_pow_d_r <= 0;
		o_finished_r <= 0;
		state_r <= 0;
		t_r <= 0;
		m_r <= 0;
		counter_r <= 0;
		Prep_start_r <= 0;
		Mont_t_start_r <= 0;
		Mont_m_start_r <= 0;
		Mont_t_input_a_r <= 0;
		Mont_t_input_b_r <= 0;
		Mont_m_input_a_r <= 0;
		Mont_m_input_b_r <= 0;
		encryptdata_r <= 0;
		t_finished_r <= 0;
		m_finished_r <= 0;
	end
	else
	begin
		o_a_pow_d_r <= o_a_pow_d_w;
		o_finished_r <= o_finished_w;
		state_r <= state_w;
		t_r <= t_w;
		m_r <= m_w;
		counter_r <= counter_w;
		Prep_start_r <= Prep_start_w;
		Mont_t_start_r <= Mont_t_start_w;
		Mont_m_start_r <= Mont_m_start_w;
		Mont_t_input_a_r <= Mont_t_input_a_w;
		Mont_t_input_b_r <= Mont_t_input_b_w;
		Mont_m_input_a_r <= Mont_m_input_a_w;
		Mont_m_input_b_r <= Mont_m_input_b_w;
		encryptdata_r <= encryptdata_w;
		t_finished_r <= t_finished_w;
		m_finished_r <= m_finished_w;
	end
end

endmodule
