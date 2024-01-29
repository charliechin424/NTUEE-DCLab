module snake(
	input clk,		
	input rst_n,	
	
	input [4:0]x,
	input [4:0]y,
	input [11:0] score,
	input key0_right,	
	input key1_left,	
	input key2_down,	
	input key3_up,		
	
	input [9:0]pos_x,	
	input [9:0]pos_y,	
	
	//boom_1 position
	input	[5:0]	boom1_x_1,
	input	[5:0]	boom1_y_1,
	input	[5:0]	boom2_x_1,
	input	[5:0]	boom2_y_1,
	input	[5:0]	boom3_x_1,
	input	[5:0]	boom3_y_1,
	//boom_2 position
	input	[5:0]	boom1_x_2,
	input	[5:0]	boom1_y_2,
	input	[5:0]	boom2_x_2,
	input	[5:0]	boom2_y_2,
	input	[5:0]	boom3_x_2,
	input	[5:0]	boom3_y_2,

	output [5:0]head_x,	
	output [5:0]head_y,	
	output [1:0] o_direct,
	output [24:0] o_speed,
	
	input add_cube,		 
	input [1:0]game_status,
	
	output [3:0] LEDG,
	
	output o_hit_body,
	output reg hit_wall, 
	output [5:0] o_cube_x [15:0],
	output [5:0] o_cube_y [15:0],
	output [15:0] o_is_exist,
	output reg [1:0]snake_show,
	output [3:0] o_snake_image
);
	
	localparam UP = 2'b00;
	localparam DOWN = 2'b01;
	localparam LEFT = 2'b10;
	localparam RIGHT = 2'b11;
	
	localparam NONE = 2'b00;
	localparam HEAD = 2'b01;
	localparam BODY = 2'b10;
	localparam WALL = 2'b11;
	
    localparam RESTART = 2'b00;
	localparam PLAY = 2'b10;
	localparam DIE = 2'b11;	
	
	logic dead;

	logic hit_body;

	logic [3:0]cube_num;
	logic [5:0]cube_x[15:0];
	logic [5:0]cube_y[15:0];
	logic [15:0]is_exist;  
	
	logic addcube_state;
	
	logic[31:0]clk_cnt;
	logic[23:0] speed;     
	
	logic[1:0]direct_r;		
	logic[1:0]direct_next;	

	// Image
	logic [3:0] image [15:0];
	parameter IM_HEAD_UP = 4'd0;
	parameter IM_HEAD_DOWN = 4'd1;
	parameter IM_HEAD_LEFT = 4'd2;
	parameter IM_HEAD_RIGHT = 4'd3;
	parameter IM_BODY_VERTI = 4'd4;
	parameter IM_BODY_PARAL = 4'd5;
	parameter IM_BODY_UP_RIGHT = 4'd6;
	parameter IM_BODY_DOWN_RIGHT = 4'd7;
	parameter IM_BODY_UP_LEFT = 4'd8;
	parameter IM_BODY_DOWN_LEFT = 4'd9;
	parameter IM_TAIL_UP = 4'd10;
	parameter IM_TAIL_DOWN = 4'd11;
	parameter IM_TAIL_LEFT = 4'd12;
	parameter IM_TAIL_RIGHT = 4'd13;
	integer i;

	
	assign head_x = cube_x[0];
	assign head_y = cube_y[0];
	assign o_cube_x = cube_x;
	assign o_cube_y = cube_y;
	assign o_is_exist = is_exist;
	assign o_direct = direct_r;
	assign o_speed = speed;
	assign o_hit_body = hit_body | dead;
	
	always_ff @(posedge clk or negedge rst_n) begin		
		if(!rst_n) begin
			speed<= 24'd12500000;
			direct_r<=RIGHT;
		end
		else if(game_status==RESTART) begin
			speed<= 24'd12500000;
			direct_r<=RIGHT;
		end
		else begin
			direct_r <= direct_next;
			if (score <= 4) begin
				speed <= 24'd6250000;
			end else if (score <= 6) begin
				speed <= 24'd5000000;
			end else if (score <= 8) begin
				speed <= 24'd4166666;
			end else if (score <= 10) begin
				speed <= 24'd3571428;
			end else if (score <= 12) begin
				speed <= 24'd2777777;
			end else if (score <= 14) begin
				speed <= 24'd2500000;
			end else if (score <= 16) begin
				speed <= 24'd2272727;
			end else if (score <= 18) begin
				speed <= 24'd2083333;
			end else if (score <= 20) begin
				speed <= 24'd1923076;
			end else if (score <= 22) begin
				speed <= 24'd1785714;
			end else if (score <= 24) begin
				speed <= 24'd1666666;
			end else begin
				speed <= 24'd1562500;
			end
		end		
	end
    
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			clk_cnt <= 0;
								
			cube_x[0] <= x;	
			cube_y[0] <= y;
					
			cube_x[1] <= x-1;	
			cube_y[1] <= y;
					
			cube_x[2] <= x-2;
			cube_y[2] <= y;

			cube_x[3] <= 0;
			cube_y[3] <= 0;
					
			cube_x[4] <= 0;
			cube_y[4] <= 0;
					
			cube_x[5] <= 0;
			cube_y[5] <= 0;
					
			cube_x[6] <= 0;
			cube_y[6] <= 0;
					
			cube_x[7] <= 0;
			cube_y[7] <= 0;
					
			cube_x[8] <= 0;
			cube_y[8] <= 0;
					
			cube_x[9] <= 0;
			cube_y[9] <= 0;					
					
			cube_x[10] <= 0;
			cube_y[10] <= 0;
					
			cube_x[11] <= 0;
			cube_y[11] <= 0;
					
         cube_x[12] <= 0;
			cube_y[12] <= 0;
					
			cube_x[13] <= 0;
			cube_y[13] <= 0;
					
			cube_x[14] <= 0;
			cube_y[14] <= 0;
					
			cube_x[15] <= 0;
			cube_y[15] <= 0;

			hit_wall <= 0;
			hit_body <= 0;
		end	
		else if(game_status==RESTART) begin
			clk_cnt <= 0;
                                                    
			cube_x[0] <= x;	
			cube_y[0] <= y;
					
			cube_x[1] <= x-1;	
			cube_y[1] <= y;
					
			cube_x[2] <= x-2;	
			cube_y[2] <= y;

			cube_x[3] <= 0;
			cube_y[3] <= 0;
					
			cube_x[4] <= 0;
			cube_y[4] <= 0;
					
			cube_x[5] <= 0;
			cube_y[5] <= 0;
					
			cube_x[6] <= 0;
			cube_y[6] <= 0;
					
			cube_x[7] <= 0;
			cube_y[7] <= 0;
					
			cube_x[8] <= 0;
			cube_y[8] <= 0;
					
			cube_x[9] <= 0;
			cube_y[9] <= 0;					
					
			cube_x[10] <= 0;
			cube_y[10] <= 0;
					
			cube_x[11] <= 0;
			cube_y[11] <= 0;
					
         cube_x[12] <= 0;
			cube_y[12] <= 0;
					
			cube_x[13] <= 0;
			cube_y[13] <= 0;
					
			cube_x[14] <= 0;
			cube_y[14] <= 0;
					
			cube_x[15] <= 0;
			cube_y[15] <= 0;
                    
			hit_wall <= 0;
			hit_body <= 0; 
		end
		else begin
			clk_cnt <= clk_cnt + 1;
				if(clk_cnt == speed) begin
					clk_cnt <= 0;
					if(game_status==PLAY) begin
						if((direct_r==UP && cube_y[0] == 1)||(direct_r==DOWN && cube_y[0] == 28)||(direct_r==LEFT && cube_x[0] == 1)||(direct_r==RIGHT && cube_x[0] == 38))begin
							hit_wall <= 1; end			
											
						else if((cube_y[0] == cube_y[1] && cube_x[0] == cube_x[1] && is_exist[1] == 1)||
								(cube_y[0] == cube_y[2] && cube_x[0] == cube_x[2] && is_exist[2] == 1)||
								(cube_y[0] == cube_y[3] && cube_x[0] == cube_x[3] && is_exist[3] == 1)||
								(cube_y[0] == cube_y[4] && cube_x[0] == cube_x[4] && is_exist[4] == 1)||
								(cube_y[0] == cube_y[5] && cube_x[0] == cube_x[5] && is_exist[5] == 1)||
								(cube_y[0] == cube_y[6] && cube_x[0] == cube_x[6] && is_exist[6] == 1)||
								(cube_y[0] == cube_y[7] && cube_x[0] == cube_x[7] && is_exist[7] == 1)||
								(cube_y[0] == cube_y[8] && cube_x[0] == cube_x[8] && is_exist[8] == 1)||
								(cube_y[0] == cube_y[9] && cube_x[0] == cube_x[9] && is_exist[9] == 1)||
								(cube_y[0] == cube_y[10] && cube_x[0] == cube_x[10] && is_exist[10] == 1)||
								(cube_y[0] == cube_y[11] && cube_x[0] == cube_x[11] && is_exist[11] == 1)||
								(cube_y[0] == cube_y[12] && cube_x[0] == cube_x[12] && is_exist[12] == 1)||
								(cube_y[0] == cube_y[13] && cube_x[0] == cube_x[13] && is_exist[13] == 1)||
								(cube_y[0] == cube_y[14] && cube_x[0] == cube_x[14] && is_exist[14] == 1)||
								(cube_y[0] == cube_y[15] && cube_x[0] == cube_x[15] && is_exist[15] == 1)) begin
								hit_body <= 1; end
							
							else begin
								cube_x[1] <= cube_x[0];
								cube_y[1] <= cube_y[0];
															
								cube_x[2] <= cube_x[1];
								cube_y[2] <= cube_y[1];
															
								cube_x[3] <= cube_x[2];
								cube_y[3] <= cube_y[2];
															
								cube_x[4] <= cube_x[3];
								cube_y[4] <= cube_y[3];
															
								cube_x[5] <= cube_x[4];
								cube_y[5] <= cube_y[4];
															
								cube_x[6] <= cube_x[5];
								cube_y[6] <= cube_y[5];
															
								cube_x[7] <= cube_x[6];
								cube_y[7] <= cube_y[6];
															
								cube_x[8] <= cube_x[7];
								cube_y[8] <= cube_y[7];
															
								cube_x[9] <= cube_x[8];
								cube_y[9] <= cube_y[8];
															
								cube_x[10] <= cube_x[9];
								cube_y[10] <= cube_y[9];
															
								cube_x[11] <= cube_x[10];
								cube_y[11] <= cube_y[10];
															
								cube_x[12] <= cube_x[11];
								cube_y[12] <= cube_y[11];
															 
								cube_x[13] <= cube_x[12];
								cube_y[13] <= cube_y[12];
															
								cube_x[14] <= cube_x[13];
								cube_y[14] <= cube_y[13];
															
								cube_x[15] <= cube_x[14];
								cube_y[15] <= cube_y[14];

								if(direct_r==UP)begin
										if(cube_y[0] == 1)
										hit_wall <= 1;
										else
											cube_y[0] <= cube_y[0]-1;
										end
																
								else if(direct_r==DOWN)begin
										if(cube_y[0] == 28)
											hit_wall <= 1;
										else
											cube_y[0] <= cube_y[0] + 1;
										end
																	
								else if(direct_r==LEFT)begin
										if(cube_x[0] == 1)
											hit_wall <= 1;
										else
											cube_x[0] <= cube_x[0] - 1;											
										end

								else if(direct_r==RIGHT)begin
										if(cube_x[0] == 38)
											hit_wall <= 1;
										else
											cube_x[0] <= cube_x[0] + 1;
										end
							end
						end
					end
				end
			end

	
	// ###############
	// ##	image	##
	// ###############
	always_comb begin
		// snake head
		if (cube_y[0] == cube_y[1] - 1) image[0] = IM_HEAD_UP;
		else if (cube_y[0] == cube_y[1] + 1) image[0] = IM_HEAD_DOWN;
		else if (cube_x[0] == cube_x[1] + 1) image[0] = IM_HEAD_RIGHT;
		else image[0] = IM_HEAD_LEFT;
		// snake body
		//
		for (i=1; i<16; i=i+1) begin
			if ((i+1 == cube_num) | (i == 15)) begin
				// snake tail
				if (cube_y[i-1] == cube_y[i] - 1) image[i] = IM_TAIL_UP;
				else if (cube_y[i-1] == cube_y[i] + 1) image[i] = IM_TAIL_DOWN;
				else if (cube_x[i-1] == cube_x[i] + 1) image[i] = IM_TAIL_RIGHT;
				else image[i] = IM_TAIL_LEFT;
			end
			else begin
				// snake body
				if (cube_y[i-1] == cube_y[i] - 1) begin
					if (cube_y[i+1] == cube_y[i] + 1) begin
						image[i] = IM_BODY_VERTI;
					end 
					else if (cube_x[i+1] == cube_x[i] + 1) begin
						image[i] = IM_BODY_UP_RIGHT;
					end
					else begin
						image[i] = IM_BODY_UP_LEFT;
					end
				end
				else if (cube_y[i-1] == cube_y[i] + 1) begin
					if (cube_y[i+1] == cube_y[i] - 1) begin
						image[i] = IM_BODY_VERTI;
					end 
					else if (cube_x[i+1] == cube_x[i] + 1) begin
						image[i] = IM_BODY_DOWN_RIGHT;
					end
					else begin
						image[i] = IM_BODY_DOWN_LEFT;
					end
				end
				else if (cube_x[i-1] == cube_x[i] + 1) begin
					if (cube_x[i+1] == cube_x[i] - 1) begin
						image[i] = IM_BODY_PARAL;
					end 
					else if (cube_y[i+1] == cube_y[i] - 1) begin
						image[i] = IM_BODY_UP_RIGHT;
					end
					else begin
						image[i] = IM_BODY_DOWN_RIGHT;
					end
				end
				else begin
					if (cube_x[i+1] == cube_x[i] + 1) begin
						image[i] = IM_BODY_PARAL;
					end 
					else if (cube_y[i+1] == cube_y[i] - 1) begin
						image[i] = IM_BODY_UP_LEFT;
					end
					else begin
						image[i] = IM_BODY_DOWN_LEFT;
					end
				end
			end
		end
	end
	
	always_comb begin
		LEDG[0] = (image[1] == IM_BODY_DOWN_RIGHT);
		LEDG[1] = (image[1] == IM_BODY_UP_LEFT);
		LEDG[2] = (image[1] == IM_BODY_DOWN_LEFT);
		LEDG[3] = (image[1] == IM_BODY_UP_RIGHT);

	end
	
	always_comb begin  
		case(direct_r)	
			UP: begin  
				if(key1_left)
					direct_next = LEFT;
				else if(key0_right)
					direct_next = RIGHT;
				else
					direct_next = UP;			
				end		
			DOWN: begin 
				if(key1_left)
					direct_next = LEFT;
				else if(key0_right)
					direct_next = RIGHT;
				else
					direct_next = DOWN;			
				end		
				LEFT: begin 
				if(key3_up)
					direct_next = UP;
				else if(key2_down)
					direct_next = DOWN;
				else
					direct_next = LEFT;			
				end
				RIGHT: begin
				if(key3_up)
					direct_next = UP;
				else if(key2_down)
					direct_next = DOWN;
				else
					direct_next = RIGHT;
				end	
		endcase
	end
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			is_exist <= 16'd7;
			cube_num <= 3;  
			addcube_state <= 0;
			dead <= 0;
		end  
		else if (game_status == RESTART) begin
		      is_exist <= 16'd7;
              cube_num <= 3;
              addcube_state <= 0;
			  dead <= 0;
         end
		else begin			
			case(addcube_state) 
				0:begin
					if(add_cube) begin
						cube_num <= cube_num + 1;
						is_exist[cube_num] <= 1;
						addcube_state <= 1;
					end						
				end
				1:begin
					if(!add_cube)
						addcube_state <= 0;				
				end
			endcase

			//====================================================================================
			//boom touch
			if ((boom1_y_1 == cube_y[0] && boom1_x_1 == cube_x[0]) || 
				(boom1_y_1 == cube_y[1] && boom1_x_1 == cube_x[1]) || 
				(boom1_y_1 == cube_y[2] && boom1_x_1 == cube_x[2]) ||

				(boom2_y_1 == cube_y[0] && boom2_x_1 == cube_x[0]) || 
				(boom2_y_1 == cube_y[1] && boom2_x_1 == cube_x[1]) || 
				(boom2_y_1 == cube_y[2] && boom2_x_1 == cube_x[2]) ||

				(boom3_y_1 == cube_y[0] && boom3_x_1 == cube_x[0]) || 
				(boom3_y_1 == cube_y[1] && boom3_x_1 == cube_x[1]) || 
				(boom3_y_1 == cube_y[2] && boom3_x_1 == cube_x[2]) ||

				(boom1_y_2 == cube_y[0] && boom1_x_2 == cube_x[0]) || 
				(boom1_y_2 == cube_y[1] && boom1_x_2 == cube_x[1]) || 
				(boom1_y_2 == cube_y[2] && boom1_x_2 == cube_x[2]) ||

				(boom2_y_2 == cube_y[0] && boom2_x_2 == cube_x[0]) || 
				(boom2_y_2 == cube_y[1] && boom2_x_2 == cube_x[1]) || 
				(boom2_y_2 == cube_y[2] && boom2_x_2 == cube_x[2]) ||

				(boom3_y_2 == cube_y[0] && boom3_x_2 == cube_x[0]) || 
				(boom3_y_2 == cube_y[1] && boom3_x_2 == cube_x[1]) || 
				(boom3_y_2 == cube_y[2] && boom3_x_2 == cube_x[2])) begin
				dead <= 1;
			end
			else if ((boom1_y_1 == cube_y[3] && boom1_x_1 == cube_x[3] && is_exist[3] == 1)||
					 (boom2_y_1 == cube_y[3] && boom2_x_1 == cube_x[3] && is_exist[3] == 1)||
					 (boom3_y_1 == cube_y[3] && boom3_x_1 == cube_x[3] && is_exist[3] == 1)||
					 (boom1_y_2 == cube_y[3] && boom1_x_2 == cube_x[3] && is_exist[3] == 1)||
					 (boom2_y_2 == cube_y[3] && boom2_x_2 == cube_x[3] && is_exist[3] == 1)||
					 (boom3_y_2 == cube_y[3] && boom3_x_2 == cube_x[3] && is_exist[3] == 1)) begin
				cube_num <= 3;
				is_exist[3] <= 0;
				is_exist[4] <= 0;
				is_exist[5] <= 0;
				is_exist[6] <= 0;
				is_exist[7] <= 0;
				is_exist[8] <= 0;
				is_exist[9] <= 0;
				is_exist[10] <= 0;
				is_exist[11] <= 0;
				is_exist[12] <= 0;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[4] && boom1_x_1 == cube_x[4] && is_exist[4] == 1)||
					 (boom2_y_1 == cube_y[4] && boom2_x_1 == cube_x[4] && is_exist[4] == 1)||
					 (boom3_y_1 == cube_y[4] && boom3_x_1 == cube_x[4] && is_exist[4] == 1)||
					 (boom1_y_2 == cube_y[4] && boom1_x_2 == cube_x[4] && is_exist[4] == 1)||
					 (boom2_y_2 == cube_y[4] && boom2_x_2 == cube_x[4] && is_exist[4] == 1)||
					 (boom3_y_2 == cube_y[4] && boom3_x_2 == cube_x[4] && is_exist[4] == 1)) begin
				cube_num <= 4;
				is_exist[4] <= 0;
				is_exist[5] <= 0;
				is_exist[6] <= 0;
				is_exist[7] <= 0;
				is_exist[8] <= 0;
				is_exist[9] <= 0;
				is_exist[10] <= 0;
				is_exist[11] <= 0;
				is_exist[12] <= 0;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[5] && boom1_x_1 == cube_x[5] && is_exist[5] == 1)||
					 (boom2_y_1 == cube_y[5] && boom2_x_1 == cube_x[5] && is_exist[5] == 1)||
					 (boom3_y_1 == cube_y[5] && boom3_x_1 == cube_x[5] && is_exist[5] == 1)||
					 (boom1_y_2 == cube_y[5] && boom1_x_2 == cube_x[5] && is_exist[5] == 1)||
					 (boom2_y_2 == cube_y[5] && boom2_x_2 == cube_x[5] && is_exist[5] == 1)||
					 (boom3_y_2 == cube_y[5] && boom3_x_2 == cube_x[5] && is_exist[5] == 1)) begin
				cube_num <= 5;
				is_exist[5] <= 0;
				is_exist[6] <= 0;
				is_exist[7] <= 0;
				is_exist[8] <= 0;
				is_exist[9] <= 0;
				is_exist[10] <= 0;
				is_exist[11] <= 0;
				is_exist[12] <= 0;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[6] && boom1_x_1 == cube_x[6] && is_exist[6] == 1)||
					 (boom2_y_1 == cube_y[6] && boom2_x_1 == cube_x[6] && is_exist[6] == 1)||
					 (boom3_y_1 == cube_y[6] && boom3_x_1 == cube_x[6] && is_exist[6] == 1)||
					 (boom1_y_2 == cube_y[6] && boom1_x_2 == cube_x[6] && is_exist[6] == 1)||
					 (boom2_y_2 == cube_y[6] && boom2_x_2 == cube_x[6] && is_exist[6] == 1)||
					 (boom3_y_2 == cube_y[6] && boom3_x_2 == cube_x[6] && is_exist[6] == 1)) begin
				cube_num <= 6;
				is_exist[6] <= 0;
				is_exist[7] <= 0;
				is_exist[8] <= 0;
				is_exist[9] <= 0;
				is_exist[10] <= 0;
				is_exist[11] <= 0;
				is_exist[12] <= 0;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[7] && boom1_x_1 == cube_x[7] && is_exist[7] == 1)||
					 (boom2_y_1 == cube_y[7] && boom2_x_1 == cube_x[7] && is_exist[7] == 1)||
					 (boom3_y_1 == cube_y[7] && boom3_x_1 == cube_x[7] && is_exist[7] == 1)||
					 (boom1_y_2 == cube_y[7] && boom1_x_2 == cube_x[7] && is_exist[7] == 1)||
					 (boom2_y_2 == cube_y[7] && boom2_x_2 == cube_x[7] && is_exist[7] == 1)||
					 (boom3_y_2 == cube_y[7] && boom3_x_2 == cube_x[7] && is_exist[7] == 1)) begin
				cube_num <= 7;
				is_exist[7] <= 0;
				is_exist[8] <= 0;
				is_exist[9] <= 0;
				is_exist[10] <= 0;
				is_exist[11] <= 0;
				is_exist[12] <= 0;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[8] && boom1_x_1 == cube_x[8] && is_exist[8] == 1)||
					 (boom2_y_1 == cube_y[8] && boom2_x_1 == cube_x[8] && is_exist[8] == 1)||
					 (boom3_y_1 == cube_y[8] && boom3_x_1 == cube_x[8] && is_exist[8] == 1)||
					 (boom1_y_2 == cube_y[8] && boom1_x_2 == cube_x[8] && is_exist[8] == 1)||
					 (boom2_y_2 == cube_y[8] && boom2_x_2 == cube_x[8] && is_exist[8] == 1)||
					 (boom3_y_2 == cube_y[8] && boom3_x_2 == cube_x[8] && is_exist[8] == 1)) begin
				cube_num <= 8;
				is_exist[8] <= 0;
				is_exist[9] <= 0;
				is_exist[10] <= 0;
				is_exist[11] <= 0;
				is_exist[12] <= 0;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[9] && boom1_x_1 == cube_x[9] && is_exist[9] == 1)||
					 (boom2_y_1 == cube_y[9] && boom2_x_1 == cube_x[9] && is_exist[9] == 1)||
					 (boom3_y_1 == cube_y[9] && boom3_x_1 == cube_x[9] && is_exist[9] == 1)||
					 (boom1_y_2 == cube_y[9] && boom1_x_2 == cube_x[9] && is_exist[9] == 1)||
					 (boom2_y_2 == cube_y[9] && boom2_x_2 == cube_x[9] && is_exist[9] == 1)||
					 (boom3_y_2 == cube_y[9] && boom3_x_2 == cube_x[9] && is_exist[9] == 1)) begin
				cube_num <= 9;
				is_exist[9] <= 0;
				is_exist[10] <= 0;
				is_exist[11] <= 0;
				is_exist[12] <= 0;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[10] && boom1_x_1 == cube_x[10] && is_exist[10] == 1)||
					 (boom2_y_1 == cube_y[10] && boom2_x_1 == cube_x[10] && is_exist[10] == 1)||
					 (boom3_y_1 == cube_y[10] && boom3_x_1 == cube_x[10] && is_exist[10] == 1)||
					 (boom1_y_2 == cube_y[10] && boom1_x_2 == cube_x[10] && is_exist[10] == 1)||
					 (boom2_y_2 == cube_y[10] && boom2_x_2 == cube_x[10] && is_exist[10] == 1)||
					 (boom3_y_2 == cube_y[10] && boom3_x_2 == cube_x[10] && is_exist[10] == 1)) begin
				cube_num <= 10;
				is_exist[10] <= 0;
				is_exist[11] <= 0;
				is_exist[12] <= 0;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[11] && boom1_x_1 == cube_x[11] && is_exist[11] == 1)||
					 (boom2_y_1 == cube_y[11] && boom2_x_1 == cube_x[11] && is_exist[11] == 1)||
					 (boom3_y_1 == cube_y[11] && boom3_x_1 == cube_x[11] && is_exist[11] == 1)||
					 (boom1_y_2 == cube_y[11] && boom1_x_2 == cube_x[11] && is_exist[11] == 1)||
					 (boom2_y_2 == cube_y[11] && boom2_x_2 == cube_x[11] && is_exist[11] == 1)||
					 (boom3_y_2 == cube_y[11] && boom3_x_2 == cube_x[11] && is_exist[11] == 1)) begin
				cube_num <= 11;
				is_exist[11] <= 0;
				is_exist[12] <= 0;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[12] && boom1_x_1 == cube_x[12] && is_exist[12] == 1)||
					 (boom2_y_1 == cube_y[12] && boom2_x_1 == cube_x[12] && is_exist[12] == 1)||
					 (boom3_y_1 == cube_y[12] && boom3_x_1 == cube_x[12] && is_exist[12] == 1)||
					 (boom1_y_2 == cube_y[12] && boom1_x_2 == cube_x[12] && is_exist[12] == 1)||
					 (boom2_y_2 == cube_y[12] && boom2_x_2 == cube_x[12] && is_exist[12] == 1)||
					 (boom3_y_2 == cube_y[12] && boom3_x_2 == cube_x[12] && is_exist[12] == 1)) begin
				cube_num <= 12;
				is_exist[12] <= 0;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[13] && boom1_x_1 == cube_x[13] && is_exist[13] == 1)||
					 (boom2_y_1 == cube_y[13] && boom2_x_1 == cube_x[13] && is_exist[13] == 1)||
					 (boom3_y_1 == cube_y[13] && boom3_x_1 == cube_x[13] && is_exist[13] == 1)||
					 (boom1_y_2 == cube_y[13] && boom1_x_2 == cube_x[13] && is_exist[13] == 1)||
					 (boom2_y_2 == cube_y[13] && boom2_x_2 == cube_x[13] && is_exist[13] == 1)||
					 (boom3_y_2 == cube_y[13] && boom3_x_2 == cube_x[13] && is_exist[13] == 1)) begin
				cube_num <= 13;
				is_exist[13] <= 0;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[14] && boom1_x_1 == cube_x[14] && is_exist[14] == 1)||
					 (boom2_y_1 == cube_y[14] && boom2_x_1 == cube_x[14] && is_exist[14] == 1)||
					 (boom3_y_1 == cube_y[14] && boom3_x_1 == cube_x[14] && is_exist[14] == 1)||
					 (boom1_y_2 == cube_y[14] && boom1_x_2 == cube_x[14] && is_exist[14] == 1)||
					 (boom2_y_2 == cube_y[14] && boom2_x_2 == cube_x[14] && is_exist[14] == 1)||
					 (boom3_y_2 == cube_y[14] && boom3_x_2 == cube_x[14] && is_exist[14] == 1)) begin
				cube_num <= 14;
				is_exist[14] <= 0;
				is_exist[15] <= 0;
			end
			else if ((boom1_y_1 == cube_y[15] && boom1_x_1 == cube_x[15] && is_exist[15] == 1)||
					 (boom2_y_1 == cube_y[15] && boom2_x_1 == cube_x[15] && is_exist[15] == 1)||
					 (boom3_y_1 == cube_y[15] && boom3_x_1 == cube_x[15] && is_exist[15] == 1)||
					 (boom1_y_2 == cube_y[15] && boom1_x_2 == cube_x[15] && is_exist[15] == 1)||
					 (boom2_y_2 == cube_y[15] && boom2_x_2 == cube_x[15] && is_exist[15] == 1)||
					 (boom3_y_2 == cube_y[15] && boom3_x_2 == cube_x[15] && is_exist[15] == 1)) begin
				cube_num <= 15;
				is_exist[15] <= 0;
			end
			//====================================================================================
		end
	end

	always_comb begin	
		o_snake_image = 4'b1111;			
		if(pos_x >= 0 && pos_x < 640 && pos_y >= 0 && pos_y < 480) begin
			if(pos_x[9:4] == 0 || pos_y[9:4] == 0 || pos_x[9:4] == 39 || pos_y[9:4] == 29)
				snake_show = WALL;
				
			else if(pos_x[9:4] == cube_x[0] && pos_y[9:4] == cube_y[0] && is_exist[0] == 1) begin
				// Scan head
				snake_show = HEAD ;
				o_snake_image = image[0];
			end
			// Scan Body
				else if (pos_x[9:4] == cube_x[1] && pos_y[9:4] == cube_y[1] && is_exist[1] == 1) begin
					snake_show = BODY;
					o_snake_image = image[1];
				end
				else if (pos_x[9:4] == cube_x[2] && pos_y[9:4] == cube_y[2] && is_exist[2] == 1) begin
					snake_show = BODY;
					o_snake_image = image[2];
				end
				else if (pos_x[9:4] == cube_x[3] && pos_y[9:4] == cube_y[3] && is_exist[3] == 1) begin
					snake_show = BODY;
					o_snake_image = image[3];
				end
				else if (pos_x[9:4] == cube_x[4] && pos_y[9:4] == cube_y[4] && is_exist[4] == 1) begin
					snake_show = BODY;
					o_snake_image = image[4];
				end
				else if (pos_x[9:4] == cube_x[5] && pos_y[9:4] == cube_y[5] && is_exist[5] == 1) begin
					snake_show = BODY;
					o_snake_image = image[5];
				end
				else if (pos_x[9:4] == cube_x[6] && pos_y[9:4] == cube_y[6] && is_exist[6] == 1) begin
					snake_show = BODY;
					o_snake_image = image[6];
				end
				else if (pos_x[9:4] == cube_x[7] && pos_y[9:4] == cube_y[7] && is_exist[7] == 1) begin
					snake_show = BODY;
					o_snake_image = image[7];
				end
				else if (pos_x[9:4] == cube_x[8] && pos_y[9:4] == cube_y[8] && is_exist[8] == 1) begin
					snake_show = BODY;
					o_snake_image = image[8];
				end
				else if (pos_x[9:4] == cube_x[9] && pos_y[9:4] == cube_y[9] && is_exist[9] == 1) begin
					snake_show = BODY;
					o_snake_image = image[9];
				end
				else if (pos_x[9:4] == cube_x[10] && pos_y[9:4] == cube_y[10] && is_exist[10] == 1) begin
					snake_show = BODY;
					o_snake_image = image[10];
				end
				else if (pos_x[9:4] == cube_x[11] && pos_y[9:4] == cube_y[11] && is_exist[11] == 1) begin
					snake_show = BODY;
					o_snake_image = image[11];
				end
				else if (pos_x[9:4] == cube_x[12] && pos_y[9:4] == cube_y[12] && is_exist[12] == 1) begin
					snake_show = BODY;
					o_snake_image = image[12];
				end
				else if (pos_x[9:4] == cube_x[13] && pos_y[9:4] == cube_y[13] && is_exist[13] == 1) begin
					snake_show = BODY;
					o_snake_image = image[13];
				end
				else if (pos_x[9:4] == cube_x[14] && pos_y[9:4] == cube_y[14] && is_exist[14] == 1) begin
					snake_show = BODY;
					o_snake_image = image[14];
				end
				else if (pos_x[9:4] == cube_x[15] && pos_y[9:4] == cube_y[15] && is_exist[15] == 1) begin
					snake_show = BODY;
					o_snake_image = image[15];
				end
			// not scaned
			else snake_show = NONE;
		end else begin
			snake_show = NONE;
		end
	end
endmodule