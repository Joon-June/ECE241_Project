module control_towerplacer(
		input clk,
		input resetn,
		input go_down, // ~KEY[0]
		input go_right, // ~KEY[1]
		input go_draw, // ~KEY[2]
		input valid,
        input square_done,
        input erase_square_done,
        input tower_done,
        input enable_draw,

		output reg move_down, 
        output reg move_right, 
        output reg move_down_wait, 
        output reg move_right_wait, 
        output reg draw_square, 
        output reg draw_tower, 
        output reg top_left,
        output reg erase_square_right,
        output reg erase_square_down,
        output reg erase_square_tower
   );
	 
	reg [3:0] current_state, next_state; 
	 
	localparam TOP_LEFT        	  = 5'd0,
               DRAW_SQUARE         = 5'd1,
               WAIT	              = 5'd2,
               MOVE_DOWN	        = 5'd3,
               MOVE_DOWN_WAIT      = 5'd4,
               MOVE_RIGHT          = 5'd5,
               MOVE_RIGHT_WAIT     = 5'd6,
               DRAW_TOWER   	     = 5'd7,
               ERASE_SQUARE_RIGHT  = 5'd8,
               ERASE_SQUARE_DOWN   = 5'd10,
               ERASE_SQUARE_TOWER  = 5'd11,
					DRAW_TOWER_DONE     = 5'd12;
	
   always @ (*)
   begin: state_table 
		case (current_state)
                TOP_LEFT: begin
                   if(enable_draw)
                        next_state = DRAW_SQUARE;
                    else
                        next_state = TOP_LEFT;
                end
                DRAW_SQUARE: begin
                    if(square_done)
                        next_state = WAIT;
                    else
                        next_state = DRAW_SQUARE;
                end
                WAIT: begin // wait for user keypress and then move to corresponding state
                    if (go_down == 1'b1)
                        next_state = ERASE_SQUARE_DOWN;
                    else if (go_right == 1'b1)
                        next_state = ERASE_SQUARE_RIGHT;
                    else if (go_draw == 1'b1)
                        next_state = ERASE_SQUARE_TOWER;
                    else
                        next_state = WAIT;
					end
					MOVE_DOWN: begin // continue moving down until the tile is valid
                    if(valid)
                        next_state = MOVE_DOWN_WAIT;
                    else
                        next_state = MOVE_DOWN;
                end                 
                MOVE_DOWN_WAIT: begin // wait for user to release go_down key
                    if(go_down)
                        next_state = MOVE_DOWN_WAIT;
                    else
                        next_state = DRAW_SQUARE;
                end
                MOVE_RIGHT: begin // continue moving right until the tile is valid
                    if(valid)
                        next_state = MOVE_RIGHT_WAIT;
                    else
                        next_state = MOVE_RIGHT;
                end              
                MOVE_RIGHT_WAIT: begin // wait for user to release go_right key
                    if(go_right)
                        next_state = MOVE_RIGHT_WAIT;
                    else
                        next_state = DRAW_SQUARE;
                end
                DRAW_TOWER: begin // TEMPORARILY RETURN TO RESET AFTER DRAWING TOWER
                    if(tower_done)
                        next_state = DRAW_TOWER_DONE;
                    else
                        next_state = DRAW_TOWER;
                end
                ERASE_SQUARE_RIGHT: begin //Erase current cell's square before moving right
                    if(erase_square_done)
                        next_state = MOVE_RIGHT;
                    else
                        next_state = ERASE_SQUARE_RIGHT;
                end
                ERASE_SQUARE_DOWN: begin //Erase current cell's square before moving down
                    if(erase_square_done)
                        next_state = MOVE_DOWN;
                    else
                        next_state = ERASE_SQUARE_DOWN;
                end
                ERASE_SQUARE_TOWER: begin
                    if(erase_square_done)
                        next_state = DRAW_TOWER;
                    else
                        next_state = ERASE_SQUARE_TOWER;
                end
					 DRAW_TOWER_DONE: next_state = DRAW_TOWER_DONE;
            default: next_state = TOP_LEFT;
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
        draw_tower = 1'b0;
        erase_square_down = 1'b0;
        erase_square_right = 1'b0;
        erase_square_tower = 1'b0;

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
            ERASE_SQUARE_DOWN: begin
                erase_square_down = 1'b1;
            end
            ERASE_SQUARE_RIGHT: begin
                erase_square_right = 1'b1;
            end
            ERASE_SQUARE_TOWER: begin
                erase_square_tower = 1'b1;
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
