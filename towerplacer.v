module control(
		input clk,
		input resetn,
		input go_down, // ~KEY[0]
		input go_right, // ~KEY[1]
		input go_draw, // ~KEY[2]
		input valid,

		output reg  move_down, move_right, move_down_wait, move_right_wait, draw_square, draw_tower, top_left
   );
	 
	reg [3:0] current_state, next_state; 
	 
	localparam  TOP_LEFT        	  = 5'd0,
               DRAW_SQUARE      = 5'd1,
               WAIT	           = 5'd2,
               MOVE_DOWN	     = 5'd3,
               MOVE_DOWN_WAIT   = 5'd4,
               MOVE_RIGHT       = 5'd5,
               MOVE_RIGHT_WAIT  = 5'd6,
               DRAW_TOWER   	  = 5'd7;
	
	always@(*)
   begin: state_table 
		case (current_state)
                TOP_LEFT: next_state = DRAW_SQUARE;
                DRAW_SQUARE: next_state = WAIT;
                WAIT: begin // wait for user keypress and then move to corresponding state
							if (go_down == 1'b1)
								next_state = MOVE_DOWN;
							else if (go_right == 1'b1)
								next_state = MOVE_RIGHT;
							else if (go_draw == 1'b1)
								next_state = DRAW_TOWER;
							else
								next_state = WAIT;
						end
					 MOVE_DOWN: next_state = valid ? MOVE_DOWN_WAIT : MOVE_DOWN; // continue moving down until the tile is valid
                MOVE_DOWN_WAIT: next_state = go_down ? MOVE_DOWN_WAIT : DRAW_SQUARE; // wait for go_down to be 0
                MOVE_RIGHT: next_state = valid ? MOVE_RIGHT_WAIT : MOVE_RIGHT; // continue moving right until the tile is valid
                MOVE_RIGHT_WAIT: next_state = go_right ? MOVE_RIGHT_WAIT : DRAW_SQUARE; // wait for go_right to be 0
                DRAW_TOWER: next_state = TOP_LEFT; // TEMPORARILY RETURN TO RESET AFTER DRAWING TOWER
			default:     next_state = TOP_LEFT;
		endcase // state table
	end
	
	
    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0 to avoid latches.
		  
		  top_left = 1'b0;
		  draw_square = 1'b0;
		  move_down = 1'b0;
        move_right = 1'b0;
        draw_tower = 1'b0;
		  move_down_wait = 1'b0;
		  move_right_wait = 1'b0;
		  

        case (current_state)
            TOP_LEFT: begin
                top_left = 1'b1;
                end
            DRAW_SQUARE: begin
                draw_square = 1'b1;
                end
            MOVE_DOWN: begin
                move_down = 1'b1;
                end
				MOVE_RIGHT: begin
                move_right = 1'b1;
            end
				MOVE_DOWN_WAIT: begin
                move_down_wait = 1'b1;
                end
				MOVE_RIGHT_WAIT: begin
                move_right_wait = 1'b1;
            end
				DRAW_TOWER: begin // Do A <- A + c
					 draw_tower = 1'b1;
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= TOP_LEFT;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

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
