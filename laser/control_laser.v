module control_laser(
		input clk,
		input resetn,
		input initiate, // corresponding tower is placed
		input enable_draw, // begin drawing cycle
		//_____Control Feedback ___//
		input car_in_range,
		input draw_done,
		input drawn,
		input erase_done,
		input delay_done,

		//_____Control Signals ___//
		output reg disabled, 
      output reg wait_draw, 
      output reg draw_laser, 
      output reg delay, 
      output reg erase
   );
	 
	reg [3:0] current_state, next_state; 
	 
	localparam DISABLED        	  = 5'd0,
              WAIT_DRAW            = 5'd1,
              DRAW_LASER	        = 5'd2,
              ERASE	              = 5'd3,
				  DELAY 		           = 5'd4;
	
   always @ (*)
   begin: state_table
		case (current_state)
                DISABLED: begin
                    if(initiate == 1'b1)
                        next_state = WAIT_DRAW;
                    else
                        next_state = DISABLED;
                end
                WAIT_DRAW: begin
                    if ((car_in_range == 1'b1) && (enable_draw == 1'b1))
                        next_state = DRAW_LASER;
//						  else if ((car_in_range == 1'b0) && ((enable_draw == 1'b1) && (drawn == 1'b1)))
//								next_state = ERASE;
                    else
                        next_state = WAIT_DRAW;
					 end
                DRAW_LASER: begin // wait for the drawing of this car to be enabled
						if(draw_done == 1'b1)
							next_state = WAIT_DRAW;
						else
                    next_state = DRAW_LASER;
					 end                 
                ERASE: begin
                    if(erase_done == 1'b1)
								next_state = DELAY;
                    else
                        next_state = ERASE;
                end            
                DELAY: begin
                    if(delay_done == 1'b1)
                        next_state = WAIT_DRAW;
                    else
                        next_state = DELAY;
                end
            default: next_state = DISABLED;
		endcase // state table
	end
	
	
    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0 to avoid latches.
		  
        wait_draw = 1'b0; 
        draw_laser = 1'b0;
        delay = 1'b0;
        erase = 1'b0;
        disabled = 1'b0;

        case (current_state)
            DISABLED: begin
                disabled = 1'b1;
            end
				WAIT_DRAW: begin
                wait_draw = 1'b1;
            end
				DRAW_LASER: begin
                draw_laser = 1'b1;
            end
				DELAY: begin
                delay = 1'b1;
            end
				ERASE: begin
                erase = 1'b1;
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= DISABLED;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
