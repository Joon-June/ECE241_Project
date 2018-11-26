module car(
		input clk,
		input resetn,
		input initiate, // beginning of stage
		input car_destroyed, // input from towers
		input enable_draw, // begin drawing cycle
		input [7:0]delay_frames,

		output game_over,
      output car_done,
		output vga_WriteEn, // erase_car | draw_car
      output [14:0] vga_coords, 
		output [8:0] vga_colour,
      output [14:0] car_location // for towers
		
   );
	 
	wire wait_start, delay, draw_car, draw_wait, erase_car, increment, destroyed_state;
	wire initial_delay_done, draw_done, erase_done;
	
	assign vga_WriteEn = draw_car | erase_car;
	
	assign car_done = draw_done;
 
	
	datapath_car d0(
		.clk(clk),
		.resetn(resetn),
		.enable_draw(enable_draw),
		//____Control Signals___//
		.wait_start(wait_start), 
		.delay(delay), 
		.draw_car(draw_car), 
		.draw_wait(draw_wait), 
		.erase_car(erase_car), 
		.increment(increment),
		.destroyed_state(destroyed_state),
		// ____ Data In ______ //
		.delay_frames(delay_frames), // delaying for 
		//___________________//
		.game_over(game_over),
		.colour(vga_colour),
		.coordinates(vga_coords),
		.Counter_X(car_location[14:7]),
		.Counter_Y(car_location[6:0]),

		//________Control Feedback__________//
		.initial_delay_done(initial_delay_done),
		.draw_done(draw_done),
		.erase_done(erase_done)
	);
	
	control_car c0(
		.clk(clk),
		.resetn(resetn),
		.initiate(initiate),
		.car_destroyed(car_destroyed),
		.enable_draw(enable_draw),
		//_____Control Feedback ___//
		.initial_delay_done(initial_delay_done),
		.draw_done(draw_done),
		.erase_done(erase_done),

		.wait_start(wait_start), 
      .delay(delay), 
      .draw_car(draw_car), 
      .draw_wait(draw_wait), 
      .erase_car(erase_car), 
      .increment(increment),
		.destroyed_state(destroyed_state) // signal on when current state is destroyed
   );
endmodule
