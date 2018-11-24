module middle_states(
//___________________Inputs_______________________//
        input clk,
        input resetn,
        //______Control Signal_______//
       input wait_start, 

      //______Stage 1_______//
		input stage_1_begin,
		input stage_1_done,

		//______Stage 2_______//
		input stage_2_begin,
		input stage_2_done,

		//______Stage 3_______//
		input stage_3_begin,
		input stage_3_done,
		
		//___Termina States___//
		input win,
		input game_over,
//_________________________________________________//

//___________________Outputs_______________________//
        //______Control Feedback_____//
		output start_display_done,
		
		//_________STAGE 1___________//
		output stage_1_begin_done,
		output stage_1_end_display_done,
		
		//_________STAGE 2___________//
		output stage_2_begin_done,
		output stage_2_end_display_done,
		
		//_________STAGE 3___________//
		output stage_3_begin_done,
		output stage_3_end_display_done,

		//Terminal States
        output WIN_done,
        output LOSE_done,
        output SAVE_GPA_done,

        //VGA_Outputs
 		output reg [8:0]colour,
		output reg [14:0]coordinates,
		output VGA_write_enable       
//_________________________________________________//
);

//____________________Wires & Registers__________________//
    wire [8:0] colour_WIN, colour_LOSE, colour_SAVE_GPA;
    wire [8:0] colour_stage_1_start, colour_stage_1_clear;
    wire [8:0] colour_stage_2_start, colour_stage_2_clear;
    wire [8:0] colour_stage_3_start, colour_stage_3_clear;

    wire [14:0] coord_WIN, coord_LOSE, coord_SAVE_GPA;
    wire [14:0] coord_stage_1_start, coord_stage_1_clear;
    wire [14:0] coord_stage_2_start, coord_stage_2_clear;
    wire [14:0] coord_stage_3_start, coord_stage_3_clear;

    assign VGA_write_enable = wait_start | stage_1_begin | stage_1_done | 
                          stage_2_begin | stage_2_done | stage_3_begin | 
                          stage_3_done | win | game_over;

//_______________________________________________________//


//__________________Module Instantiations_________________//
    
    //______________Terminal States_____________//
    draw_SAVE_GPA SG1(
        .clk(clk && wait_start),
        .resetn(resetn),
        .SAVE_GPA_done(SAVE_GPA_done),
        .colour(colour_SAVE_GPA),
        .x(coord_SAVE_GPA[14:7]),
        .y(coord_SAVE_GPA[6:0])
    )
    draw_WIN W1(
        .clk(clk && win),
        .resetn(resetn),
        .WIN_done(WIN_done),
        .colour(colour_WIN),
        .x(coord_WIN[14:7]),
        .y(coord_WIN[6:0])
    );

    draw_LOSE L1(
        .clk(clk && game_over),
        .resetn(resetn),
        .LOSE_done(LOSE_done),
        .colour(colour_LOSE),
        .x(coord_LOSE[14:7]),
        .y(coord_LOSE[6:0])
    );
    //__________________________________________//

    draw_stage_1_start s1_start(
        .clk(clk && stage_1_begin),
        .resetn(resetn),
        .stage_1_start_done(stage_1_begin_done),
        .colour(colour_stage_1_start),
        .x(coord_stage_1_start[14:7]),
        .y(coord_stage_1_start[6:0])
    );

    draw_stage_1_clear s1_clear(
        .clk(clk && stage_1_done),
        .resetn(resetn),
        .stage_1_clear_done(stage_1_end_display_done),
        .colour(colour_stage_1_clear),
        .x(coord_stage_1_clear[14:7]),
        .y(coord_stage_1_clear[6:0])
    );
    
    draw_stage_2_start s2_start(
        .clk(clk && stage_2_begin),
        .resetn(resetn),
        .stage_2_start_done(stage_2_begin_done),
        .colour(colour_stage_2_start),
        .x(coord_stage_2_start[14:7]),
        .y(coord_stage_2_start[6:0])
    );

    draw_stage_2_clear s2_clear(
        .clk(clk && stage_2_done),
        .resetn(resetn),
        .stage_2_clear_done(stage_2_end_display_done),
        .colour(colour_stage_2_clear),
        .x(coord_stage_2_clear[14:7]),
        .y(coord_stage_2_clear[6:0])
    );

    draw_stage_3_start s3_start(
        .clk(clk && stage_3_begin),
        .resetn(resetn),
        .stage_3_start_done(stage_3_begin_done),
        .colour(colour_stage_3_start),
        .x(coord_stage_3_start[14:7]),
        .y(coord_stage_3_start[6:0])
    );
    
    
    draw_stage_3_clear s3_clear(
        .clk(clk && stage_3_done),
        .resetn(resetn),
        .stage_3_clear_done(stage_3_end_display_done),
        .colour(colour_stage_3_clear),
        .x(coord_stage_3_clear[14:7]),
        .y(coord_stage_3_clear[6:0])
    );
//________________________________________________________//

    always @(posedge clk) begin
        if(wait_start) begin
            //draw starting display
            colour <= colour_SAVE_GPA;
            coordinates <= coord_SAVE_GPA;
            //count 10 seconds then
            //start_display_done <= 1;
        end
        else if(stage_1_begin) begin
            //@
            //draw map (initial)
            //wait 1 second
            //draw stage_1_start, then
            colour <= colour_stage_1_start;
            coordinates <= coord_stage_1_start;
            //stage_1_begin_done <= 1;

        end
        else if(stage_1_done) begin
            //@
            //if(stage_1_end_display_done == 0)
            //draw stage_1_clear, then
            colour <= colour_stage_1_clear;
            coordinates <= coord_stage_1_clear;
            //stage_1_end_display_done <= 1;
        end
        else if(stage_2_begin) begin
            //@
            //if(stage_2_begin_done == 0)
            //draw stage_2_start, then
            colour <= colour_stage_2_start;
            coordinates <= coord_stage_2_start;
            //stage_2_begin_done <= 1;
        end
        else if(stage_2_done) begin
            //@
            //if(stage_2_end_display_done == 0)
            //draw stage_2_clear, then
            colour <= colour_stage_2_clear;
            coordinates <= coord_stage_2_clear;
            //stage_2_end_display_done <= 1;
        end
        else if(stage_3_begin) begin
            //@
            //if(stage_3_begin_done == 0)
            //draw stage_3_start, then
            colour <= colour_stage_3_start;
            coordinates <= coord_stage_3_start;
            //stage_3_begin_done <= 1;
        end
        else if(stage_3_done) begin
            //if(stage_3_end_display_done == 0)
            //draw stage_3_clear, then
            colour <= colour_stage_3_clear;
            coordinates <= coord_stage_3_clear;
            //stage_3_end_display_done <= 1;
        end
        else if(win) begin
            //draw win display
            colour <= colour_WIN;
            coordinates <= coord_WIN;
        end
        else if(game_over) begin
            //draw game over display
            colour <= colour_LOSE;
            coordinates <= coord_LOSE;
        end
        else begin //to prevent a latch
            colour <= 0;
            coordinates <= 0;
        end
    end

 game_over_feedback
endmodule