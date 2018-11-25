module control_game_flow(
		input clk,
		input resetn,
		
		//___________________________//
		//______Control Feedback_____//
		//___________________________//
		input start_display_done,
		
		//_________STAGE 1___________//
		input stage_1_begin_done,
		input stage_1_tower_done,
		input stage_1_car_done,
		input stage_1_end_display_done,
		
		//_________STAGE 2___________//
		input stage_2_begin_done,
		input stage_2_tower_done,
		input stage_2_car_done,
		input stage_2_end_display_done,
		
		//_________STAGE 3___________//
		input stage_3_begin_done,
		input stage_3_tower_done,
		input stage_3_car_done,
		input stage_3_end_display_done,
		
		//Terminal State
		input game_over_in,
		
		//___________________________//
		//______Control Signal_______//
		//___________________________//
      output reg wait_start, 
      //______Stage 1_______//
		output reg stage_1_begin,

		output reg stage_1_draw_tower,
		output reg stage_1_in_progress,
		output reg stage_1_done,
		output reg redraw_tower_1,

		//______Stage 2_______//
		output reg stage_2_begin,
		output reg stage_2_draw_tower,
		output reg stage_2_in_progress,
		output reg stage_2_done,

		//______Stage 3_______//
		output reg stage_3_begin,
		output reg stage_3_draw_tower,
		output reg stage_3_in_progress,
		output reg stage_3_done,

		output reg win,
		output reg game_over_out
	);

	reg [3:0] current_state, next_state;
	
	
	//STAGE_BEGIN: Make starting screen in WAIT_START state
	//STAGE_DONE: Make "clear" screen
	localparam RESET = 5'd0,
				  WAIT_START = 5'd1,
				  //____Stage 1_____//
				  STAGE_1_BEGIN = 5'd2,
				  STAGE_1_DRAW_TOWER = 5'd3,
				  STAGE_1_IN_PROGRESS = 5'd4,
				  STAGE_1_DONE = 5'd5,
				  
				  //____Stage 2_____//
				  STAGE_2_BEGIN = 5'd6,
				  STAGE_2_DRAW_TOWER = 5'd7,
				  STAGE_2_IN_PROGRESS = 5'd8,
				  STAGE_2_DONE = 5'd9,
				  
				  //____Stage 3_____//
				  STAGE_3_BEGIN = 5'd10,
				  STAGE_3_DRAW_TOWER = 5'd11,
				  STAGE_3_IN_PROGRESS = 5'd12,
				  STAGE_3_DONE = 5'd13,
				  
				  WIN = 5'd14,
				  GAME_OVER = 5'd15;
				  
	always @(*)
	begin: state_table
		case (current_state)
			
			//___________________________//
			//_______Initia Setup________//
			//___________________________//			
			RESET: next_state = WAIT_START;
			WAIT_START: begin
				if(start_display_done)
					next_state = STAGE_1_BEGIN;
				else
					next_state = WAIT_START;
			end
			
			//___________________________//
			//_________Stage 1___________//
			//___________________________//
		   STAGE_1_BEGIN: begin
				if(stage_1_begin_done)
					next_state = STAGE_1_DRAW_TOWER;
				else
					next_state = STAGE_1_BEGIN;
			end
		   STAGE_1_DRAW_TOWER: begin
				if(stage_1_tower_done)
					next_state = STAGE_1_IN_PROGRESS;
				else
					next_state = STAGE_1_DRAW_TOWER;
			end
		   STAGE_1_IN_PROGRESS: begin
				if(stage_1_car_done)
					next_state = STAGE_1_DONE;
				else if(game_over_in)
					next_state = GAME_OVER;
				else
					next_state = STAGE_1_IN_PROGRESS;
			end
		   STAGE_1_DONE: begin
				if(stage_1_end_display_done)
					next_state = STAGE_2_BEGIN;
				else
					next_state = STAGE_1_DONE;
			end
		  
			//___________________________//
			//_________Stage 2___________//
			//___________________________//
		   STAGE_2_BEGIN: begin
				if(stage_2_begin_done)
					next_state = STAGE_2_DRAW_TOWER;
				else
					next_state = STAGE_2_BEGIN;
			end
		   STAGE_2_DRAW_TOWER: begin
				if(stage_2_tower_done)
					next_state = STAGE_2_IN_PROGRESS;
				else
					next_state = STAGE_2_DRAW_TOWER;
			end
		   STAGE_2_IN_PROGRESS: begin
				if(stage_2_car_done)
					next_state = STAGE_2_DONE;
				else if(game_over_in)
					next_state = GAME_OVER;
				else
					next_state = STAGE_2_IN_PROGRESS;
			end
		   STAGE_2_DONE: begin
				if(stage_2_end_display_done)
					next_state = STAGE_3_BEGIN;
				else
					next_state = STAGE_2_DONE;
			end
		  
			//___________________________//
			//_________Stage 3___________//
			//___________________________//
		   STAGE_3_BEGIN: begin
				if(stage_3_begin_done)
					next_state = STAGE_3_DRAW_TOWER;
				else
					next_state = STAGE_3_BEGIN;
			end
		   STAGE_3_DRAW_TOWER: begin
				if(stage_3_tower_done)
					next_state = STAGE_3_IN_PROGRESS;
				else
					next_state = STAGE_3_DRAW_TOWER;
			end
		   STAGE_3_IN_PROGRESS: begin
				if(stage_3_car_done)
					next_state = STAGE_3_DONE;
				else if(game_over_in)
					next_state = GAME_OVER;
				else
					next_state = STAGE_3_IN_PROGRESS;
			end
		   STAGE_3_DONE: begin
				if(stage_3_end_display_done)
					next_state = WIN;
				else
					next_state = STAGE_3_DONE;
			end
		   
			//____Terminal States______//
		   WIN: begin
				next_state = WIN;
			end
		   GAME_OVER: begin
				next_state = GAME_OVER;
			end
			default: next_state = WAIT_START;
		endcase
	end
	
	// Output logic aka all of our datapath control signals
	always @(*)
	begin: enable_signals
		// By default make all our signals 0 to avoid latches.
        wait_start = 1'b0; 
        //______Stage 1_______//
		stage_1_begin = 1'b0;
		stage_1_draw_tower = 1'b0;
		stage_1_in_progress = 1'b0;
		stage_1_done  = 1'b0;

		//______Stage 2_______//
		stage_2_begin = 1'b0;
		stage_2_draw_tower = 1'b0;
		stage_2_in_progress = 1'b0;
		stage_2_done  = 1'b0;

		//______Stage 3_______//
		stage_3_begin = 1'b0;
		stage_3_draw_tower = 1'b0;
		stage_3_in_progress = 1'b0;
		stage_3_done = 1'b0;

		win = 1'b0;
		game_over_out = 1'b0;

        case (current_state)
            WAIT_START: begin
                wait_start = 1'b1;
            end
			//________Stage 1________//
			STAGE_1_BEGIN: begin
                stage_1_begin = 1'b1;
            end
			STAGE_1_DRAW_TOWER: begin
                stage_1_draw_tower = 1'b1;
            end
			STAGE_1_IN_PROGRESS: begin
                stage_1_in_progress = 1'b1;
            end
			STAGE_1_DONE: begin
				stage_1_done = 1'b1;
			end

			//________Stage 2________//
			STAGE_2_BEGIN: begin
                stage_2_begin = 1'b1;
            end
			STAGE_2_DRAW_TOWER: begin
                stage_2_draw_tower = 1'b1;
            end
			STAGE_2_IN_PROGRESS: begin
                stage_2_in_progress = 1'b1;
            end
			STAGE_2_DONE: begin
				stage_2_done = 1'b1;
			end
			
			//________Stage 1________//
			STAGE_3_BEGIN: begin
                stage_3_begin = 1'b1;
            end
			STAGE_3_DRAW_TOWER: begin
                stage_3_draw_tower = 1'b1;
            end
			STAGE_3_IN_PROGRESS: begin
                stage_3_in_progress = 1'b1;
            end
			STAGE_3_DONE: begin
				stage_3_done = 1'b1;
			end

			WIN: begin
				win = 1'b1;
			end
			GAME_OVER: begin
				game_over_out = 1'b1;
			end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
	
	end
	
	always @(posedge clk)
	begin: state_FFs
		if(!resetn)
			current_state <= RESET;
		else
			current_state <= next_state;
	end
endmodule

