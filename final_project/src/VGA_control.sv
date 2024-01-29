module VGA_control
(
	input clk,	
	input rst_n,
	
	input [1:0] snake_show1,			
	input [1:0] snake_show2,
	input [3:0] snake_image1,
	input [3:0] snake_image2,
	input [1:0] game_status,
	input [11:0] bcd_data,	
	input [5:0] apple_x1,
	input [4:0] apple_y1,
	input [5:0] apple_x2,
	input [4:0] apple_y2,
	input [5:0] apple_x3,
	input [4:0] apple_y3,
	input [2:0] i_apple_exist,

	input green_win,
	input red_win,

	//boom_1 position
	input [5:0] boom_x_1,
	input [5:0] boom_y_1,
	input [5:0] boom1_x_1,
	input [5:0] boom1_y_1,
	input [5:0] boom2_x_1,
	input [5:0] boom2_y_1,
	input [5:0] boom3_x_1,
	input [5:0] boom3_y_1,
	input boom_display_1,
	input outside1_1,
	input outside2_1,
	input outside3_1,
	
	//boom_2 position
	input [5:0] boom_x_2,
	input [5:0] boom_y_2,
	input [5:0] boom1_x_2,
	input [5:0] boom1_y_2,
	input [5:0] boom2_x_2,
	input [5:0] boom2_y_2,
	input [5:0] boom3_x_2,
	input [5:0] boom3_y_2,
	input boom_display_2,
	input outside1_2,
	input outside2_2,
	input outside3_2,
	
	output [9:0] pos_x,	
	output [9:0] pos_y,	
	
	output vga_hs,		
	output vga_vs,		
	output [23:0] vga_rgb,
	output vga_blank_n		
);
	

	localparam RESTART = 2'b00;		
	localparam START = 2'b01;			
	localparam PLAY = 2'b10;			
	localparam DIE = 2'b11;				

	localparam NONE = 2'b00;
	localparam HEAD = 2'b01;
	localparam BODY = 2'b10;
	localparam WALL = 2'b11;
	
    localparam	RED    = 24'b11111111_00000000_00000000; 
    localparam	GREEN  = 24'b00000000_11111111_00000000; 
    localparam	BLUE   = 24'b00000000_00000000_11111111;
	localparam	YELLOW = 24'b11111111_11111111_00000000;
    localparam	PINK   = 24'b11111111_00000000_11111111; 
	localparam	WHITE  = 24'b11111111_11111111_11111111;
	localparam	BLACK  = 24'b00000000_00000000_00000000;
	

    parameter	HS_A = 96;	
    parameter	HS_B = 48;	
    parameter	HS_C = 640;	
    parameter	HS_D = 16;	
    parameter	HS_E = 800;	

    parameter	VS_A = 2;	
    parameter	VS_B = 33;	
    parameter	VS_C = 480;	
    parameter	VS_D = 10;	
    parameter	VS_E = 525;	
    
    parameter	HS_WIDTH = 10;
    parameter	VS_WIDTH = 10;	
	 
    localparam	SIDE_W  = 11'd16;	
    localparam	BLOCK_W = 11'd16;	
	 
	parameter	height = 480;		
	parameter	width  = 640;		
	
	parameter	CHAR_W = 160;  	
	parameter	CHAR_H = 32;   	

	logic	[HS_WIDTH - 1:0] cnt_hs; 
    logic	[VS_WIDTH - 1:0] cnt_vs;

	logic	[27:0]	cnt;
	logic	[18:0]	cnt_rom_address1; 
	logic	[18:0]	cnt_rom_address2;
	logic   [18:0]  cnt_rom_address;
	logic	[11:0]	addr_h;   
	logic	[11:0]	addr_v;   
		 
    logic en_hs;	
    logic en_vs;	
    logic en;	
   
	logic flag_clear_rom_address1;
	logic flag_clear_rom_address2;
	logic flag_clear_rom_address;
	logic flag_begin_h;			 
	logic flag_begin_v;			  
	logic picture_flag_enable;		  
	
	logic [23:0] rom_data;
	logic [23:0] snake_cover_data;
	logic [23:0] snake_image_data_1;
	logic [23:0] snake_image_data_2;
	logic [23:0] apple_image_data;
	logic [23:0] boom_image_data;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            cnt_hs <= 0;
		end else begin
            if (cnt_hs < HS_E - 1) begin
                cnt_hs <= cnt_hs + 1'b1;
			end else begin
                cnt_hs <= 0;
			end
		end
	end
					       
    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            cnt_vs <= 0;
		end else begin
            if (cnt_hs == HS_E - 1) begin
                if (cnt_vs < VS_E - 1) begin
                    cnt_vs <= cnt_vs + 1'b1;
				end else begin
                    cnt_vs <= 0;
				end
			end else begin
                cnt_vs <= cnt_vs;
			end
		end
	end
					 
    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            vga_hs <= 1'b1;
		end else begin
            if (cnt_hs < HS_A - 1) begin 
                vga_hs <= 1'b0;
			end else begin
                vga_hs <= 1'b1;
			end
		end
	end
             
    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            vga_vs <= 1'b1;
		end else begin
            if (cnt_vs < VS_A - 1) begin
                vga_vs <= 1'b0;
			end else begin
                vga_vs <= 1'b1;
			end
		end
	end

	assign en_hs = (cnt_hs > HS_A + HS_B - 1)&& (cnt_hs < HS_E - HS_D);		
	assign en_vs = (cnt_vs > VS_A + VS_B - 1) && (cnt_vs < VS_E - VS_D);	
	assign en = en_hs && en_vs;
	assign vga_blank_n = en; 
		            
	assign pos_x = en ? (cnt_hs - (HS_A + HS_B - 1'b1)) : 0;
	assign pos_y = en ? (cnt_vs - (VS_A + VS_B - 1'b1)) : 0;
	 
	always_ff @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			cnt <= 0;
		end else if (game_status == RESTART) begin
			vga_rgb<= 24'b000000000000000000000000;
		end else if (game_status == PLAY | game_status == START) begin 
			cnt <=0;
			if (pos_x[9:4] == apple_x1 && pos_y[9:4] == apple_y1 && i_apple_exist[0]) begin
				// apple 1
				vga_rgb = apple_image_data;
			end else if (pos_x[9:4] == apple_x2 && pos_y[9:4] == apple_y2 && i_apple_exist[1]) begin
				// apple 2
				vga_rgb = apple_image_data;
			end else if (pos_x[9:4] == apple_x3 && pos_y[9:4] == apple_y3 && i_apple_exist[2]) begin
				// apple 3
				vga_rgb = apple_image_data;
			end 
			else if (boom_display_1 && pos_x[9:4] == boom_x_1 && pos_y[9:4] == boom_y_1) begin
				vga_rgb = boom_image_data;
			end else if (!boom_display_1 && ((pos_x[9:4] == boom1_x_1 && pos_y[9:4] == boom1_y_1 && !outside1_1) || (pos_x[9:4] == boom2_x_1 && pos_y[9:4] == boom2_y_1 && !outside2_1) || (pos_x[9:4] == boom3_x_1&& pos_y[9:4] == boom3_y_1 && !outside3_1))) begin
				vga_rgb = boom_image_data;
			end else if (boom_display_2 && pos_x[9:4] == boom_x_2 && pos_y[9:4] == boom_y_2) begin
				vga_rgb = boom_image_data;
			end else if (!boom_display_2 && ((pos_x[9:4] == boom1_x_2 && pos_y[9:4] == boom1_y_2 && !outside1_2) || (pos_x[9:4] == boom2_x_2 && pos_y[9:4] == boom2_y_2 && !outside2_2) || (pos_x[9:4] == boom3_x_2&& pos_y[9:4] == boom3_y_2 && !outside3_2))) begin
				vga_rgb = boom_image_data;
			end	
			else if (snake_show1 == NONE && snake_show2 == NONE) begin
				// background
				vga_rgb = BLACK; 
			end else if (snake_show1 == WALL && snake_show2 == WALL) begin
				// Wall
				vga_rgb = RED;
			end else if (snake_show1 == HEAD | snake_show1 == BODY | snake_show2 == HEAD | snake_show2 == BODY) begin
				// snake
				if (snake_show1 == HEAD) begin
					vga_rgb = snake_image_data_1;
				end else if (snake_show1 == BODY) begin
					vga_rgb = snake_image_data_1;
				end else if (snake_show2 == HEAD) begin
					vga_rgb = snake_image_data_2;
				end else if (snake_show2 == BODY) begin
					vga_rgb = snake_image_data_2;
				end
			end else begin
				vga_rgb <= BLACK;
			end
		end

		else if (game_status == DIE )  begin
			if(cnt < 50000000)begin
				cnt<=cnt+1;
				if (pos_x[9:4] == apple_x1 && pos_y[9:4] == apple_y1 && i_apple_exist[0]) begin
					// apple 1
					vga_rgb = apple_image_data;
				end else if (pos_x[9:4] == apple_x2 && pos_y[9:4] == apple_y2 && i_apple_exist[1]) begin
					// apple 2
					vga_rgb = apple_image_data;
				end else if (pos_x[9:4] == apple_x3 && pos_y[9:4] == apple_y3 && i_apple_exist[2]) begin
					// apple 3
					vga_rgb = apple_image_data;
				end 
				else if (boom_display_1 && pos_x[9:4] == boom_x_1 && pos_y[9:4] == boom_y_1) begin
					vga_rgb = boom_image_data;
				end else if (!boom_display_1 && ((pos_x[9:4] == boom1_x_1 && pos_y[9:4] == boom1_y_1 && !outside1_1) || (pos_x[9:4] == boom2_x_1 && pos_y[9:4] == boom2_y_1 && !outside2_1) || (pos_x[9:4] == boom3_x_1&& pos_y[9:4] == boom3_y_1 && !outside3_1))) begin
					vga_rgb = boom_image_data;
				end	else if (boom_display_2 && pos_x[9:4] == boom_x_2 && pos_y[9:4] == boom_y_2) begin
					vga_rgb = boom_image_data;
				end else if (!boom_display_2 && ((pos_x[9:4] == boom1_x_2 && pos_y[9:4] == boom1_y_2 && !outside1_2) || (pos_x[9:4] == boom2_x_2 && pos_y[9:4] == boom2_y_2 && !outside2_2) || (pos_x[9:4] == boom3_x_2&& pos_y[9:4] == boom3_y_2 && !outside3_2))) begin
					vga_rgb = boom_image_data;
				end	
				else if (snake_show1 == NONE && snake_show2 == NONE) begin
					vga_rgb = BLACK; 
				end else if (snake_show1 == WALL && snake_show2 == WALL) begin
					vga_rgb = RED;
				end else if (snake_show1 == HEAD | snake_show1 == BODY | snake_show2 == HEAD | snake_show2 == BODY) begin
					if (snake_show1 == HEAD) begin
						vga_rgb = snake_image_data_1;
					end else if (snake_show1 == BODY) begin
						vga_rgb = snake_image_data_1;
					end else if (snake_show2 == HEAD) begin
						vga_rgb = snake_image_data_2;
					end else if (snake_show2 == BODY) begin
						vga_rgb = snake_image_data_2;
					end
				end else begin
					vga_rgb <= BLACK;
				end
			end else if(cnt >= 50000000) begin
				if (red_win) begin
					if (pos_x[9:4] >= 15 && pos_x[9:4] < 25 && pos_y[9:4] >= 8 && pos_y[9:4] < 10 && char_red_win[char_y][159-char_x] == 1'b1) begin
						vga_rgb <= RED;
					end else begin
						vga_rgb <= BLACK;
					end
				end else begin
					if (pos_x[9:4] >= 15 && pos_x[9:4] < 25 && pos_y[9:4] >= 8 && pos_y[9:4] < 10 && char_green_win[char_y][159-char_x] == 1'b1) begin
						vga_rgb <= GREEN;
					end else begin
						vga_rgb <= BLACK;
					end
				end
			end
			else
				vga_rgb = 24'h000000;
		end
	end

	// ###################
	// ##	snake rom	##
	// ###################
	logic [18:0] bike_rom_addr;
	logic [23:0] bike_rom_data1;
	logic [23:0] bike_rom_data2;
	assign bike_rom_addr = { pos_y[3:0], pos_x[3:0] };

	snake_image_rom_green snake_image_rom_green (
		.i_clk(clk),
    	.i_snake_image(snake_image1),
		.i_pos_x(pos_x),
		.i_pos_y(pos_y),
    	.o_snake_image_data(snake_image_data_1)
	);

	snake_image_rom_red snake_image_rom_red (
		.i_clk(clk),
    	.i_snake_image(snake_image2),
		.i_pos_x(pos_x),
		.i_pos_y(pos_y),
    	.o_snake_image_data(snake_image_data_2)
	);
	
	apple_image_rom apple_image_rom (
		.i_clk(clk),
		.i_pos_x(pos_x),
		.i_pos_y(pos_y),
    	.o_apple_image_data(apple_image_data)
	);
	
	boom_image_rom boom_image_rom (
		.i_clk(clk),
		.i_pos_x(pos_x),
		.i_pos_y(pos_y),
    	.o_boom_image_data(boom_image_data)
	);
	
	


logic    [9:0]   char_x  ; 
logic    [9:0]   char_y  ;  

logic     [159:0] char_green_win [31:0];  
logic     [159:0] char_red_win [31:0];   
 
assign  char_x  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)? (pos_x - 15*16) : 0;
assign  char_y  =   (pos_x[9:4] >=15 && pos_x[9:4] < 25 && pos_y[9:4] >= 8 && pos_y[9:4] < 10)? (pos_y - 8*16) : 0;

//字符“紅色蛇獲勝”
always_ff @(posedge clk) begin
	char_red_win[0]     <=  160'h0000000000000000000000000000000000000000;
	char_red_win[1]     <=  160'h0000000000380000000000000000000000000000; 
	char_red_win[2]     <=  160'h00c00000003e000003801c000020e1c018761e60; 
	char_red_win[3]     <=  160'h01e00000007e000003c01e002078f1f81fff1ef0; 
	char_red_win[4]     <=  160'h01e0007800783c0003800f007878e1fc1c7f9cf8;
	char_red_win[5]     <=  160'h03c3fffc00fffe0003800f001efffffe1c73dde0;
	char_red_win[6]     <=  160'h0783ce0001f07e00038187000feee1c01c71dfc0; 
	char_red_win[7]     <=  160'h07180e0001e078000381871c07e0fdc01c71dfe0; 
	char_red_win[8]     <=  160'h0f3c0e0003c0f0000381fffe03c3ff801c71fff0; 
	char_red_win[9]     <=  160'h1e3c0e000780e000339f801e07c79e001c7ffff8; 
	char_red_win[10]     <=  160'h7ff80e000f81c1c03fff80380fc78e781ff73818;
	char_red_win[11]     <=  160'h7ff00e001fffffe03bbf80381fcffffc1c70383c; 
	char_red_win[12]     <=  160'h3ee00e001f83c1c03bbff0303def0e701c7ffffe; 
	char_red_win[13]     <=  160'h11d80e007f83c1c03bbc780071fffff81c7e7600; 
	char_red_win[14]     <=  160'h03dc0e007783c1c03bbc703061ff0e001c70f700; 
	char_red_win[15]     <=  160'h079e0e000783c1c03bbc707803ff0e701c71f3c0; 
	char_red_win[16]     <=  160'h1f0e0e000783c1c03bbc70f803e7fff81c73fdf0; 
	char_red_win[17]     <=  160'h3fff0e000783c1c03bbc71f007e70e001ff7bcfe; 
	char_red_win[18]     <=  160'h3fff0e0007ffffc03bbc73e00fe70e381c7f387e; 
	char_red_win[19]     <=  160'h3f0f0e00078001c03ffc7f800ee7fffc1c7e38fc; 
	char_red_win[20]     <=  160'h181e0e00078001c03bbc7e001ee700001c7ffff0; 
	char_red_win[21]     <=  160'h1b9c0e000780001c33a078003ce700e01c7778e0;
	char_red_win[22]     <=  160'h1b8e0e000780001c03f8701c38effff01c7070e0; 
	char_red_win[23]     <=  160'h19cf0e000780001c03bc701c70e7c1f0387070e0;
	char_red_win[24]     <=  160'h19ef0e000780001c039c701ce0e0e3c03870f0e0; 
	char_red_win[25]     <=  160'h39e70e000780001c03fe701c00e077803871e0e0; 
	char_red_win[26]     <=  160'h39e70e1c0780001c3ffe701c01e03f003871c1e0;
	char_red_win[27]     <=  160'h79e00e3c0780001e7f0e701c01e03f0077f3c1c0; 
	char_red_win[28]     <=  160'h78dffffe07fffffe780c7ffe1fc1fffe77ff1fc0; 
	char_red_win[29]     <=  160'h701e000003fffffc30007ffe0fcfe3fe61fe0fc0;
	char_red_win[30]     <=  160'h00000000000000000000000007ff0078e0fc0380; 
	char_red_win[31]     <=  160'h0000000000000000000000000000000000000000;
end

//字符“綠色蛇獲勝”
always_ff @(posedge clk) begin
	char_green_win[0] <= 160'h0000000000000000000000000000000000000000;
	char_green_win[1] <= 160'h0000000000380000000000000000000000000000;
	char_green_win[2] <= 160'h0381e000003e000003801c000020e1c018761e60;
	char_green_win[3] <= 160'h03c1e000007e000003c01e002078f1f81fff1ef0;
	char_green_win[4] <= 160'h03c1c1c000783c0003800f007878e1fc1c7f9cf8;
	char_green_win[5] <= 160'h0781ffe000fffe0003800f001efffffe1c73dde0;
	char_green_win[6] <= 160'h0703c1e001f07e00038187000feee1c01c71dfc0;
	char_green_win[7] <= 160'h0e0381c001e078000381871c07e0fdc01c71dfe0;
	char_green_win[8] <= 160'h1e7381c003c0f0000381fffe03c3ff801c71fff0;
	char_green_win[9] <= 160'h1cf381c00780e000339f801e07c79e001c7ffff8;
	char_green_win[10] <= 160'h38f7ffc00f81c1c03fff80380fc78e781ff73818;
	char_green_win[11] <= 160'h7fe381c01fffffe03bbf80381fcffffc1c70383c;
	char_green_win[12] <= 160'h7fc003d81f83c1c03bbff0303def0e701c7ffffe;
	char_green_win[13] <= 160'h338003fc7f83c1c03bbc780071fffff81c7e7600;
	char_green_win[14] <= 160'h07fffffe7783c1c03bbc703061ff0e001c70f700;
	char_green_win[15] <= 160'h0f7e1c000783c1c03bbc707803ff0e701c71f3c0;
	char_green_win[16] <= 160'h1e7e1c300783c1c03bbc70f803e7fff81c73fdf0;
	char_green_win[17] <= 160'h3c7f9c380783c1c03bbc71f007e70e001ff7bcfe;
	char_green_win[18] <= 160'h7ffbde7c07ffffc03bbc73e00fe70e381c7f387e;
	char_green_win[19] <= 160'h7fbbdef0078001c03ffc7f800ee7fffc1c7e38fc;
	char_green_win[20] <= 160'h38f9dfe0078001c03bbc7e001ee700001c7ffff0;
	char_green_win[21] <= 160'h06f1ff800780001c33a078003ce700e01c7778e0;
	char_green_win[22] <= 160'h1f78ffc00780001c03f8701c38effff01c7070e0;
	char_green_win[23] <= 160'h3fb9fde00780001c03bc701c70e7c1f0387070e0;
	char_green_win[24] <= 160'h3bbbddf00780001c039c701ce0e0e3c03870f0e0;
	char_green_win[25] <= 160'h7b9f9cfc0780001c03fe701c00e077803871e0e0;
	char_green_win[26] <= 160'h73bf1c7e0780001c3ffe701c01e03f003871c1e0;
	char_green_win[27] <= 160'hf3bf1c3c0780001e7f0e701c01e03f0077f3c1c0;
	char_green_win[28] <= 160'h701ffc1807fffffe780c7ffe1fc1fffe77ff1fc0;
	char_green_win[29] <= 160'h0000fc0003fffffc30007ffe0fcfe3fe61fe0fc0;
	char_green_win[30] <= 160'h00003800000000000000000007ff0078e0fc0380;
	char_green_win[31] <= 160'h0000000000000000000000000000000000000000;
end
 
endmodule
		 