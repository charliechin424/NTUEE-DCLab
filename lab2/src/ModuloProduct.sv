module ModuloProduct(
    input clk,
    input i_rst,
    input i_str,
    input [255:0] N,
	input [256:0] a,
	input [255:0] b,
	input [8:0] k,
	output[255:0] m,
	output o_fin
);

    parameter S_IDLE = 1'b0;
    parameter S_RUN  = 1'b1;

    logic [257:0] t_r;  //overflow
    logic [257:0] t_w;
    logic state_r;
    logic state_w;
    logic [8:0]i_r;
    logic [8:0]i_w;
    
    logic [257:0] m_r;
    logic [257:0] m_w;
    logic o_fin_r;
    logic o_fin_w;

    assign m     = m_r[255:0];
    assign o_fin = o_fin_r;

    always_comb begin
        
        t_w     = t_r;
        state_w = state_r;
        i_w     = i_r;
        m_w     = m_r;
        o_fin_w = o_fin_r;
        
        case(state_r)
            S_IDLE: begin
                o_fin_w = 0;
                if(i_str) begin
                    t_w     = b;
                    m_w     = 0;
                    state_w = S_RUN;
                    i_w     = 0;
                end
            end
            S_RUN: begin
                if(i_r <= k) begin
                    if (a[i_r] == 1'b1) begin
                        if (m_r + t_r >= N) begin
                            m_w = m_r + t_r - N; 
                        end
                        else begin
                            m_w = m_r + t_r;
                        end
                    end
                    if (t_r + t_r > N) begin   
                        t_w = t_r + t_r - N;
                    end
                    else begin
                        t_w = t_r + t_r;
                    end
                    i_w = i_r + 9'b1;
                end
                else begin
                    state_w = S_IDLE;
                    o_fin_w = 1'b1;
                end
            end
        endcase

    end

    always_ff @( posedge clk or posedge i_rst ) begin
        if(i_rst) begin
            t_r     <= 0;
            m_r     <= 0;
            o_fin_r <= 0;
            m_r     <= 0;
            state_r <= S_IDLE;
        end
        else begin
            t_r     <= t_w;
            m_r     <= m_w;
            o_fin_r <= o_fin_w;
            i_r     <= i_w;
            state_r <= state_w;
        end
    end

    
endmodule
