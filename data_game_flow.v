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
		input stage_1_done, //stage_1_cl

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
//____________________________________________________________//


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
		output reg [8:0]colour,
		output reg [14:0]coordinates,
		output VGA_write_enable
	//_______________________________________________________________//
	);
	

//_________________________Wires & Registers_________________________//
	
	//_______________Tower Related Wires___________//
	wire tower_wren;
	wire [8:0]colour_tower;
	wire [14:0]coord_tower;
	wire tower_1_drawn, tower_2_drawn, tower_3_drawn;
	wire [14:0] tower_1_location, tower_2_location, tower_3_location;

	//_______________Car Related Wires_____________//
	wire car_wren;
	wire [8:0]colour_car;
	wire [14:0]coord_car;
	wire [14:0] car_0_coords, car_1_coords, car_2_coords, car_3_coords;
	wire [3:0]destroyed_cars;
	
	//_______________Laser Related Wires_____________//
	wire laser_wren;
	wire [8:0]colour_laser;
	wire [14:0]coord_laser;
	
	//_______________Signal for controlling laser/car drawing_____________//
	wire enable_laser_draw;
	wire enable_car_draw;

	//______________________Control signals for map background__________________________//
	wire back_wren;
	wire [8:0]out_colour;
	wire [8:0]in_colour;
	wire [14:0]mem_add;
	
	assign VGA_write_enable = car_wren | laser_wren | tower_wren;

//______________________Module Instatiations__________________________//
	//Common map background
	ram19200x9_map_background MBCKGD(
			.address(mem_add),
			.clock(clk),
			.data(colour_tower),
			.wren(back_wren),
			.q(out_colour)
	);
	
	FrameCounter_30 FC1(.Clock(clk), .resetn(resetn), .Enable30(enable_laser_draw));
	
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
      .colour(colour_tower),
		//_______Reading from Map for Erase Square____//
		.colour_erase_square_from_mem(out_colour),
		.erase_mem_address(mem_add),
		//_______Write to Map____//
		.writeToMapEnable(back_wren),
		//_______Tower Locations____//
		.tower_1_location(tower_1_location),
		.tower_1_drawn(tower_1_drawn),
		.tower_2_location(tower_2_location),
		.tower_2_drawn(tower_2_drawn),
		.tower_3_location(tower_3_location),
		.tower_3_drawn(tower_3_drawn)
	);

	LASERS L1(
		  .clk(clk),
        .resetn(resetn && (stage_1_in_progress | stage_2_in_progress | stage_3_in_progress)), // resets if no stage in progress
		  .laser_start_draw(enable_laser_draw),
		  .background_colour(out_colour),

        //_________Tower Location Inputs_________//
		  .tower_1_coords(tower_1_drawn),
		  .tower_1_drawn(tower_1_drawn),
		  .tower_2_coords(tower_2_drawn),
		  .tower_2_drawn(tower_2_drawn),
		  .tower_3_coords(tower_3_drawn),
		  .tower_3_drawn(tower_3_drawn),

		  //_________Car Location Inputs_________//
		  .car_0_coords(car_0_coords),
		  .car_1_coords(car_1_coords),
		  .car_2_coords(car_2_coords),
		  .car_3_coords(car_3_coords),
		  
		  
		  //_________VGA Outputs_________//
		  .laser_wren(laser_wren),
        .coord(coord_laser),
        .colour(colour_laser),
		  
		  //_________Outputs_________//
		  .laser_draw_done(enable_car_draw),
		  .destroyed_cars(destroyed_cars)
	);
	
	CARS C1(
		//_________________________Inputs_____________________________//
        .clk(clk && (stage_1_in_progress | stage_2_in_progress | stage_3_in_progress)),
        .resetn(resetn),
        
        //________Control Signal__________//
        .stage_1_in_progress(stage_1_in_progress),
        .stage_2_in_progress(stage_2_in_progress),
        .stage_3_in_progress(stage_3_in_progress),
		  
		  //_________Destroyed Cars_________//
		  .destroyed_cars(destroyed_cars),
		  
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
        .game_over_feedback(game_over_feedback),
		  
		  //_________Car Locations_________//
		  .car_0_coords(car_0_coords),
		  .car_1_coords(car_1_coords),
		  .car_2_coords(car_2_coords),
		  .car_3_coords(car_3_coords)
		//__________________________________________________________//	
	);




//___________________________________________________________________//

//__________________Mux to select car or tower vga data______________//
	always @(*) begin
		if(tower_wren == 1'b1) begin
			colour <= colour_tower;
			coordinates <= coord_tower;
		end
		else if(car_wren == 1'b1) begin
			colour <= colour_car;
			coordinates <= coord_car;
		end
		else if(laser_wren == 1'b1) begin
			colour <= colour_laser;
			coordinates <= coord_laser;
		end
		else begin
			colour <= 0;
			coordinates <= 0;
		end
	end

endmodule

// Testing module to count 30fps
module FrameCounter_30(Clock, resetn, Enable30); // tested
	input Clock;
	input resetn;
	output reg Enable30;

	reg [20:0] Q;

	always @(posedge Clock) begin
		if (!resetn) begin
			Q <= 0;
			Enable30 <= 0;
		end

		else if (Q >= 21'b110010110111001101010) begin // 30 fps @ 50MHz
			Enable30 <= 1'b1;
			Q <= 0;
		end

		else begin
			Enable30 <= 1'b0;
			Q <= Q + 1;
		end
	end
endmodule





