module control(
		input clk,
		input resetn,
		input go_down, // KEY[0]
		input go_right, // KEY[1]
		input go_pick, // KEY[2]
		input valid,

		output reg  move_down, move_right, draw_square, draw_tower, top_left
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
