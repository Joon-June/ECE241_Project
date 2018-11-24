module data_game_flow(
//_________________________Inputs_____________________________//	
		input clk,
		input resetn,
		//________User Input________//
		input go_down,
		input go_right,
		input go_draw,

		//______Control Signal_______//
      input wait_start, 

      //______Stage 1_______//
		input stage_1_begin,
		input stage_1_draw_tower, //used
		input stage_1_in_progress,//used
		input stage_1_done,

		//______Stage 2_______//
		input stage_2_begin,
		input stage_2_draw_tower, //used
		input stage_2_in_progress,//used
		input stage_2_done,

		//______Stage 3_______//
		input stage_3_begin,
		input stage_3_draw_tower, //used
		input stage_3_in_progress,//used
		input stage_3_done,
		
		//___Termina States___//
		input win,
		input game_over,
//_______________________________________________________________//


//__________________________Outputs___________________________//
		//______Control Feedback_____//
		output start_display_done,
		
		//_________STAGE 1___________//
		output stage_1_begin_done,
		output stage_1_tower_done, //used
		output stage_1_car_done,
		output stage_1_end_display_done,
		
		//_________STAGE 2___________//
		output stage_2_begin_done,
		output stage_2_tower_done, //used
		output stage_2_car_done,
		output stage_2_end_display_done,
		
		//_________STAGE 3___________//
		output stage_3_begin_done,
		output stage_3_tower_done, //used
		output stage_3_car_done,
		output stage_3_end_display_done,

		//Terminal States
		output game_over_feedback,
		
		//________VGA Inputs_________//
		output reg [8:0]colours,
		output reg [14:0]coordinates,
		output VGA_write_enable
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

//____________________________________________________________________//



//______________________Module Instatiations__________________________//
	//@@@To be implemented
	//Save Current Situation to following ram
	//Only need to save tower information
	ram19200x9_map_background(
			.address(mem_add),
			.clock(clk),
			.data(9'b0),
			.wren(1'b0),
			.q(colour_erase_square)
	);
	
	
	
	TOWERS T1(
		//_________________________Inputs_____________________________//
      .clk(clk && (stage_1_draw_tower | stage_2_draw_tower | stage_3_draw_tower)),
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
        .clk(clk && (stage_1_in_progress | stage_2_in_progress | stage_3_in_progress)),
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




//___________________________________________________________________//

//@TO DO
//1. When draw_tower, output coord_tower and colour_tower
//____________________________Data Path_____________________________//
always @(*) begin
  	

end




endmodule





