module middle_states(
//___________________Inputs_______________________//
        input clk,
        input resetn,
        input start,
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

        //_____Current Map_____//
        input [8:0]curr_colour,
//_________________________________________________//

//___________________Outputs_______________________//
        //______Control Feedback_____//
		output reg start_display_done,
		
		//_________STAGE 1___________//
		output reg stage_1_begin_done,
		output reg stage_1_end_display_done,
		
		//_________STAGE 2___________//
		output reg stage_2_begin_done,
		output reg stage_2_end_display_done,
		
		//_________STAGE 3___________//
		output reg stage_3_begin_done,
		output reg stage_3_end_display_done,

		//Terminal States
        // output WIN_done,
        // output LOSE_done,
        // output SAVE_GPA_done,

        //VGA_Outputs
 		output reg [8:0]colour,
		output reg [14:0]coordinates,
		output VGA_write_enable,

        //Memory address to curr state
        output [14:0]mem_add_curr_state


//_________________________________________________//
);

//____________________Wires & Registers__________________//
    wire [8:0] colour_WIN, colour_LOSE, colour_SAVE_GPA;
    wire [8:0] colour_stage_1_start, colour_stage_1_clear;
    wire [8:0] colour_stage_2_start, colour_stage_2_clear;
    wire [8:0] colour_stage_3_start, colour_stage_3_clear;
    wire [8:0] colour_map, colour_erase_80x40;

    wire [14:0] coord_WIN, coord_LOSE, coord_SAVE_GPA;
    wire [14:0] coord_stage_1_start, coord_stage_1_clear;
    wire [14:0] coord_stage_2_start, coord_stage_2_clear;
    wire [14:0] coord_stage_3_start, coord_stage_3_clear;
    wire [14:0] coord_map, coord_erase_80x40;

    wire stage_1_begin_done_temp, stage_1_end_display_done_temp;
    wire stage_2_begin_done_temp, stage_2_end_display_done_temp;
    wire stage_3_begin_done_temp, stage_3_end_display_done_temp;

    wire counter_done, erase_done, SAVE_GPA_done, WIN_done, LOSE_done, map_done;
    reg map_enable, erase, counter_enable;


    assign VGA_write_enable = wait_start | stage_1_begin | stage_1_done | 
                          stage_2_begin | stage_2_done | stage_3_begin | 
                          stage_3_done | win | game_over;
    
    initial begin
        map_enable = 0;
        erase = 0;
        counter_enable = 0;
    end
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
    );
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
        .stage_1_start_done(stage_1_begin_done_temp),
        .colour(colour_stage_1_start),
        .x(coord_stage_1_start[14:7]),
        .y(coord_stage_1_start[6:0])
    );

    draw_stage_1_clear s1_clear(
        .clk(clk && stage_1_done),
        .resetn(resetn),
        .stage_1_clear_done(stage_1_end_display_done_temp),
        .colour(colour_stage_1_clear),
        .x(coord_stage_1_clear[14:7]),
        .y(coord_stage_1_clear[6:0])
    );
    
    draw_stage_2_start s2_start(
        .clk(clk && stage_2_begin),
        .resetn(resetn),
        .stage_2_start_done(stage_2_begin_done_temp),
        .colour(colour_stage_2_start),
        .x(coord_stage_2_start[14:7]),
        .y(coord_stage_2_start[6:0])
    );

    draw_stage_2_clear s2_clear(
        .clk(clk && stage_2_done),
        .resetn(resetn),
        .stage_2_clear_done(stage_2_end_display_done_temp),
        .colour(colour_stage_2_clear),
        .x(coord_stage_2_clear[14:7]),
        .y(coord_stage_2_clear[6:0])
    );

    draw_stage_3_start s3_start(
        .clk(clk && stage_3_begin),
        .resetn(resetn),
        .stage_3_start_done(stage_3_begin_done_temp),
        .colour(colour_stage_3_start),
        .x(coord_stage_3_start[14:7]),
        .y(coord_stage_3_start[6:0])
    );
    
    
    draw_stage_3_clear s3_clear(
        .clk(clk && stage_3_done),
        .resetn(resetn),
        .stage_3_clear_done(stage_3_end_display_done_temp),
        .colour(colour_stage_3_clear),
        .x(coord_stage_3_clear[14:7]),
        .y(coord_stage_3_clear[6:0])
    );

    draw_map map(
        .clk(clk),
        .resetn(resetn),
        .enable(map_enable),
        .map_done(map_done),
        .colour(colour_map),
        .x(coord_map[14:7]),
        .y(coord_map[6:0])
    );

    erase_80x40 erase_stages(
        .clk(clk),
        .resetn(resetn),
        .enable(erase),
        .colour_erase_from_ram(curr_colour),
        .erase_done(erase_done),
        .mem_add_read_from_ram(mem_add_curr_state),
        .colour(colour_erase_80x40),        
        .x(coord_erase_80x40[14:7]),
        .y(coord_erase_80x40[6:0])
    );

    counter_2seconds counter(
        .clk(clk), 
        .resetn(resetn), 
        .enable(counter_enable), 
        .out(counter_done)
    );

//________________________________________________________//

    always @(posedge clk) begin
        if(!resetn) begin
            //______Control Feedback_____//
            start_display_done <= 0;
            
            //_________STAGE 1___________//
            stage_1_begin_done <= 0;
            stage_1_end_display_done <= 0;
            
            //_________STAGE 2___________//
            stage_2_begin_done <= 0;
            stage_2_end_display_done <= 0;
            
            //_________STAGE 3___________//
            stage_3_begin_done <= 0;
            stage_3_end_display_done <= 0;

            //VGA_Outputs
            colour <= 0;
            coordinates <= 0;
        end
        
        if(wait_start) begin
            
            //draw starting display
            colour <= colour_SAVE_GPA;
            coordinates <= coord_SAVE_GPA;
            //Account for user input
            if(start) begin
              map_enable <= 1;
            end
            //Draw map
            if(map_enable) begin
                colour <= colour_map;
                coordinates <= coord_map;
                start_display_done <= map_done;
                map_enable <= ~map_done;
            end
        end
        else if(stage_1_begin) begin
            if(!stage_1_begin_done_temp) begin
                //draw stage_1_start, then
                colour <= colour_stage_1_start;
                coordinates <= coord_stage_1_start;
            end
            else begin
                counter_enable <= 1;
            end

            if(counter_done) begin
                erase <= 1;
                counter_enable <= 0;
            end
            
            if(erase) begin
                counter_enable <= 0;
                colour <= colour_erase_80x40;
                coordinates <= coord_erase_80x40;
                stage_1_begin_done <= erase_done;
                erase <= ~erase_done;
            end            
            else if(stage_1_begin_done)
                counter_enable <= 0;
            
        end
        else if(stage_1_done) begin
            if(!stage_1_end_display_done_temp) begin
                //draw stage_1_start, then
                colour <= colour_stage_1_clear;
                coordinates <= coord_stage_1_clear;
            end
            else begin
                counter_enable <= 1;
            end

            if(counter_done) begin
                erase <= 1;
                counter_enable <= 0;
            end
            
            if(erase) begin
                counter_enable <= 0;
                colour <= colour_erase_80x40;
                coordinates <= coord_erase_80x40;
                stage_1_end_display_done <= erase_done;
                erase <= ~erase_done;
            end
            else if(stage_1_end_display_done)
                counter_enable <= 0;
        end
        else if(stage_2_begin) begin
            if(!stage_2_begin_done_temp) begin
                //draw stage_1_start, then
                colour <= colour_stage_2_start;
                coordinates <= coord_stage_2_start;
            end
            else begin
                counter_enable <= 1;
            end

            if(counter_done) begin
                erase <= 1;
                counter_enable <= 0;
            end

            if(erase) begin
                counter_enable <= 0;
                colour <= colour_erase_80x40;
                coordinates <= coord_erase_80x40;
                stage_2_begin_done <= erase_done;
                erase <= ~erase_done;
            end
            else if(stage_2_begin_done)
                counter_enable <= 0;
        end
        else if(stage_2_done) begin
            if(!stage_2_end_display_done_temp) begin
                //draw stage_1_start, then
                colour <= colour_stage_2_clear;
                coordinates <= coord_stage_2_clear;
            end
            else begin
                counter_enable <= 1;
            end

            if(counter_done) begin
                erase <= 1;
                counter_enable <= 0;
            end

            if(erase) begin
                counter_enable <= 0;
                colour <= colour_erase_80x40;
                coordinates <= coord_erase_80x40;
                stage_2_end_display_done <= erase_done;
                erase <= ~erase_done;
            end
            else if(stage_2_end_display_done)
                counter_enable <= 0;
        end
        else if(stage_3_begin) begin
           if(!stage_3_begin_done_temp) begin
                //draw stage_1_start, then
                colour <= colour_stage_3_start;
                coordinates <= coord_stage_3_start;
            end
            else begin
                counter_enable <= 1;
            end

           if(counter_done) begin
                erase <= 1;
                counter_enable <= 0;
            end

            if(erase) begin
                counter_enable <= 0;
                colour <= colour_erase_80x40;
                coordinates <= coord_erase_80x40;
                stage_3_begin_done <= erase_done;
                erase <= ~erase_done;
            end
            else if(stage_3_begin_done)
                counter_enable <= 0;
        end
        else if(stage_3_done) begin
            if(!stage_3_end_display_done_temp) begin
                //draw stage_1_start, then
                colour <= colour_stage_3_clear;
                coordinates <= coord_stage_3_clear;
            end
            else begin
                counter_enable <= 1;
            end

            if(counter_done) begin
                erase <= 1;
                counter_enable <= 0;
            end

            if(erase) begin
                counter_enable <= 0;
                colour <= colour_erase_80x40;
                coordinates <= coord_erase_80x40;
                stage_3_end_display_done <= erase_done;
                erase <= ~erase_done;
            end
            else if(stage_3_end_display_done)
                counter_enable <= 0;
        end
        else if(win) begin
            if(!WIN_done) begin
                //draw win display
                colour <= colour_WIN;
                coordinates <= coord_WIN;
            end
        end
        else if(game_over) begin
            if(!LOSE_done) begin
                //draw game over display
                colour <= colour_LOSE;
                coordinates <= coord_LOSE;
            end
        end
        else begin //to prevent a latch
            colour <= 0;
            coordinates <= 0;
        end
    end
endmodule

// Module to separate clock pulses to every 1/60th of a second
module counter_2seconds(clk, resetn, enable, out);
	input clk;
	input resetn;
	input enable;
	output reg out;

	reg [26:0] Q;

	always @(posedge clk) begin
		if (!resetn) begin
			Q <= 0;
			out <= 0;
		end

        if(enable) begin
            if (Q == 27'b101111101011110000100000000) begin //10 Million = 2 seconds
                out <= 1;
                Q <= 0;
            end

            else begin
                Q <= Q + 1;
                out <= 0;
            end
        end
	end
endmodule
