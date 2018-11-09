module datapath(
    input clk,
    input resetn,
    input [7:0] row, // from memory, holds 0s where nothing is in the square, 1 if something is there (ie valid)
    input ld_alu_out, 
    input top_left, draw_square, move_right, move_down, move_down_wait, move_right_wait,
    output reg valid
    );
	 
	 reg Counter_X; // Column in grid, not coordinates on vga
	 reg Counter_Y; // Row in grid, not coordinates on vga
	 
	 always@(posedge clk) begin
		if (!resetn) begin
			
		end
		else if (top_left) begin
			
		end
		else if (draw_square) begin
			
		end
		else if (move_right) begin
			
		end
		else if (move_down) begin
			
		end
		else if (move_down_wait) begin
			
		end
		else if (move_right_wait) begin
			
		end
	end
endmodule
