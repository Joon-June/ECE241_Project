module LASERS(
		  input clk,
        input resetn,
		  input laser_start_draw,
		  input [8:0]background_colour,

        //_________Tower Location Inputs_________//
		  input [14:0]tower_1_coords,
		  input tower_1_drawn,
		  input [14:0]tower_2_coords,
		  input tower_2_drawn,
		  input [14:0]tower_3_coords,
		  input tower_3_drawn,

		  //_________Car Location Inputs_________//
		  input [14:0]car_0_coords,
		  input [14:0]car_1_coords,
		  input [14:0]car_2_coords,
		  input [14:0]car_3_coords,
		  
		  
		  //_________VGA Outputs_________//
		  output laser_wren,
        output reg [14:0]coord,
        output reg [8:0]colour,
		  
		  //_________Outputs_________//
		  output laser_draw_done,
		  output [3:0]destroyed_cars,
		  output [14:0] mem_add_laser
);	

//___________________Wires & Registers_______________________//
	wire [2:0]laser_writeEn; //Goes into VGA input
	wire [2:0]enable_laser_draw;
	
	wire [8:0] colour_laser_1, colour_laser_2, colour_laser_3; //Output colour from each laser
	wire [14:0] coord_laser_1, coord_laser_2, coord_laser_3; //Output coordinate from each laser
	wire [3:0] destroyed_cars_1, destroyed_cars_2, destroyed_cars_3;

	assign enable_laser_draw[0] = laser_start_draw;
	assign laser_wren = (|laser_writeEn);
	
	// consolidate list of destroyed cars
	assign destroyed_cars[0] = 1'b1;//((destroyed_cars_1[0] == 1'b1) | (destroyed_cars_2[0] == 1'b1) | (destroyed_cars_3[0] == 1'b1));
	assign destroyed_cars[1] = ((destroyed_cars_1[1] == 1'b1) | (destroyed_cars_2[1] == 1'b1) | (destroyed_cars_3[1] == 1'b1));
	assign destroyed_cars[2] = ((destroyed_cars_1[2] == 1'b1) | (destroyed_cars_2[2] == 1'b1) | (destroyed_cars_3[2] == 1'b1));
	assign destroyed_cars[3] = ((destroyed_cars_1[3] == 1'b1) | (destroyed_cars_2[3] == 1'b1) | (destroyed_cars_3[3] == 1'b1));


//_____________________________Lasers_______________________________//
    laser L1(
		.clk(clk),
		.resetn(resetn),
		.initiate(tower_1_drawn), // beginning of stage
		.enable_draw(enable_laser_draw[0]), // begin drawing cycle
		.tower_x(tower_1_coords[14:7]),
		.tower_y(tower_1_coords[6:0]),
		.background_colour(background_colour),
		.car0_coords(car_0_coords),
		.car1_coords(car_1_coords),
		.car2_coords(car_2_coords),
		.car3_coords(car_3_coords),

      .laser_done(enable_laser_draw[1]),
		.vga_WriteEn(laser_writeEn[0]), // draw_laser | erase
      .vga_coords(coord_laser_1), 
		.vga_colour(colour_laser_1),
		.destroyed_cars(destroyed_cars_1)
   );
	
	laser L2(
		.clk(clk),
		.resetn(resetn),
		.initiate(tower_2_drawn), // beginning of stage
		.enable_draw(enable_laser_draw[1]), // begin drawing cycle
		.tower_x(tower_2_coords[14:7]),
		.tower_y(tower_2_coords[6:0]),
		.background_colour(background_colour),
		.car0_coords(car_0_coords),
		.car1_coords(car_1_coords),
		.car2_coords(car_2_coords),
		.car3_coords(car_3_coords),

      .laser_done(enable_laser_draw[2]),
		.vga_WriteEn(laser_writeEn[1]), // draw_laser | erase
      .vga_coords(coord_laser_2), 
		.vga_colour(colour_laser_2),
		.destroyed_cars(destroyed_cars_2)
   );
	
	laser L3(
		.clk(clk),
		.resetn(resetn),
		.initiate(tower_3_drawn), // beginning of stage
		.enable_draw(enable_laser_draw[2]), // begin drawing cycle
		.tower_x(tower_3_coords[14:7]),
		.tower_y(tower_3_coords[6:0]),
		.background_colour(background_colour),
		.car0_coords(car_0_coords),
		.car1_coords(car_1_coords),
		.car2_coords(car_2_coords),
		.car3_coords(car_3_coords),

      .laser_done(laser_draw_done),
		.vga_WriteEn(laser_writeEn[2]), // draw_laser | erase
      .vga_coords(coord_laser_3), 
		.vga_colour(colour_laser_3),
		.destroyed_cars(destroyed_cars_3)
   );

	//Memory Address Translator for 160x130 .mif files to generate address for background
    memory_address_translator_160x120 v1(
									  .x(coord[14:7]), 
									  .y(coord[6:0]), 
									  .mem_address(mem_add_laser)
									  ); 
	
/*________________Mux for colours and coords from lasers to VGA_____________*/
	always @(*) begin
		if(laser_writeEn[0] == 1'b1) begin
			colour = colour_laser_1;
			coord = coord_laser_1;
		end
		else if(laser_writeEn[1] == 1'b1) begin
			colour = colour_laser_2;
			coord = coord_laser_2;
		end
		else if(laser_writeEn[2] == 1'b1) begin
			colour = colour_laser_3;
			coord = coord_laser_3;
		end
		else begin
			colour = 0;
			coord = 0;
		end
	end
endmodule
