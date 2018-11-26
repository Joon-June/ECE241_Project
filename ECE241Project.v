module ECE241Project(
	input [3:0]KEY,
	input [9:0]SW,
	input CLOCK_50,
	output			VGA_CLK,   				//	VGA Clock
	output			VGA_HS,					//	VGA H_SYNC
	output			VGA_VS,					//	VGA V_SYNC
	output			VGA_BLANK_N,				//	VGA BLANK
	output			VGA_SYNC_N,				//	VGA SYNC
	output	[9:0]	VGA_R,   				//	VGA Red[9:0]
	output	[9:0]	VGA_G,	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B   				//	VGA Blue[9:0]
);
//_______________________Wires & Registers____________________________//
	
	//_________reset_________//
	wire resetn;
	assign resetn = ~SW[0];
	
	//_________User Inputs_______//
	wire go_down;
	wire go_right;
	wire go_draw;
	wire start;
	assign go_down = ~KEY[0];
	assign go_right = ~KEY[1];
	assign go_draw = ~KEY[2];
	assign start = ~KEY[3];
	
	//_______VGA Inputs______//
	reg [7:0]x;
	reg [6:0]y;
	reg [8:0]colour;
	reg writeEn;
	
	wire [8:0] temp_colour;
	wire [7:0] temp_x;
	wire [6:0] temp_y;
	wire writeEn_from_data;	
	
	always @(posedge CLOCK_50) begin
	  	x <= temp_x;
	  	y <= temp_y;
	  	colour <= temp_colour;

		if(temp_x != 8'b00000000 && temp_colour != 9'b111111111) begin
			writeEn <= writeEn_from_data;
		end
		else begin
			writeEn <= 1'b0;
		end

	end
	//______Game Flow Related Wires______//
	//Initial Setup
	wire wait_start;
	wire start_display_done;
	//Control Feebacks
	wire [3:0]stage_1_feedback;
	wire [3:0]stage_2_feedback;
	wire [3:0]stage_3_feedback;
	//Control Output
	wire [3:0]stage_1_control;
	wire [3:0]stage_2_control;
	wire [3:0]stage_3_control;
	//Terminal States
	wire win;
	wire game_over_control;
	wire game_over_feedback;
//____________________________________________________________________//


//_________________________Data Path__________________________________//
	data_game_flow DGF(
		.clk(CLOCK_50),
		.resetn(resetn),
		//__________________________________//
		//____________User Input____________//
		//__________________________________//
		.go_down(go_down),
		.go_right(go_right),
		.go_draw(go_draw),		
		.start(start),
				
		//__________________________________//
		//_______Control Signal Input_______//
		//__________________________________//
		.wait_start(wait_start), 
        //______Stage 1_______//
		.stage_1_begin(stage_1_control[0]),
		.stage_1_draw_tower(stage_1_control[1]),
		.stage_1_in_progress(stage_1_control[2]),
		.stage_1_done(stage_1_control[3]),

		//______Stage 2_______//
		.stage_2_begin(stage_2_control[0]),
		.stage_2_draw_tower(stage_2_control[1]),
		.stage_2_in_progress(stage_2_control[2]),
		.stage_2_done(stage_2_control[3]),

		//______Stage 3_______//
		.stage_3_begin(stage_3_control[0]),
		.stage_3_draw_tower(stage_3_control[1]),
		.stage_3_in_progress(stage_3_control[2]),
		.stage_3_done(stage_3_control[3]),
		
		//Terminal States
		.win(win),
		.game_over(game_over_control),


		//_________________________________//
		//______Control Feedback Output_____//
		//_________________________________//
		.start_display_done(start_display_done),
		
		//_________STAGE 1___________//
		.stage_1_begin_done(stage_1_feedback[0]),
		.stage_1_tower_done(stage_1_feedback[1]),
		.stage_1_car_done(stage_1_feedback[2]),
		.stage_1_end_display_done(stage_1_feedback[3]),
		
		//_________STAGE 2___________//
		.stage_2_begin_done(stage_2_feedback[0]),
		.stage_2_tower_done(stage_2_feedback[1]),
		.stage_2_car_done(stage_2_feedback[2]),
		.stage_2_end_display_done(stage_2_feedback[3]),
		
		//_________STAGE 3___________//
		.stage_3_begin_done(stage_3_feedback[0]),
		.stage_3_tower_done(stage_3_feedback[1]),
		.stage_3_car_done(stage_3_feedback[2]),
		.stage_3_end_display_done(stage_3_feedback[3]),

		//Terminal States
		.game_over_feedback(game_over_feedback),

		
		//________VGA Inputs_________//
		.colour(temp_colour),
		.coordinates({temp_x, temp_y}),
		.VGA_write_enable(writeEn_from_data)
	);
//____________________________________________________________________//

	
	
	
	
//____________________Finite State Machine____________________________//

	control_game_flow CGF(
		.clk(CLOCK_50),
		.resetn(resetn),
		//_________________________________//
		//______Control Feedback Input_____//
		//_________________________________//
		.start_display_done(start_display_done),
		
		//_________STAGE 1___________//
		.stage_1_begin_done(stage_1_feedback[0]),
		.stage_1_tower_done(stage_1_feedback[1]),
		.stage_1_car_done(stage_1_feedback[2]),
		.stage_1_end_display_done(stage_1_feedback[3]),
		
		//_________STAGE 2___________//
		.stage_2_begin_done(stage_2_feedback[0]),
		.stage_2_tower_done(stage_2_feedback[1]),
		.stage_2_car_done(stage_2_feedback[2]),
		.stage_2_end_display_done(stage_2_feedback[3]),
		
		//_________STAGE 3___________//
		.stage_3_begin_done(stage_3_feedback[0]),
		.stage_3_tower_done(stage_3_feedback[1]),
		.stage_3_car_done(stage_3_feedback[2]),
		.stage_3_end_display_done(stage_3_feedback[3]),

		//Terminal States
		.game_over_in(game_over_feedback),

		
		//__________________________________//
		//______Control Signal Output_______//
		//__________________________________//
		.wait_start(wait_start), 
        //______Stage 1_______//
		.stage_1_begin(stage_1_control[0]),
		.stage_1_draw_tower(stage_1_control[1]),
		.stage_1_in_progress(stage_1_control[2]),
		.stage_1_done(stage_1_control[3]),

		//______Stage 2_______//
		.stage_2_begin(stage_2_control[0]),
		.stage_2_draw_tower(stage_2_control[1]),
		.stage_2_in_progress(stage_2_control[2]),
		.stage_2_done(stage_2_control[3]),

		//______Stage 3_______//
		.stage_3_begin(stage_3_control[0]),
		.stage_3_draw_tower(stage_3_control[1]),
		.stage_3_in_progress(stage_3_control[2]),
		.stage_3_done(stage_3_control[3]),

		.win(win),
		.game_over_out(game_over_control)
	
	);
//____________________________________________________________________//
	

	
//____________________________VGA Module______________________________//

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
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

//____________________________________________________________________//
endmodule


