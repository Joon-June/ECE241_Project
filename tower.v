module tower(
		input clk,
		input resetn,
		input go_down,
		input go_right,
		input go_draw,


		output vga_WriteEn, // erase_car | draw_car
      output [14:0] vga_coords, 
		output [8:0] vga_colour
   );
	 
	/*________________Feedback Wires From Datapath_____________________*/
	wire valid_feeback, square_done, erase_square_done, tower_done;

	/*_________________________Control Wire___________________________*/
	wire move_down, move_right, move_down_wait, move_right_wait, draw_square, draw_tower;
	wire top_left, erase_square_right, erase_square_down, erase_square_tower;

	assign vga_WriteEn = draw_square | draw_tower | erase_square_right | erase_square_down | erase_square_tower;
	
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

  	/*__________Outputs____________*/	
		.valid(valid_feeback),
		.colour(vga_colour),
		.coordinates(vga_coords),
		.square_done(square_done),
		.erase_square_done(erase_square_done),
		.tower_done(tower_done)
	);

	control c0(
		/*__________Inputs______________*/
		.clk(clk),
		.resetn(resetn),
		.go_down(go_down),
		.go_right(go_right),
		.go_draw(go_draw),
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
