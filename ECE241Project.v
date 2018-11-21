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
	
	wire [8:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	
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

//	wire car1en, enable_draw;
		
//	assign WriteEn = (colour != 9'b111111111) && car1en;
	assign writeEn = (colour != 9'b111111111) && (draw_square | draw_tower | erase_square_right | erase_square_down | erase_square_tower);
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.


	
//	FrameCounter_30 FC1(.Clock(Clock_50), .resetn(resetn), .Enable30(enable_draw));
//	
//	assign LEDR[9] = enable_draw;
//	
//	car CAR1(
//		.clk(Clock_50),
//		.resetn(resetn),
//		.initiate(~KEY[0]), // beginning of stage
//		.car_destroyed(1'b0), // input from towers
//		.enable_draw(1'b1), // begin drawing cycle
//		.delay_frames(5'b11110), // 1 second @ 30fps
//
//		.game_over(LEDR[8]),
//      //.car_done(LEDR[2]), // needs to be added
//		.vga_WriteEn(car1en), // enables the WriteEn in vga
//      .vga_coords({x,y}), 
//		.vga_colour(colour),
//		.LEDR(LEDR[7:0])
//      //.car_location // for towers
//   );
	
	/*________________Feedback Wires From Datapath_____________________*/
	wire valid_feeback, square_done, erase_square_done, tower_done;

	/*_________________________Control Wire___________________________*/
	wire move_down, move_right, move_down_wait, move_right_wait, draw_square, draw_tower;
	wire top_left, erase_square_right, erase_square_down, erase_square_tower;


	datapath d0(
	/*________Inputs____________*/
		.clk(CLOCK_50),
    	.resetn(resetn),
    	.top_left(top_left), 
		.draw_square(draw_square), 
		.move_right(move_right), 
		.move_down(move_down), 
		.move_down_wait(move_down_wait), 
		.move_right_wait(move_right_wait),
		.draw_tower(draw_tower),
		.erase_square_right(erase_square_right),
		.erase_square_down(erase_square_down),
		.erase_square_tower(erase_square_tower),

  	/*__________Outputs____________*/	
		.valid(valid_feeback),
		.colour(colour),
		.coordinates({x, y}),
		.square_done(square_done),
		.erase_square_done(erase_square_done),
		.tower_done(tower_done)
	);

	control c0(
		/*__________Inputs______________*/
		.clk(CLOCK_50),
		.resetn(resetn),
		.go_down(~KEY[0]),
		.go_right(~KEY[1]),
		.go_draw(~KEY[2]),
		.valid(valid_feeback),
		.square_done(square_done),
		.erase_square_done(erase_square_done),
		.tower_done(tower_done),

		/*__________Outputs____________*/
		.move_down(move_down),
		.move_right(move_right),
		.move_down_wait(move_down_wait),
		.move_right_wait(move_right_wait),
		.draw_square(draw_square),
		.draw_tower(draw_tower),
		.top_left(top_left),
		.erase_square_right(erase_square_right),
		.erase_square_down(erase_square_down),
		.erase_square_tower(erase_square_tower)
	);
endmodule


// Testing module to count 30fps
module FrameCounter_30(Clock, resetn, Enable30);
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
