module datapath(
    input clk,
    input resetn,
    input [7:0] row, // from memory, holds 0s where nothing is in the square, 1 if something is there (ie valid)
    input ld_alu_out, 
    input top_left, draw_square, move_right, move_down, move_down_wait, move_right_wait,
    output reg valid
    );
	 
	 reg [2:0]Counter_X; // Column in grid, not coordinates on vga
	 reg [2:0]Counter_Y; // Row in grid, not coordinates on vga
	 reg down_wait = 1'b0;
	 
	 always@(posedge clk) begin
		if (!resetn) begin
			Counter_X <= 0;
			Counter_Y <= 0;
			valid <= 0;
		end
		else if (top_left) begin
			Counter_X <= 0;
			Counter_Y <= 0;
			valid <= 0;
		end
		else if (draw_square) begin
			
		end
		else if (move_right) begin
			if(Counter_X<3'b111) begin // increment counter, update valid
				Counter_X <= Counter_X + 1;
				valid <= ~(row[Counter_X + 1]);
			end
			else begin
				Counter_X <= 0;
				valid <= ~row[0];
			end
		end
		else if (move_down) begin // because move down needs to get a new memory from memory, it has to wait for one cycle
			if(down_wait) begin // on second cycle in move_down, update valid
				valid = ~(row[Counter_X]);
			end
			else begin // on first cycle in move_down, increment counter
				if(Counter_Y<3'b101)
					Counter_Y <= Counter_Y + 1;
				else
					Counter_Y <= 0;
			end
			down_wait <= ~down_wait; // toggle down_wait, is zero on first cycle, 1 on second cycle
		end
		else if (move_down_wait) begin
			valid <= 0;
			down_wait <= 0; // only changed on down_wait
		end
		else if (move_right_wait) begin
			valid <= 0;
		end
	end
endmodule