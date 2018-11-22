module ECE241Project(
	input [3:0]KEY,
	input CLOCK_50,
	output [9:0]LEDR,
	output			VGA_CLK,   				//	VGA Clock
	output			VGA_HS,					//	VGA H_SYNC
	output			VGA_VS,					//	VGA V_SYNC
	output			VGA_BLANK_N,				//	VGA BLANK
	output			VGA_SYNC_N,				//	VGA SYNC
	output	[9:0]	VGA_R,   				//	VGA Red[9:0]
	output	[9:0]	VGA_G,	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B   				//	VGA Blue[9:0]
);
	
	wire resetn;
	assign resetn = KEY[3];
	
	reg [8:0] colour;
	reg [7:0] x;
	reg [6:0] y;
	
	wire writeEn;
	
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
			
		/* Signals for the DAC to drive the monitor. */	
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
		defparam VGA.BACKGROUND_IMAGE = "defense_map_with_turn.mif";

	wire [3:0]car_writeEn;
	wire [3:0]enable_car_draw;
	wire [3:0]game_over;
	wire [8:0]colour0, colour1, colour2, colour3;
	wire [14:0]coords0, coords1, coords2, coords3;
		
	assign writeEn = (colour != 9'b111111111) && (|car_writeEn);
//	assign writeEn = (colour != 9'b111111111) && (draw_square | draw_tower | erase_square_right | erase_square_down | erase_square_tower);
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.

	assign LEDR[3:0] = car_writeEn;
	assign LEDR[7:4] = game_over;
	assign LEDR[9:8] = enable_car_draw[1:0];
	
	FrameCounter_30 FC1(.Clock(CLOCK_50), .resetn(resetn), .Enable30(enable_car_draw[0]));
	
	
	car CAR0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.initiate(~KEY[0]), // beginning of stage
		.car_destroyed(1'b0 | (game_over[0] == 1'b1)), // input from towers
		.enable_draw(enable_car_draw[0]), // begin drawing cycle
		.delay_frames(8'b0), // 1 second @ 30fps

		.game_over(game_over[0]),
      .car_done(enable_car_draw[1]), // needs to be used
		.vga_WriteEn(car_writeEn[0]), // enables the WriteEn in vga
      .vga_coords(coords0), 
		.vga_colour(colour0),
      //.car_location // for towers
   );
	
	car CAR1(
		.clk(CLOCK_50),
		.resetn(resetn),
		.initiate(~KEY[0]), // beginning of stage
		.car_destroyed(1'b0 | (game_over[1] == 1'b1)), // input from towers
		.enable_draw(enable_car_draw[1]), // begin drawing cycle
		.delay_frames(8'b00011110), // 1 second @ 30fps

		.game_over(game_over[1]),
      .car_done(enable_car_draw[2]), // needs to be used
		.vga_WriteEn(car_writeEn[1]), // enables the WriteEn in vga
      .vga_coords(coords1), 
		.vga_colour(colour1),
      //.car_location // for towers
   );
	
	car CAR2(
		.clk(CLOCK_50),
		.resetn(resetn),
		.initiate(~KEY[0]), // beginning of stage
		.car_destroyed(1'b0 | (game_over[2] == 1'b1)), // input from towers
		.enable_draw(enable_car_draw[2]), // begin drawing cycle
		.delay_frames(8'b01000000), // 128 frames @ 30fps

		.game_over(game_over[2]),
      .car_done(enable_car_draw[3]), // needs to be used
		.vga_WriteEn(car_writeEn[2]), // enables the WriteEn in vga
      .vga_coords(coords2), 
		.vga_colour(colour2),
      //.car_location // for towers
   );
	
	car CAR3(
		.clk(CLOCK_50),
		.resetn(resetn),
		.initiate(~KEY[0]), // beginning of stage
		.car_destroyed(1'b0 | (game_over[3] == 1'b1)), // input from towers
		.enable_draw(enable_car_draw[3]), // begin drawing cycle
		.delay_frames(8'b10000000), // 256 frames @ 30fps

		.game_over(game_over[3]),
      //.car_done(enable_car_draw[1]), // needs to be used
		.vga_WriteEn(car_writeEn[3]), // enables the WriteEn in vga
      .vga_coords(coords3), 
		.vga_colour(colour3),
      //.car_location // for towers
   );
	
	
	/*________________Mux for colours and coords from cars to VGA_____________*/
	always @(*) begin
		if(car_writeEn[0] == 1'b1) begin
			colour = colour0;
			{x,y} = coords0;
		end
		else if(car_writeEn[1] == 1'b1) begin
			colour = colour1;
			{x,y} = coords1;
		end
		else if(car_writeEn[2] == 1'b1) begin
			colour = colour2;
			{x,y} = coords2;
		end
		else if(car_writeEn[3] == 1'b1) begin
			colour = colour3;
			{x,y} = coords3;
		end
		else begin
			colour = 0;
			{x,y} = 0;
		end
	end
	
//	/*________________Feedback Wires From Datapath_____________________*/
//	wire valid_feeback, square_done, erase_square_done, tower_done;
//
//	/*_________________________Control Wire___________________________*/
//	wire move_down, move_right, move_down_wait, move_right_wait, draw_square, draw_tower;
//	wire top_left, erase_square_right, erase_square_down, erase_square_tower;
//
//
//	datapath d0(
//	/*________Inputs____________*/
//		.clk(CLOCK_50),
//    	.resetn(resetn),
//    	.top_left(top_left), 
//		.draw_square(draw_square), 
//		.move_right(move_right), 
//		.move_down(move_down), 
//		.move_down_wait(move_down_wait), 
//		.move_right_wait(move_right_wait),
//		.draw_tower(draw_tower),
//		.erase_square_right(erase_square_right),
//		.erase_square_down(erase_square_down),
//		.erase_square_tower(erase_square_tower),
//
//  	/*__________Outputs____________*/	
//		.valid(valid_feeback),
//		.colour(colour),
//		.coordinates({x, y}),
//		.square_done(square_done),
//		.erase_square_done(erase_square_done),
//		.tower_done(tower_done)
//	);
//
//	control c0(
//		/*__________Inputs______________*/
//		.clk(CLOCK_50),
//		.resetn(resetn),
//		.go_down(~KEY[0]),
//		.go_right(~KEY[1]),
//		.go_draw(~KEY[2]),
//		.valid(valid_feeback),
//		.square_done(square_done),
//		.erase_square_done(erase_square_done),
//		.tower_done(tower_done),
//
//		/*__________Outputs____________*/
//		.move_down(move_down),
//		.move_right(move_right),
//		.move_down_wait(move_down_wait),
//		.move_right_wait(move_right_wait),
//		.draw_square(draw_square),
//		.draw_tower(draw_tower),
//		.top_left(top_left),
//		.erase_square_right(erase_square_right),
//		.erase_square_down(erase_square_down),
//		.erase_square_tower(erase_square_tower)
//	);
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
