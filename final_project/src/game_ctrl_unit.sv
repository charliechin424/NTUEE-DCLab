module game_ctrl_unit
(
 input i_clk,    
 input i_rst_n,   
 
 input [3:0] i_key_P1,
 input [3:0] i_key_P2,
 input key0,
 input key1,
 input key2,
 input key3,
 
 input [5:0] P1_cube_x [15:0],
 input [5:0] P1_cube_y [15:0],
 input [5:0] P2_cube_x [15:0],
 input [5:0] P2_cube_y [15:0],
 input [15:0] P1_is_exist,
 input [15:0] P2_is_exist,

 input i_hit_wall1,   
 input i_hit_wall2,
 input i_hit_body1,   
 input i_hit_body2,
 input [11:0] i_bcd_data1, 
 input [11:0] i_bcd_data2,
 
 output [1:0] o_game_status, 
 output o_red_win,
 output o_green_win
);
 
 localparam S_RESTART = 2'b00;   
 localparam S_START = 2'b01; 
 localparam S_PLAY = 2'b10;   
 localparam S_DIE = 2'b11;  
 
 logic [31:0] flash_cnt, flash_cnt_nxt; 
 logic [1:0] state, state_nxt;

 logic green_win, green_win_nxt;
 logic red_win, red_win_nxt;

 assign o_game_status = state;
 assign o_green_win = green_win;
 assign o_red_win = red_win;

 always_comb begin
 flash_cnt_nxt = flash_cnt;
 state_nxt = state;
 red_win_nxt = red_win;
 green_win_nxt = green_win;
  case(state)
   S_RESTART: begin  
    if(key0) begin
      state_nxt = S_START; 
    end else begin
      state_nxt = S_RESTART;
    end
   end

   S_START: begin
    if ((| i_key_P1 )|| (| i_key_P2)) begin 
     state_nxt = S_PLAY;
     green_win_nxt = 0;
     red_win_nxt = 0;
    end else begin
     state_nxt = S_START;
    end
   end

   S_PLAY: begin
    if(i_hit_wall1 || i_hit_body1) begin 
      state_nxt = S_DIE;
      red_win_nxt = 1;
      green_win_nxt = 0;
    end 
    else if (i_hit_wall2 || i_hit_body2) begin
      state_nxt = S_DIE;
      green_win_nxt = 1;
      red_win_nxt = 0;
    end 
    else if (
      (P1_cube_y[0] == P2_cube_y[1] && P1_cube_x[0] == P2_cube_x[1] && P2_is_exist[1] == 1)||
      (P1_cube_y[0] == P2_cube_y[2] && P1_cube_x[0] == P2_cube_x[2] && P2_is_exist[2] == 1)||
      (P1_cube_y[0] == P2_cube_y[3] && P1_cube_x[0] == P2_cube_x[3] && P2_is_exist[3] == 1)||
      (P1_cube_y[0] == P2_cube_y[4] && P1_cube_x[0] == P2_cube_x[4] && P2_is_exist[4] == 1)||
      (P1_cube_y[0] == P2_cube_y[5] && P1_cube_x[0] == P2_cube_x[5] && P2_is_exist[5] == 1)||
      (P1_cube_y[0] == P2_cube_y[6] && P1_cube_x[0] == P2_cube_x[6] && P2_is_exist[6] == 1)||
      (P1_cube_y[0] == P2_cube_y[7] && P1_cube_x[0] == P2_cube_x[7] && P2_is_exist[7] == 1)||
      (P1_cube_y[0] == P2_cube_y[8] && P1_cube_x[0] == P2_cube_x[8] && P2_is_exist[8] == 1)||
      (P1_cube_y[0] == P2_cube_y[9] && P1_cube_x[0] == P2_cube_x[9] && P2_is_exist[9] == 1)||
      (P1_cube_y[0] == P2_cube_y[10] && P1_cube_x[0] == P2_cube_x[10] && P2_is_exist[10] == 1)||
      (P1_cube_y[0] == P2_cube_y[11] && P1_cube_x[0] == P2_cube_x[11] && P2_is_exist[11] == 1)||
      (P1_cube_y[0] == P2_cube_y[12] && P1_cube_x[0] == P2_cube_x[12] && P2_is_exist[12] == 1)||
      (P1_cube_y[0] == P2_cube_y[13] && P1_cube_x[0] == P2_cube_x[13] && P2_is_exist[13] == 1)||
      (P1_cube_y[0] == P2_cube_y[14] && P1_cube_x[0] == P2_cube_x[14] && P2_is_exist[14] == 1)||
      (P1_cube_y[0] == P2_cube_y[15] && P1_cube_x[0] == P2_cube_x[15] && P2_is_exist[15] == 1)) begin
      red_win_nxt = 1;
		green_win_nxt = 0;
      state_nxt = S_DIE;
    end 
    else if (
      (P2_cube_y[0] == P1_cube_y[1] && P2_cube_x[0] == P1_cube_x[1] && P1_is_exist[1] == 1)||
      (P2_cube_y[0] == P1_cube_y[2] && P2_cube_x[0] == P1_cube_x[2] && P1_is_exist[2] == 1)||
      (P2_cube_y[0] == P1_cube_y[3] && P2_cube_x[0] == P1_cube_x[3] && P1_is_exist[3] == 1)||
      (P2_cube_y[0] == P1_cube_y[4] && P2_cube_x[0] == P1_cube_x[4] && P1_is_exist[4] == 1)||
      (P2_cube_y[0] == P1_cube_y[5] && P2_cube_x[0] == P1_cube_x[5] && P1_is_exist[5] == 1)||
      (P2_cube_y[0] == P1_cube_y[6] && P2_cube_x[0] == P1_cube_x[6] && P1_is_exist[6] == 1)||
      (P2_cube_y[0] == P1_cube_y[7] && P2_cube_x[0] == P1_cube_x[7] && P1_is_exist[7] == 1)||
      (P2_cube_y[0] == P1_cube_y[8] && P2_cube_x[0] == P1_cube_x[8] && P1_is_exist[8] == 1)||
      (P2_cube_y[0] == P1_cube_y[9] && P2_cube_x[0] == P1_cube_x[9] && P1_is_exist[9] == 1)||
      (P2_cube_y[0] == P1_cube_y[10] && P2_cube_x[0] == P1_cube_x[10] && P1_is_exist[10] == 1)||
      (P2_cube_y[0] == P1_cube_y[11] && P2_cube_x[0] == P1_cube_x[11] && P1_is_exist[11] == 1)||
      (P2_cube_y[0] == P1_cube_y[12] && P2_cube_x[0] == P1_cube_x[12] && P1_is_exist[12] == 1)||
      (P2_cube_y[0] == P1_cube_y[13] && P2_cube_x[0] == P1_cube_x[13] && P1_is_exist[13] == 1)||
      (P2_cube_y[0] == P1_cube_y[14] && P2_cube_x[0] == P1_cube_x[14] && P1_is_exist[14] == 1)||
      (P2_cube_y[0] == P1_cube_y[15] && P2_cube_x[0] == P1_cube_x[15] && P1_is_exist[15] == 1)) begin
      green_win_nxt = 1;
      state_nxt = S_DIE;
    end 
    else begin
      state_nxt = S_PLAY;
      green_win_nxt = 0;
      red_win_nxt = 0;
    end
   end

   S_DIE:begin
    if(flash_cnt <= 50000000) begin  
     flash_cnt_nxt = flash_cnt + 1'b1; 
    end else if((| i_key_P1 )|| (| i_key_P2)) begin 
     flash_cnt_nxt = 0;
     state_nxt = S_RESTART;
    end else begin
     state_nxt = S_DIE;
    end
   end 

   default:begin                
    state_nxt = S_RESTART; 
   end

  endcase
 end

 always_ff @(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n) begin
   flash_cnt <= 0;
   state <= S_RESTART; 
   green_win <= 0;
   red_win <= 0;
  end else begin
   flash_cnt <= flash_cnt_nxt;
   state <= state_nxt;
   green_win <= green_win_nxt;
   red_win <= red_win_nxt;
  end
 end
 
endmodule