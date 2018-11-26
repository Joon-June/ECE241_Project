module laser(
		input clk,
		input resetn,
		input initiate, // beginning of stage
		input enable_draw, // begin drawing cycle
		input [7:0]tower_x,
		input [6:0]tower_y,
		input [8:0]background_colour,
		input [14:0]car0_coords,
		input [14:0]car1_coords,
		input [14:0]car2_coords,
		input [14:0]car3_coords,

      output laser_done,
		output vga_WriteEn, // draw_laser | erase
      output [14:0] vga_coords, 
		output [8:0] vga_colour,
		output [3:0] destroyed_cars
   );
	 
	wire wait_draw, draw_laser, delay, erase, disabled;
	wire car_in_range, draw_done, drawn, delay_done, erase_done;
	
	assign vga_WriteEn = draw_laser | erase;
	
	assign laser_done = draw_done | erase_done | (enable_draw && (car_in_range == 1'b0) && (drawn == 1'b0));

	
	datapath_laser d0(
		.clk(clk),
		.resetn(resetn),
		 //____Control Signals___//
		.wait_draw(wait_draw), 
		.draw_laser(draw_laser), 
		.delay(delay), 
		.erase(erase), 
		.disabled(disabled),
		//________Control Feedback__________//
		.car_in_range(car_in_range),
		.draw_done(draw_done),
		.drawn(drawn),
		.delay_done(delay_done),
		.erase_done(erase_done),
		// ____ Data In ______ //
		.pos_x(tower_x), // location of corresponding tower
		.pos_y(tower_y),
		.back_colour(background_colour), // Colour from common background
		.car0_coords(car0_coords),
		.car1_coords(car1_coords),
		.car2_coords(car2_coords),
		.car3_coords(car3_coords),
		// ____ Data Out ______ //
		.mem_add(), // To get colour from common background
		.vga_coords(vga_coords),
		.vga_colour(vga_colour),
		.destroyed_cars(destroyed_cars)
	);
	
	control_laser c0(
		.clk(clk),
		.resetn(resetn),
		.initiate(initiate), // corresponding tower is placed
		.enable_draw(enable_draw), // begin drawing cycle
		//_____Control Feedback ___//
		.car_in_range(car_in_range),
		.draw_done(draw_done),
		.drawn(drawn),
		.erase_done(erase_done),
		.delay_done(delay_done),

		//_____Control Signals ___//
		.disabled(disabled), 
      .wait_draw(wait_draw), 
      .draw_laser(draw_laser), 
      .delay(delay), 
      .erase(erase)
   );

endmodule
