module tower(
		//_____________Inputs________________//
		input clk,
		input resetn,
		input go_down,
		input go_right,
		input go_draw,
		input enable_draw,

		//____________Outputs________________//
		output vga_WriteEn, // erase_car | draw_car
      	output [14:0] vga_coords, 
		output [8:0] vga_colour,
		output tower_done_out
   );
	
	//______________________Wires & Registers______________________________//
	
	/*________________Feedback Wires From Datapath_____________________*/
	wire valid_feeback;
	wire square_done;
	wire erase_square_done;
	wire tower_done_wire;

	/*_________________________Control Wire___________________________*/
	wire move_down;
	wire move_right;
	wire move_down_wait;
	wire move_right_wait;
	wire draw_square;
	wire draw_tower;
	wire top_left;
	wire erase_square_right;
	wire erase_square_down;
	wire erase_square_tower;

	assign vga_WriteEn = draw_square | draw_tower | erase_square_right | erase_square_down | erase_square_tower;
	assign tower_done_out = tower_done_wire;

	//____________________________________________________________________//

	datapath d0(
	/*________Inputs____________*/
		.clk(clk),
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

  	/*__________Control Feedback Output____________*/	
		.valid(valid_feeback),
		.square_done(square_done),
		.erase_square_done(erase_square_done),

	//________________Output__________________//
		.colour(vga_colour),
		.coordinates(vga_coords),
		.tower_done(tower_done_wire)
	);

	control_towerplacer c0(
		/*__________Inputs______________*/
		.clk(clk),
		.resetn(resetn),
		.go_down(go_down),
		.go_right(go_right),
		.go_draw(go_draw),
		.valid(valid_feeback),
		.square_done(square_done),
		.erase_square_done(erase_square_done),
		.tower_done(tower_done_wire),
		.enable_draw(enable_draw),

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
