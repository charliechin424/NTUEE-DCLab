module snake_image_rom_green (
    input i_clk,
    input [3:0] i_snake_image,
    input [9:0] i_pos_x,
    input [9:0] i_pos_y,
	 input [8:0] LEDG,
    output [23:0] o_snake_image_data
);

localparam	RED    = 24'b11111111_00000000_00000000; 	
localparam	GREEN  = 24'b00000000_11111111_00000000; 	
localparam	BLUE   = 24'b00000000_00000000_11111111; 
localparam	YELLOW = 24'b11111111_11111111_00000000; 

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

logic [3:0] snake_image;
logic [7:0] head_rom_addr;
logic [7:0] bodyS_rom_addr;
logic [7:0] bodyT_rom_addr;
logic [7:0] tail_rom_addr;
logic [23:0] head_rom_data;
logic [23:0] bodyS_rom_data;
logic [23:0] bodyT_UR_rom_data;
logic [23:0] bodyT_UL_rom_data;
logic [23:0] bodyT_DR_rom_data;
logic [23:0] bodyT_DL_rom_data;
logic [23:0] tail_rom_data;

logic [3:0] addr1;
assign addr1 = i_pos_y[3:0];
logic [3:0] addr2;
assign addr2 = i_pos_x[3:0];

assign snake_image = i_snake_image;

always_comb begin
    head_rom_addr = 0;
    bodyS_rom_addr = 0;
    bodyT_rom_addr = 0;
    tail_rom_addr = 0;

    // ROM address logic
    case (snake_image)
        // head
        IM_HEAD_UP: head_rom_addr = { addr1, addr2 };
        IM_HEAD_DOWN: head_rom_addr = { (15 - addr1), addr2 };
        IM_HEAD_RIGHT: head_rom_addr = { (15 - addr2), addr1 };
        IM_HEAD_LEFT: head_rom_addr = { addr2, addr1 };
        
        // body straight
        IM_BODY_VERTI: bodyS_rom_addr = { addr1, addr2 };
        IM_BODY_PARAL: bodyS_rom_addr = { addr2, addr1 };

        // body turn
        IM_BODY_UP_RIGHT: bodyT_rom_addr = { addr1, addr2 };
        IM_BODY_DOWN_RIGHT: bodyT_rom_addr = { (15 - addr1), addr2 };
        IM_BODY_UP_LEFT: bodyT_rom_addr = { addr1, addr2 };
        IM_BODY_DOWN_LEFT: bodyT_rom_addr = { addr2, addr1 };
	
        // tail
        IM_TAIL_UP: tail_rom_addr = { addr1, addr2 };
        IM_TAIL_DOWN: tail_rom_addr = { (15 - addr1), addr2 };
        IM_TAIL_RIGHT: tail_rom_addr = { (15 - addr2), addr1 };
        IM_TAIL_LEFT: tail_rom_addr = { addr2, addr1 };
        default: ;
    endcase
end

// #################
// ##   7 x ROM   ##
// #################

green_head_data green_head_data(
	.i_addr(head_rom_addr),
	.head_rom_data(head_rom_data)
);
green_body_data green_body_data(
	.i_addr(bodyS_rom_addr),
	.head_rom_data(bodyS_rom_data)
);

green_UR_data green_UR_data (
	.i_addr(bodyT_rom_addr),
	.head_rom_data(bodyT_UR_rom_data)
);

green_UL_data green_UL_data (
	.i_addr(bodyT_rom_addr),
	.head_rom_data(bodyT_UL_rom_data)
);

green_tail_data green_tail_data (
	.i_addr(tail_rom_addr),
	.head_rom_data(tail_rom_data)
);


// ROM data logic
always_comb begin
    o_snake_image_data = 0;
    case (snake_image)
        IM_HEAD_UP: o_snake_image_data = head_rom_data;
        IM_HEAD_DOWN: o_snake_image_data = head_rom_data;
        IM_HEAD_LEFT: o_snake_image_data = head_rom_data;
        IM_HEAD_RIGHT: o_snake_image_data = head_rom_data;
        IM_BODY_VERTI: o_snake_image_data = bodyS_rom_data;
        IM_BODY_PARAL: o_snake_image_data = bodyS_rom_data;
        IM_BODY_UP_RIGHT: o_snake_image_data = bodyT_UR_rom_data;
        IM_BODY_DOWN_RIGHT: o_snake_image_data = bodyT_UR_rom_data;
        IM_BODY_UP_LEFT: o_snake_image_data = bodyT_UL_rom_data;
        IM_BODY_DOWN_LEFT: o_snake_image_data = bodyT_UR_rom_data;
        IM_TAIL_UP: o_snake_image_data = tail_rom_data;
        IM_TAIL_DOWN: o_snake_image_data = tail_rom_data;
        IM_TAIL_LEFT:  o_snake_image_data = tail_rom_data;
        IM_TAIL_RIGHT:  o_snake_image_data = tail_rom_data;
        default: ;
    endcase
end

endmodule

module snake_image_rom_red (
    input i_clk,
    input [3:0] i_snake_image,
    input [9:0] i_pos_x,
    input [9:0] i_pos_y,
	 input [8:0] LEDG,
    output [23:0] o_snake_image_data
);

localparam	RED    = 24'b11111111_00000000_00000000; 	
localparam	GREEN  = 24'b00000000_11111111_00000000; 	
localparam	BLUE   = 24'b00000000_00000000_11111111; 
localparam	YELLOW = 24'b11111111_11111111_00000000; 

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

logic [3:0] snake_image;
logic [7:0] head_rom_addr;
logic [7:0] bodyS_rom_addr;
logic [7:0] bodyT_rom_addr;
logic [7:0] tail_rom_addr;
logic [23:0] head_rom_data;
logic [23:0] bodyS_rom_data;
logic [23:0] bodyT_UR_rom_data;
logic [23:0] bodyT_UL_rom_data;
logic [23:0] bodyT_DR_rom_data;
logic [23:0] bodyT_DL_rom_data;
logic [23:0] tail_rom_data;

logic [3:0] addr1;
assign addr1 = i_pos_y[3:0];
logic [3:0] addr2;
assign addr2 = i_pos_x[3:0];

assign snake_image = i_snake_image;

always_comb begin
    head_rom_addr = 0;
    bodyS_rom_addr = 0;
    bodyT_rom_addr = { addr1, addr2 };
    tail_rom_addr = 0;

    // ROM address logic
    case (snake_image)
        // head
        IM_HEAD_UP: head_rom_addr = { addr1, addr2 };
        IM_HEAD_DOWN: head_rom_addr = { 15 - addr1, addr2 };
        IM_HEAD_RIGHT: head_rom_addr = { 15 - addr2, addr1 };
        IM_HEAD_LEFT: head_rom_addr = { addr2, addr1 };
        
        // body straight
        IM_BODY_VERTI: bodyS_rom_addr = { addr1, addr2 };
        IM_BODY_PARAL: bodyS_rom_addr = { addr2, addr1 };

        // body turn
        IM_BODY_UP_RIGHT: bodyT_rom_addr = { addr1, addr2 };
        IM_BODY_DOWN_RIGHT: bodyT_rom_addr = { (15 - addr1), addr2 };
        IM_BODY_UP_LEFT: bodyT_rom_addr = { addr1, addr2 };
        IM_BODY_DOWN_LEFT: bodyT_rom_addr = { addr2, addr1 };
        
        // tail
        IM_TAIL_UP: tail_rom_addr = { addr1, addr2 };
        IM_TAIL_DOWN: tail_rom_addr = { 15 - addr1, addr2 };
        IM_TAIL_RIGHT: tail_rom_addr = { 15 - addr2, addr1 };
        IM_TAIL_LEFT: tail_rom_addr = { addr2, addr1 };
        default: ;
    endcase
end

// #################
// ##   7 x ROM   ##
// #################

red_head_data red_head_data(
	.i_addr(head_rom_addr),
	.head_rom_data(head_rom_data)
);
red_body_data red_body_data(
	.i_addr(bodyS_rom_addr),
	.head_rom_data(bodyS_rom_data)
);

red_UR_data red_UR_data (
	.i_addr(bodyT_rom_addr),
	.head_rom_data(bodyT_UR_rom_data)
);

red_UL_data red_UL_data (
	.i_addr(bodyT_rom_addr),
	.head_rom_data(bodyT_UL_rom_data)
);

red_tail_data red_tail_data (
	.i_addr(tail_rom_addr),
	.head_rom_data(tail_rom_data)
);


// ROM data logic
always_comb begin
    o_snake_image_data = 0;
    case (snake_image)
        IM_HEAD_UP: o_snake_image_data = head_rom_data;
        IM_HEAD_DOWN: o_snake_image_data = head_rom_data;
        IM_HEAD_LEFT: o_snake_image_data = head_rom_data;
        IM_HEAD_RIGHT: o_snake_image_data = head_rom_data;
        IM_BODY_VERTI: o_snake_image_data = bodyS_rom_data;
        IM_BODY_PARAL: o_snake_image_data = bodyS_rom_data;
        IM_BODY_UP_RIGHT: o_snake_image_data = bodyT_UR_rom_data;
        IM_BODY_DOWN_RIGHT: o_snake_image_data = bodyT_UR_rom_data;
        IM_BODY_UP_LEFT: o_snake_image_data = bodyT_UL_rom_data;
        IM_BODY_DOWN_LEFT: o_snake_image_data = bodyT_UR_rom_data;
        IM_TAIL_UP: o_snake_image_data = tail_rom_data;
        IM_TAIL_DOWN: o_snake_image_data = tail_rom_data;
        IM_TAIL_LEFT:  o_snake_image_data = tail_rom_data;
        IM_TAIL_RIGHT:  o_snake_image_data = tail_rom_data;
        default: ;
    endcase
end

endmodule