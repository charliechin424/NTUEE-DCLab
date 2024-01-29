module snake_top
(
   	input clk,				
	input clk_25m,
	input rst_n,			
	
	input key0,  		
	input key1, 		
	input key2,   
	input key3, 		 	
	input [2:0]sw,			

	output vga_hsync,		
	output vga_vsync,	
   	output vga_clk,			
   	output vga_blank_n,		
   	output vga_sync_n,		
	output [23:0]vga_rgb,	
	
	output [6:0]hex0,		
	output [6:0]hex1,		
	output [6:0]hex2,		
	output [6:0]hex3,
	output [6:0]hex4,
	output [6:0]hex5,
	output [6:0]hex6,
	output [6:0]hex7,

	output [8:0] LEDG,
	output [17:0] LEDR,

	inout PS2_CLK,
	inout PS2_DAT
);
	logic [1:0]snake_show1;	
	logic [1:0]snake_show2;

	logic [9:0]pos_x;		
	logic [9:0]pos_y;		

	logic [5:0]boom_x_1;	
	logic [4:0]boom_y_1;	
	logic [5:0]boom_x_2;		
	logic [4:0]boom_y_2;	

	logic [5:0]head_x1;		
	logic [5:0]head_y1;		
	logic [5:0]head_x2;		
	logic [5:0]head_y2;

	logic [3:0] P1_image;
	logic [3:0] P2_image;

	logic [24:0] speed1, speed2;

	logic [5:0] boom1_x_1, boom1_y_1, boom2_x_1, boom2_y_1, boom3_x_1, boom3_y_1;
	logic [5:0] boom1_x_2, boom1_y_2, boom2_x_2, boom2_y_2, boom3_x_2, boom3_y_2;

	logic [1:0] direct1, direct2;
	
	// apple
	logic [5:0] apple_x1;
	logic [4:0] apple_y1;
	logic [5:0] apple_x2;
	logic [4:0] apple_y2;
	logic [5:0] apple_x3;
	logic [4:0] apple_y3;
	logic [2:0] apple_exist;

	logic add_cube1;	
	logic add_cube2;

	logic add_cube1_apple1;
	logic add_cube2_apple1;
	logic add_cube1_apple2;
	logic add_cube2_apple2;
	logic add_cube1_apple3;
	logic add_cube2_apple3;

	assign add_cube1 = add_cube1_apple1 | add_cube1_apple2 | add_cube1_apple3;
	assign add_cube2 = add_cube2_apple1 | add_cube2_apple2 | add_cube2_apple3;

	logic boom_active1_1;
	logic boom_active2_1;
	logic boom_active1_2;
	logic boom_active2_2;

	logic boom_display_1;
	logic boom_display_2;

	logic outside1_1, outside2_1, outside3_1;
	logic outside1_2, outside2_2, outside3_2;

	logic [5:0] cube_x1 [15:0];
	logic [5:0] cube_y1 [15:0];
	logic [5:0] cube_x2 [15:0];
	logic [5:0] cube_y2 [15:0];

	logic [15:0] is_exist1, is_exist2;

	logic [1:0] game_status;	
	logic green_win, red_win;

	logic ready_next_boom_1;
	logic ready_next_boom_2;
	
	logic hit_wall1;			
	logic hit_body1;				
	logic hit_wall2;			
	logic hit_body2;	

	logic [31:0] cnt1, cnt1_nxt;
	logic [31:0] cnt2, cnt2_nxt;
	logic [31:0] cnt3, cnt3_nxt;
	logic apple1, apple1_nxt;
	logic apple2, apple2_nxt;
	logic apple3, apple3_nxt;

	logic [2:0] apple_cnt, apple_cnt_nxt;

	logic [11:0] bcd_data1;	
	logic [11:0] bcd_data2;

	logic P1_key_up, P1_key_down, P1_key_left, P1_key_right;
	logic P2_key_up, P2_key_down, P2_key_left, P2_key_right;
		
	assign vga_clk = clk_25m;
	assign vga_sync_n = 1'b0;   

	PS2_key PS2_key (
		.i_clk(clk_25m),
		.i_rst_n(rst_n),
		.i_key_clk(PS2_CLK),
		.i_key_data(PS2_DAT),
		.o_P1_UP(P1_key_up),
		.o_P1_DOWN(P1_key_down),
		.o_P1_LEFT(P1_key_left),
		.o_P1_RIGHT(P1_key_right),
		.o_P2_UP(P2_key_up),
    	.o_P2_DOWN(P2_key_down),
    	.o_P2_LEFT(P2_key_left),
    	.o_P2_RIGHT(P2_key_right)
	);


	// assign LEDG[8:5] = { P1_key_up, P1_key_down, P1_key_left, P1_key_right };
	assign LEDR[17:14] = { P2_key_up, P2_key_down, P2_key_left, P2_key_right };
	
	apple_generate #(0) Apple1 (	
		.i_clk(clk_25m),
		.i_rst_n(rst_n),
		.i_head_x1(head_x1),
		.i_head_y1(head_y1),
		.i_head_x2(head_x2),
		.i_head_y2(head_y2),
		.o_apple_x(apple_x1),
		.o_apple_y(apple_y1),
		.o_apple_exist(apple_exist[0]),
		.o_add_cube1(add_cube1_apple1),
		.o_add_cube2(add_cube2_apple1)
	);

	apple_generate #(2) Apple2 (	
		.i_clk(clk_25m),
		.i_rst_n(rst_n),
		.i_head_x1(head_x1),
		.i_head_y1(head_y1),
		.i_head_x2(head_x2),
		.i_head_y2(head_y2),
		.o_apple_x(apple_x2),
		.o_apple_y(apple_y2),
		.o_apple_exist(apple_exist[1]),
		.o_add_cube1(add_cube1_apple2),
		.o_add_cube2(add_cube2_apple2)
	);

	apple_generate #(4) Apple3 (	
		.i_clk(clk_25m),
		.i_rst_n(rst_n),
		.i_head_x1(head_x1),
		.i_head_y1(head_y1),
		.i_head_x2(head_x2),
		.i_head_y2(head_y2),
		.o_apple_x(apple_x3),
		.o_apple_y(apple_y3),
		.o_apple_exist(apple_exist[2]),
		.o_add_cube1(add_cube1_apple3),
		.o_add_cube2(add_cube2_apple3)
	);
	
	snake S1 (
	    .clk(clk_25m),
		.rst_n(rst_n),
		.x(10),
		.y(5),
		.score(bcd_data1 + bcd_data2),
		.key0_right(P1_key_right),
		.key1_left(P1_key_left),
		.key2_down(P1_key_down),
		.key3_up(P1_key_up),
		.pos_x(pos_x),
		.pos_y(pos_y),
		.boom1_x_1(boom1_x_1),
	  .boom1_y_1(boom1_y_1),
	  .boom2_x_1(boom2_x_1),
	  .boom2_y_1(boom2_y_1),
	  .boom3_x_1(boom3_x_1),
	  .boom3_y_1(boom3_y_1),
	  .boom1_x_2(boom1_x_2),
	  .boom1_y_2(boom1_y_2),
	  .boom2_x_2(boom2_x_2),
	  .boom2_y_2(boom2_y_2),
	  .boom3_x_2(boom3_x_2),
	  .boom3_y_2(boom3_y_2),
		.o_snake_image(P1_image),
		.add_cube(add_cube1),
		.game_status(game_status),
		.head_x(head_x1),
		.head_y(head_y1),
		.o_direct(direct1),
		.o_cube_x(cube_x1),
		.o_cube_y(cube_y1),
		.o_speed(speed1),
		.o_is_exist(is_exist1),
		.o_hit_body(hit_body1),
		.hit_wall(hit_wall1),
		.snake_show(snake_show1),
		
		.LEDG(LEDG[3:0])
	);

	snake S2 (
	   	.clk(clk_25m),
		.rst_n(rst_n),
		.x(10),
		.y(20),
		.score(bcd_data1 + bcd_data2),
		.key0_right(P2_key_right),
		.key1_left(P2_key_left),
		.key2_down(P2_key_down),
		.key3_up(P2_key_up),
		.pos_x(pos_x),
		.pos_y(pos_y),
		.boom1_x_1(boom1_x_1),
        .boom1_y_1(boom1_y_1),
        .boom2_x_1(boom2_x_1),
        .boom2_y_1(boom2_y_1),
        .boom3_x_1(boom3_x_1),
        .boom3_y_1(boom3_y_1),
        .boom1_x_2(boom1_x_2),
        .boom1_y_2(boom1_y_2),
        .boom2_x_2(boom2_x_2),
        .boom2_y_2(boom2_y_2),
        .boom3_x_2(boom3_x_2),
        .boom3_y_2(boom3_y_2),
		.o_snake_image(P2_image),
		.add_cube(add_cube2),
		.game_status(game_status),
		.head_x(head_x2),
		.head_y(head_y2),
		.o_direct(direct2),
		.o_cube_x(cube_x2),
		.o_cube_y(cube_y2),
		.o_speed(speed2),
		.o_is_exist(is_exist2),
		.o_hit_body(hit_body2),
		.hit_wall(hit_wall2),
		.snake_show(snake_show2)
	);

	boom_generate U5_1(
		.seed(35),
		.i_clk(clk_25m),
		.i_rst_n(rst_n),
		.i_head_x1(head_x1),
		.i_head_y1(head_y1),
		.i_head_x2(head_x2),
		.i_head_y2(head_y2),
		.ready_next_boom(ready_next_boom_1),
		.o_boom_x(boom_x_1),
		.o_boom_y(boom_y_1),
		.o_boom_active1(boom_active1_1),
		.o_boom_active2(boom_active2_1),
		.o_boom_display(boom_display_1)
	);

	boom_generate U5_2(
		.seed(25),
		.i_clk(clk_25m),
		.i_rst_n(rst_n),
		.i_head_x1(head_x1),
		.i_head_y1(head_y1),
		.i_head_x2(head_x2),
		.i_head_y2(head_y2),
		.ready_next_boom(ready_next_boom_2),
		.o_boom_x(boom_x_2),
		.o_boom_y(boom_y_2),
		.o_boom_active1(boom_active1_2),
		.o_boom_active2(boom_active2_2),
		.o_boom_display(boom_display_2)
	);

	boom_movement U6_1 (
		.clk(clk_25m),
		.rst_n(rst_n),
		.player1_direct(direct1),
		.player2_direct(direct2),
		.head_x1(head_x1),
		.head_y1(head_y1),
		.head_x2(head_x2),
		.head_y2(head_y2),
		.boom_active1(boom_active1_1),
		.boom_active2(boom_active2_1),
		.speed(speed1 >> 2),
		.boom_display(boom_display_1),
		.o_boom1_x(boom1_x_1),
		.o_boom1_y(boom1_y_1),
		.o_boom2_x(boom2_x_1),
		.o_boom2_y(boom2_y_1),
		.o_boom3_x(boom3_x_1),
		.o_boom3_y(boom3_y_1),
		.o_outside1(outside1_1),
		.o_outside2(outside2_1),
		.o_outside3(outside3_1),
		.o_ready_next_boom(ready_next_boom_1)
	);

	boom_movement U6_2(
		.clk(clk_25m),
		.rst_n(rst_n),
		.player1_direct(direct1),
		.player2_direct(direct2),
		.head_x1(head_x1),
		.head_y1(head_y1),
		.head_x2(head_x2),
		.head_y2(head_y2),
		.boom_active1(boom_active1_2),
		.boom_active2(boom_active2_2),
		.speed(speed1 >> 2),
		.boom_display(boom_display_2),
		.o_boom1_x(boom1_x_2),
		.o_boom1_y(boom1_y_2),
		.o_boom2_x(boom2_x_2),
		.o_boom2_y(boom2_y_2),
		.o_boom3_x(boom3_x_2),
		.o_boom3_y(boom3_y_2),
		.o_outside1(outside1_2),
		.o_outside2(outside2_2),
		.o_outside3(outside3_2),
		.o_ready_next_boom(ready_next_boom_2)
	);

	VGA_control U3 (
		.clk(clk_25m),
		.rst_n(rst_n),

		.game_status(game_status),
		.bcd_data(bcd_data),

		.boom_x_1(boom_x_1),
		.boom_y_1(boom_y_1),
		.boom1_x_1(boom1_x_1),
		.boom1_y_1(boom1_y_1),
		.boom2_x_1(boom2_x_1),
		.boom2_y_1(boom2_y_1),
		.boom3_x_1(boom3_x_1),
		.boom3_y_1(boom3_y_1),
		.boom_display_1(boom_display_1),
		.boom_x_2(boom_x_2),
		.boom_y_2(boom_y_2),
		.boom1_x_2(boom1_x_2),
		.boom1_y_2(boom1_y_2),
		.boom2_x_2(boom2_x_2),
		.boom2_y_2(boom2_y_2),
		.boom3_x_2(boom3_x_2),
		.boom3_y_2(boom3_y_2),
		.boom_display_2(boom_display_2),

		.outside1_1(outside1_1),
		.outside2_1(outside2_1),
		.outside3_1(outside3_1),

		.outside1_2(outside1_2),
		.outside2_2(outside2_2),
		.outside3_2(outside3_2),
		
		.snake_show1(snake_show1),
		.snake_show2(snake_show2),
		.snake_image1(P1_image),
        .snake_image2(P2_image),
		
		.apple_x1(apple_x1),
		.apple_y1(apple_y1),
		.apple_x2(apple_x2),
		.apple_y2(apple_y2),
		.apple_x3(apple_x3),
		.apple_y3(apple_y3),
		.i_apple_exist(apple_exist),

		.red_win(red_win),
		.green_win(green_win),
		.pos_x(pos_x),
		.pos_y(pos_y),
		.vga_rgb(vga_rgb),
		.vga_hs(vga_hsync),
		.vga_vs(vga_vsync),
		.vga_blank_n(vga_blank_n)
	);

	score_ctrl u4(
		.clk(clk_25m),
		.rst_n(rst_n),
		.add_cube(add_cube1),
		.game_status(game_status),
		.bcd_data(bcd_data1) /
	);

	score_ctrl u5(
		.clk(clk_25m),
		.rst_n(rst_n),
		.add_cube(add_cube2),
		.game_status(game_status),
		.bcd_data(bcd_data2)
	);

	
	game_ctrl_unit U0 (  
		.i_clk(clk_25m),
		.i_rst_n(rst_n),
		.i_key_P1({P1_key_up, P1_key_down, P1_key_left, P1_key_right}),
		.i_key_P2({P2_key_up, P2_key_down, P2_key_left, P2_key_right}),
		.key0(key0),
		.key1(key1),
		.key2(key2),
		.key3(key3),
		.P1_cube_x(cube_x1),
		.P1_cube_y(cube_y1),
		.P2_cube_x(cube_x2),
		.P2_cube_y(cube_y2),
		.P1_is_exist(is_exist1),
		.P2_is_exist(is_exist2),
		.i_hit_wall1(hit_wall1),
		.i_hit_wall2(hit_wall2),
		.i_hit_body1(hit_body1),
		.i_hit_body2(hit_body2),
		.i_bcd_data1(bcd_data1),
		.o_game_status(game_status),
		.o_green_win(green_win),
		.o_red_win(red_win)
	);
		
endmodule
