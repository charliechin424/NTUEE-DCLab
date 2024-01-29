module score_ctrl
(
	input clk,
	input rst_n,
	
	input add_cube,
	input [1:0]game_status,

	output [11:0] bcd_data
);
	logic [7:0]bin_data;

   localparam RESTART = 2'b00;
    
	always_ff@(posedge clk or negedge rst_n) begin
		if(!rst_n) 										
			bin_data <= 0;
		else if(game_status==RESTART)					
			bin_data <= 0;	
		else if(add_cube==1 && bin_data < 8'd100)		
			bin_data <= bin_data + 1;
		else 
			bin_data <= bin_data;
		end
	
	assign bcd_data[3:0]  = bin_data%10;				
	assign bcd_data[7:4]  = (bin_data/10)%10;			
	assign bcd_data[11:8] = (bin_data/100)%10;

endmodule