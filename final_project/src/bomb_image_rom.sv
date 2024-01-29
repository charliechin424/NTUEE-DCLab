module boom_image_rom (
    input i_clk,
    input [9:0] i_pos_x,
    input [9:0] i_pos_y,
    output [23:0] o_boom_image_data
);

localparam	RED    = 24'b11111111_00000000_00000000; 	
localparam	GREEN  = 24'b00000000_11111111_00000000; 	
localparam	BLUE   = 24'b00000000_00000000_11111111; 
localparam	YELLOW = 24'b11111111_11111111_00000000; 

logic [7:0] bomb_rom_addr;
logic [23:0] bomb_rom_data;

logic [3:0] addr1;
assign addr1 = i_pos_y[3:0] - 1;
logic [3:0] addr2;
assign addr2 = i_pos_x[3:0] - 1;

assign bomb_rom_addr = { addr1, addr2 };

// #################
// ##   1 x ROM   ##
// #################

boom bomb_init1 (
    .address(bomb_rom_addr),
    .clock(i_clk),
    .q(o_boom_image_data)
);

// ROM data logic

endmodule