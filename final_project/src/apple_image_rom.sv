module apple_image_rom (
    input i_clk,
    input [9:0] i_pos_x,
    input [9:0] i_pos_y,
    output [23:0] o_apple_image_data
);

logic [7:0] apple_rom_addr;
logic [23:0] apple_rom_data;
logic [1:0] rotation = 0;

logic [3:0] addr1;
assign addr1 = i_pos_y[3:0] + 1;
logic [3:0] addr2;
assign addr2 = i_pos_x[3:0] + 1;

assign apple_rom_addr = { addr1, addr2 };

// #################
// ##   1 x ROM   ##
// #################

apple apple_init1 (
    .address(apple_rom_addr),
    .clock(i_clk),
    .q(o_apple_image_data)
);

// ROM data logic

endmodule