module CARS(
//_________________________Inputs_____________________________//
        input clk,
        input resetn,
		  input start_car_draw,
        
        //________Control Signal__________//
        input stage_1_in_progress,
        input stage_2_in_progress,
        input stage_3_in_progress,
		  input [3:0] destroyed_cars,
//___________________________________________________________//


//_______________________Outputs_____________________________//
        output car_wren,

        output stage_1_car_done, //It means all cars are destroyed
        output stage_2_car_done,
        output stage_3_car_done,

        //_________VGA Outputs_________//
        output reg [14:0]coord,
        output reg [8:0]colour,

        //_________Terminal States_________//
        output game_over_feedback,
		  
		  //_________Car Locations_________//
		  output [14:0]car_0_coords,
		  output [14:0]car_1_coords,
		  output [14:0]car_2_coords,
		  output [14:0]car_3_coords,
		  
		  output car_done_drawing
		  
//__________________________________________________________//
);

//___________________Wires & Registers_______________________//
	wire [3:0]car_writeEn; //Goes into VGA input
	wire [3:0]enable_car_draw;
	wire [3:0]game_over; //Output feedback signal
	wire [8:0]colour_car_0, colour_car_1, colour_car_2, colour_car_3; //Output colour from each car
	wire [14:0]coord_car_0, coord_car_1, coord_car_2, coord_car_3; //Output coordinate from each car

    assign stage_1_car_done = ((destroyed_cars[0] == 1'b1) && (destroyed_cars[1] == 1'b1) && (destroyed_cars[2] == 1'b1) && (destroyed_cars[3] == 1'b1)); // Needs to be updated once lasers
    assign stage_2_car_done = ((destroyed_cars[0] == 1'b1) && (destroyed_cars[1] == 1'b1) && (destroyed_cars[2] == 1'b1) && (destroyed_cars[3] == 1'b1)); // Needs to be updated once lasers
    assign stage_3_car_done = ((destroyed_cars[0] == 1'b1) && (destroyed_cars[1] == 1'b1) && (destroyed_cars[2] == 1'b1) && (destroyed_cars[3] == 1'b1)); // Needs to be updated once lasers

    assign car_wren = (|car_writeEn); //Unary Opeartor
    assign game_over_feedback = (|game_over); //Unary Operator
	 
	 assign enable_car_draw[0] = start_car_draw;
//___________________________________________________________//

//_____________________________Cars_______________________________//
	//Stage 1
    car CAR0(
		//___________Inputs_____________//
        .clk(clk),
		.resetn(resetn),
		.initiate(stage_1_in_progress || stage_2_in_progress || stage_3_in_progress), // beginning of stage
		.car_destroyed(destroyed_cars[0]), // input from lasers
		.enable_draw(enable_car_draw[0]), // begin drawing cycle
		.delay_frames(8'b0), // 1 second @ 30fps

        //___________Outputs_____________//
		.game_over(game_over[0]),
      .car_done(enable_car_draw[1]),
		.vga_WriteEn(car_writeEn[0]), // enables the WriteEn in vga
      .vga_coords(coord_car_0), 
		.vga_colour(colour_car_0),
      .car_location(car_0_coords)
   );
	
	car CAR1(
        //___________Inputs_____________//
		.clk(clk),
		.resetn(resetn),
		.initiate(stage_1_in_progress || stage_2_in_progress || stage_3_in_progress), // beginning of stage
		.car_destroyed(destroyed_cars[1]), // input from lasers
		.enable_draw(enable_car_draw[1]), // begin drawing cycle
		.delay_frames(8'b00011110), // 1 second @ 30fps

        //___________Outputs_____________//
		.game_over(game_over[1]),
      .car_done(enable_car_draw[2]),
		.vga_WriteEn(car_writeEn[1]), // enables the WriteEn in vga
      .vga_coords(coord_car_1), 
		.vga_colour(colour_car_1),
      .car_location(car_1_coords)
   );
	
	car CAR2(
        //___________Inputs_____________//
		.clk(clk),
		.resetn(resetn),
		.initiate(stage_1_in_progress || stage_2_in_progress || stage_3_in_progress), // beginning of stage
		.car_destroyed(destroyed_cars[2]), // input from lasers
		.enable_draw(enable_car_draw[2]), // begin drawing cycle
		.delay_frames(8'b01000000), // 128 frames @ 30fps

        //___________Outputs_____________//
		.game_over(game_over[2]),
      .car_done(enable_car_draw[3]),
		.vga_WriteEn(car_writeEn[2]), // enables the WriteEn in vga
      .vga_coords(coord_car_2), 
		.vga_colour(colour_car_2),
      .car_location(car_2_coords)
   );
	
	car CAR3(
        //___________Inputs_____________//
		.clk(clk),
		.resetn(resetn),
		.initiate(stage_1_in_progress || stage_2_in_progress || stage_3_in_progress), // beginning of stage
		.car_destroyed(1'b0 | (game_over[3] == 1'b1)), // .car_destroyed(destroyed_cars[3]), // input from towers
		.enable_draw(enable_car_draw[3]), // begin drawing cycle
		.delay_frames(8'b10000000), // 256 frames @ 30fps

        //___________Outputs_____________//
		.game_over(game_over[3]),
      .car_done(car_done_drawing),
		.vga_WriteEn(car_writeEn[3]), // enables the WriteEn in vga
      .vga_coords(coord_car_3), 
		.vga_colour(colour_car_3),
      .car_location(car_3_coords)
   );

	
	
/*________________Mux for colours and coords from cars to VGA_____________*/
	always @(*) begin
		if(car_writeEn[0] == 1'b1) begin
			colour = colour_car_0;
			coord = coord_car_0;
		end
		else if(car_writeEn[1] == 1'b1) begin
			colour = colour_car_1;
			coord = coord_car_1;
		end
		else if(car_writeEn[2] == 1'b1) begin
			colour = colour_car_2;
			coord = coord_car_2;
		end
		else if(car_writeEn[3] == 1'b1) begin
			colour = colour_car_3;
			coord = coord_car_3;
		end
		else begin
			colour = 0;
			coord = 0;
		end
	end
endmodule