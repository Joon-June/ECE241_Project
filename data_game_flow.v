module data_game_flow(
//_________________________Inputs_____________________________//	
		input clk,
		input resetn,
		//________User Input________//
		input go_down,
		input go_right,
		input go_draw,
		input start,

		//______Control Signal_______//
      input wait_start, //used

      //______Stage 1_______//
		input stage_1_begin,//used
		input stage_1_draw_tower, //used
		input stage_1_in_progress,//used
		input stage_1_done,//used

		//______Stage 2_______//
		input stage_2_begin,//used
		input stage_2_draw_tower, //used
		input stage_2_in_progress,//used
		input stage_2_done,//used

		//______Stage 3_______//
		input stage_3_begin,//used
		input stage_3_draw_tower, //used
		input stage_3_in_progress,//used
		input stage_3_done,//used
		
		//___Termina States___//
		input win,//used
		input game_over,//used
//_______________________________________________________________//


//__________________________Outputs___________________________//
		//______Control Feedback_____//
		output start_display_done,//used
		
		//_________STAGE 1___________//
		output stage_1_begin_done,//used
		output stage_1_tower_done, //used
		output stage_1_car_done,
		output stage_1_end_display_done,//used
		
		//_________STAGE 2___________//
		output stage_2_begin_done,//used
		output stage_2_tower_done, //used
		output stage_2_car_done,
		output stage_2_end_display_done,
		
		//_________STAGE 3___________//
		output stage_3_begin_done,//used
		output stage_3_tower_done, //used
		output stage_3_car_done,
		output stage_3_end_display_done,

		//Terminal States
		output game_over_feedback,//used
		
		//________VGA Inputs_________//
		output reg [8:0]colour,//used
		output reg [14:0]coordinates,//used
		output reg VGA_write_enable//used
	//_______________________________________________________________//
	);
	

//_________________________Wires & Registers_________________________//
	
	//_______________Tower Related Wires___________//
	wire tower_wren;
	wire [8:0]colour_tower;
	wire [14:0]coord_tower;

	//_______________Car Related Wires_____________//
	wire car_wren;
	wire [8:0]colour_car;
	wire [14:0]coord_car;

	//__________Middle States Related Wires________//
	wire middle_wren;
	wire [8:0]colour_middle;
	wire [14:0]coord_middle;

	wire [8:0]curr_colour;
	wire [14:0]mem_add_curr_state;

//____________________________________________________________________//



//______________________Module Instatiations__________________________//
	//@@@To be implemented
	//Save Current Situation to following ram
	//Need to save tower & car information
	ram19200x9_map_background Current_State(
			.address(mem_add_curr_state), //to be fixed using mux later on
			.clock(clk),
			.data(9'b0),
			.wren(1'b0),
			.q(curr_colour) //to be fixed using mux later on
	);

	TOWERS T1(
		//_________________________Inputs_____________________________//
      .clk(clk),//  && (stage_1_draw_tower | stage_2_draw_tower | stage_3_draw_tower)),
      .resetn(resetn),
      //________User Input________//
		.go_down(go_down),
		.go_right(go_right),
		.go_draw(go_draw),
    
      //_____Control Signlas______//
      .stage_1_draw_tower(stage_1_draw_tower),
      .stage_2_draw_tower(stage_2_draw_tower),
      .stage_3_draw_tower(stage_3_draw_tower),

		//_______________________Outputs_____________________________//
		.tower_wren(tower_wren),
      //_____Control Feedback_____//
      .stage_1_tower_done(stage_1_tower_done),
      .stage_2_tower_done(stage_2_tower_done),
      .stage_3_tower_done(stage_3_tower_done),

      //_______VGA Outputs________//
      .coord(coord_tower),
      .colour(colour_tower)
	);

	CARS C1(
		//_________________________Inputs_____________________________//
        .clk(clk), // && (stage_1_in_progress | stage_2_in_progress | stage_3_in_progress)),
        .resetn(resetn),
        
        //________Control Signal__________//
        .stage_1_in_progress(stage_1_in_progress),
        .stage_2_in_progress(stage_2_in_progress),
        .stage_3_in_progress(stage_3_in_progress),
		//___________________________________________________________//


		//_______________________Outputs_____________________________//
        .car_wren(car_wren),

        .stage_1_car_done(stage_1_car_done), //It means all cars are destroyed
        .stage_2_car_done(stage_2_car_done),
        .stage_3_car_done(stage_3_car_done),

        //_________VGA Outputs_________//
        .coord(coord_car),
        .colour(colour_car),

        //Terminal States
        .game_over_feedback(game_over_feedback)
		//__________________________________________________________//	
	);

	middle_states m1(
//___________________Inputs_______________________//
        .clk(clk),
        .resetn(resetn),
        .start(start),
        //______Control Signal_______//
       .wait_start(wait_start), 

      //______Stage 1_______//
		.stage_1_begin(stage_1_begin),
		.stage_1_done(stage_1_done),

		//______Stage 2_______//
		.stage_2_begin(stage_2_begin),
		.stage_2_done(stage_2_done),

		//______Stage 3_______//
		.stage_3_begin(stage_3_begin),
		.stage_3_done(stage_3_done),
		
		//___Termina States___//
		.win(win),
		.game_over(game_over),

        //_____Current Map_____//
        .curr_colour(curr_colour),
//_________________________________________________//

//___________________Outputs_______________________//
        //______Control Feedback_____//
		.start_display_done(start_display_done),
		
		//_________STAGE 1___________//
		.stage_1_begin_done(stage_1_begin_done),
		.stage_1_end_display_done(stage_1_end_display_done),
		
		//_________STAGE 2___________//
		.stage_2_begin_done(stage_2_begin_done),
		.stage_2_end_display_done(stage_2_end_display_done),
		
		//_________STAGE 3___________//
		.stage_3_begin_done(stage_3_begin_done),
		.stage_3_end_display_done(stage_3_end_display_done),

		//Terminal States
        // .WIN_done,
        // .LOSE_done,
        // .SAVE_GPA_done,

        //VGA_Outputs
 		.colour(colour_middle),
		.coordinates(coord_middle),
		.VGA_write_enable(middle_wren),

        //Memory address to curr state
        .mem_add_curr_state(mem_add_curr_state)
//_________________________________________________//
);


//___________________________________________________________________//

//@TO DO
//1. When draw_tower, output coord_tower and colour_tower
//____________________________Data Path_____________________________//
always @(*) begin
  	if(tower_wren) begin
		colour <= colour_tower;
		coordinates <= coord_tower;
		VGA_write_enable <= tower_wren;
	end
	else if(car_wren) begin
		colour <= colour_car;
		coordinates <= coord_car;
		VGA_write_enable <= car_wren;
	end
	else if(middle_wren) begin
		colour <= colour_middle;
		coordinates <= coord_middle;
		VGA_write_enable <= middle_wren;
	end
	else begin
		colour <= 0;
		coordinates <= 0;
		VGA_write_enable <= 0;
	end
end




endmodule





