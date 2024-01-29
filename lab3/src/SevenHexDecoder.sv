module SevenHexDecoder (
	input  logic [5:0]  i_num,
	output logic [6:0] o_seven_ten,
	output logic [6:0] o_seven_one
);

/* The layout of seven segment display, 1: dark
 *    00
 *   5  1
 *    66
 *   4  2
 *    33
 */

parameter D0 = 7'b1000000;
parameter D1 = 7'b1111001;
parameter D2 = 7'b0100100;
parameter D3 = 7'b0110000;
parameter D4 = 7'b0011001;
parameter D5 = 7'b0010010;
parameter D6 = 7'b0000010;
parameter D7 = 7'b1011000;
parameter D8 = 7'b0000000;
parameter D9 = 7'b0010000;

always_comb begin
	case(i_num)
		6'b000000: begin o_seven_ten = D0; o_seven_one = D0; end
		6'b000001: begin o_seven_ten = D0; o_seven_one = D1; end
		6'b000010: begin o_seven_ten = D0; o_seven_one = D2; end
		6'b000011: begin o_seven_ten = D0; o_seven_one = D3; end
		6'b000100: begin o_seven_ten = D0; o_seven_one = D4; end
		6'b000101: begin o_seven_ten = D0; o_seven_one = D5; end
		6'b000110: begin o_seven_ten = D0; o_seven_one = D6; end
		6'b000111: begin o_seven_ten = D0; o_seven_one = D7; end
		6'b001000: begin o_seven_ten = D0; o_seven_one = D8; end
		6'b001001: begin o_seven_ten = D0; o_seven_one = D9; end
		6'b001010: begin o_seven_ten = D1; o_seven_one = D0; end
		6'b001011: begin o_seven_ten = D1; o_seven_one = D1; end
		6'b001100: begin o_seven_ten = D1; o_seven_one = D2; end
		6'b001101: begin o_seven_ten = D1; o_seven_one = D3; end
		6'b001110: begin o_seven_ten = D1; o_seven_one = D4; end
		6'b001111: begin o_seven_ten = D1; o_seven_one = D5; end
		6'b010000: begin o_seven_ten = D1; o_seven_one = D6; end
		6'b010001: begin o_seven_ten = D1; o_seven_one = D7; end
		6'b010010: begin o_seven_ten = D1; o_seven_one = D8; end
		6'b010011: begin o_seven_ten = D1; o_seven_one = D9; end
		6'b010100: begin o_seven_ten = D2; o_seven_one = D0; end
		6'b010101: begin o_seven_ten = D2; o_seven_one = D1; end
		6'b010110: begin o_seven_ten = D2; o_seven_one = D2; end
		6'b010111: begin o_seven_ten = D2; o_seven_one = D3; end
		6'b011000: begin o_seven_ten = D2; o_seven_one = D4; end
		6'b011001: begin o_seven_ten = D2; o_seven_one = D5; end
		6'b011010: begin o_seven_ten = D2; o_seven_one = D6; end
		6'b011011: begin o_seven_ten = D2; o_seven_one = D7; end
		6'b011100: begin o_seven_ten = D2; o_seven_one = D8; end
		6'b011101: begin o_seven_ten = D2; o_seven_one = D9; end
		6'b011110: begin o_seven_ten = D3; o_seven_one = D0; end
		6'b011111: begin o_seven_ten = D3; o_seven_one = D1; end
		6'b111111: begin o_seven_ten = D3; o_seven_one = D2; end
		default:   begin o_seven_ten = D3; o_seven_one = D2; end
	endcase
end

endmodule