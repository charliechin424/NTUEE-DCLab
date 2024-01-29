module boom_generate(
  input i_rst_n,
  input i_clk,  

  input [10:0]  seed,
  
  input [5:0] i_head_x1,
  input [5:0] i_head_y1,
  input [5:0] i_head_x2,
  input [5:0] i_head_y2,

  input ready_next_boom,
  
  output [5:0] o_boom_x,
  output [4:0] o_boom_y,

  output o_boom_active1,
  output o_boom_active2,

  output o_boom_display
);

  logic [10:0]  random_num, random_num_nxt;
  logic boom_active1, boom_active_nxt1, boom_active2, boom_active_nxt2;
  logic [5:0] boom_x, boom_x_nxt;
  logic [4:0] boom_y, boom_y_nxt;
  logic boom_display, boom_display_nxt;

  assign o_boom_x = boom_x;
  assign o_boom_y = boom_y;
  assign o_boom_active1 = boom_active1;
  assign o_boom_active2 = boom_active2;
  assign o_boom_display = boom_display;

  always_comb begin
    random_num_nxt = random_num + seed;
    if (ready_next_boom) begin
      boom_x_nxt = (random_num[10:5] > 38) ? (random_num[10:5] - 25) : (random_num[10:5] <= 1) ? 2 : random_num[10:5];
      boom_y_nxt = (random_num[4:0] > 28) ? (random_num[4:0] - 3) : (random_num[4:0] <= 1) ? 2 : random_num[4:0];
    end else begin
      boom_x_nxt = boom_x;
      boom_y_nxt = boom_y;
    end

    if (ready_next_boom) begin
      boom_display_nxt = 1;
    end else if((boom_x == i_head_x1 && boom_y == i_head_y1) || (boom_x == i_head_x2 && boom_y == i_head_y2)) begin
      boom_display_nxt = 0;
    end else begin
      boom_display_nxt = boom_display;
    end

    if (boom_x == i_head_x1 && boom_y == i_head_y1) begin
      boom_active_nxt1 = 1;
    end else begin
      boom_active_nxt1 = 0;
    end

    if (boom_x == i_head_x2 && boom_y == i_head_y2) begin
      boom_active_nxt2 = 1;
    end else begin
      boom_active_nxt2 = 0;
    end
  end

always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)  begin
    boom_x      <= seed;
    boom_y      <= seed;
    boom_active1 <= 0;
    boom_active2 <= 0;
    boom_display <= 1;
  end else begin
    boom_x <= boom_x_nxt;
    boom_y <= boom_y_nxt;
    boom_active1 <= boom_active_nxt1;
    boom_active2 <= boom_active_nxt2;
    boom_display <= boom_display_nxt;
  end
end

always_ff @(posedge i_clk ) begin
  random_num <= random_num_nxt;
end

endmodule