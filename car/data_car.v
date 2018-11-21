module datapath_car(
   input clk,
   input resetn,
	 //____Control Signals___//
   input wait_start, 
   input delay, 
	input draw_car, 
	input draw_wait, 
   input erase_car, 
	input increment,
	input destroyed_state,
	// ____ Data In ______ //
	input [7:0]delay_frames, // the number of frames that the car should wait before entering (30 frames per second)
	//___________________//
	output reg game_over,
	output reg [8:0] colour,
	output reg [14:0] coordinates,
	output reg [7:0]Counter_X, // Location (top left of car) on map, not pixel coordinates sent vga
	output reg [6:0]Counter_Y, // Location (top left of car) on map, not pixel coordinates sent vga

	//________Control Feedback__________//
	output reg initial_delay_done,
	output reg draw_done,
	output reg erase_done
	);
	 
	reg [1:0] two_cycle_delay;

	/*____________Map Related Registers___________*/
	reg [14:0] memory_address_map; //need 15 bits to access map.mif (19200 addresses - 160 x 120)
	
	/*___________Car Related Registers___________*/
	reg [7:0] counter_memory_x_car; //counter to track pixel location while drawing/erasing
	reg [6:0] counter_memory_y_car; //counter to track pixel location while drawing/erasing
	reg [8:0] memory_address_car; //need 8 bit to access car.mif (400 addresses - 20 x 20)
	 
	  /*___________Register for Game Grid___________*/
	reg [7:0] game_grid [5:0];
	initial begin //Represents the path of the game grid
		game_grid[0] = 8'b0;
		game_grid[1] = 8'b00111100;
		game_grid[2] = 8'b00100100;
		game_grid[3] = 8'b11100111;
		game_grid[4] = 8'b0;
		game_grid[5] = 8'b0;
	end
	 
	/*___________________Flags____________________*/
	//  reg down_wait = 1'b0;
	 
	/*___________Memory Accessing Wires___________*/
	wire [8:0] colour_map;
	wire [8:0] colour_car;
	wire draw_done_wire;
	wire [14:0]coord; // output from draw_tower module
	wire delay_done_wire;
	/*___________Counter enabled during delay state_______*/
	DelayCounter d1(
						.Clock(clk),
						.resetn(resetn),
						.delay_length(delay_frames),
						.Enable(delay),
						.delay_done(delay_done_wire));

	ram19200x9_map_background map_background(
						.address(memory_address_map),
						.clock(clk),
						.data(9'b0),
						.wren(1'b0),
						.q(colour_map)
						);
	
	draw_car c1(
			.clk(clk && draw_car),
			.resetn(resetn),
			.COUNTER_X(Counter_X),
			.COUNTER_Y(Counter_Y),
			.colour(colour_car),
			.draw_done(draw_done_wire),
			.x(coord[14:7]),
			.y(coord[6:0])
			);
	 
	 always @ (posedge clk) begin
		if (!resetn) begin
			Counter_X <= 0;
			Counter_Y <= 6'b111100;
			memory_address_map <= 0;

			counter_memory_x_car <= 0;
			counter_memory_y_car <= 0;
			memory_address_car <= 0;

			initial_delay_done <= 0;
			draw_done <= 0;
			erase_done <= 0;
			game_over <= 0;
			
			coordinates <= {9'b0, 6'b111100};

			two_cycle_delay = 2'b00;
		end
		else if (wait_start) begin
			Counter_X <= 0;
			Counter_Y <= 6'b111100;
			memory_address_map <= 0;

			counter_memory_x_car <= 0;
			counter_memory_y_car <= 0;
			memory_address_car <= 0;
			game_over <= 0;
			
			initial_delay_done <= 0;
			draw_done <= 0;
			erase_done <= 0;

			coordinates <= {9'b0, 6'b111100};

			two_cycle_delay = 2'b00;
		end
		else if (delay) begin
			initial_delay_done <= delay_done_wire;
		end
		else if (draw_wait) begin
			//Reset the flag for next use
			draw_done <= 0;
			erase_done <= 0;
			// Check if car has reached the end of the game (Counter_X >= 140)
			if(Counter_X >= 8'b10001100) begin
				game_over <= 1'b1;
			end
		end
		else if (increment) begin
			//Reset the erase flag for next use
			erase_done <= 0;
			// Increment Counter_X and Counter_Y according to location in path
			if(Counter_Y == 6'b111100 && Counter_X < 6'b101000) begin // Segment 1: Y == 60 && X < 40
				Counter_X <= Counter_X + 1; // Right
				coordinates <= {Counter_X + 1, Counter_Y};
			end
			else if (Counter_Y > 5'b10100 && Counter_X == 6'b101000) begin // Segment 2: Y>20 && X == 40
				Counter_Y <= Counter_Y - 1; // Up
				coordinates <= {Counter_X, Counter_Y - 1};
			end
			else if (Counter_Y == 5'b10100 && Counter_X < 7'b1100100) begin // Segment 3: Y == 20 && X < 100
				Counter_X <= Counter_X + 1; // Right
				coordinates <= {Counter_X + 1, Counter_Y };
			end
			else if (Counter_Y < 6'b111100 && Counter_X == 7'b1100100) begin // Segment 3: Y < 60 && X == 100
				Counter_Y <= Counter_Y + 1; // Down
				coordinates <= {Counter_X, Counter_Y + 1};
			end
			else if (Counter_Y == 6'b111100 && Counter_X < 8'b10100000) begin // Segment 3: Y == 60 && X < 160
				Counter_X <= Counter_X + 1; // Right
				coordinates <= {Counter_X + 1, Counter_Y};
			end
		end
		else if(draw_car) begin
			//Reset the flag for next use
			coordinates <= coord;
			colour <= colour_car;
			draw_done <= draw_done_wire;
		end
		//Separating right / down case is for state machine. Actual deletion is the same functionality
		else if(erase_car) begin 		
				//Reset the flag for next use
				draw_done <= 0;
				//Erase current cell's car
				colour <= colour_map;
				if (two_cycle_delay == 2'b10) begin
					coordinates <= {(Counter_X + counter_memory_x_car), 
									(Counter_Y + counter_memory_y_car)};
									
					memory_address_map <= (Counter_Y * 8'b10100000) + Counter_X + 
												(8'b10100000 * counter_memory_y_car) + counter_memory_x_car;
											
					counter_memory_x_car <= counter_memory_x_car +1;
					if(counter_memory_x_car >= 8'b00010011) begin
						counter_memory_y_car <= counter_memory_y_car +1;
						counter_memory_x_car <= 0;
					end

					//Same as {x, y} >= {19, 19} - i.e. done accessing map memory
					if({counter_memory_x_car, counter_memory_y_car} >= 15'b000100110010011) begin
						erase_done <= 1;
						memory_address_map <= 0;
						counter_memory_x_car <= 0;
						counter_memory_y_car <= 0;
					end
				end
				if(two_cycle_delay >= 2'b10)
					two_cycle_delay <= 2'b00;
				else
					two_cycle_delay <= two_cycle_delay + 1;
			end
	end
endmodule

// Module to count initial delay
module DelayCounter(Clock, resetn, delay_length, Enable, delay_done);
	input Clock;
	input resetn;
	input Enable;
	input [7:0] delay_length;
	output reg delay_done;

	reg [7:0] frame_counter; // related to delay_length (2^8 = 256) times
	reg [20:0] clock_counter;

	always @(posedge Clock) begin
		if (!resetn) begin
			frame_counter <= 0;
			clock_counter <= 0;
			delay_done <= 0;
		end

		else if (clock_counter >= 21'b110010110111001101010) begin // 30 fps @ 50MHz
			if (frame_counter >= delay_length) // delay has passed
				delay_done <= 1'b1;
			else
				frame_counter <= frame_counter + 1;
			clock_counter <= 0;
		end

		else if (Enable && delay_done != 1'b1) begin // do not count if delay has finished
			clock_counter <= clock_counter + 1;
		end
	end
endmodule
