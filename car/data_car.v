module datapath_car(
   input clk,
   input resetn,
	input enable_draw,
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
	output reg [14:0] coordinates, // coordinates sent to VGA
	output reg [7:0]Counter_X, // Location (top left of car) on map, not pixel coordinates sent vga
	output reg [6:0]Counter_Y, // Location (top left of car) on map, not pixel coordinates sent vga

	//________Control Feedback__________//
	output reg initial_delay_done,
	output reg draw_done,
	output reg erase_done
	);
	 
	/*___________________Flags____________________*/
	wire delay_done_wire;
	 
	/*___________Memory Accessing Wires___________*/
	wire [8:0] colour_car;
	wire draw_done_wire;
	wire [14:0]coord_draw_car; // output from draw_tower module
	

	wire [8:0] colour_erase_car;
	wire erase_done_wire;
	wire [14:0]coord_erase_car;
	
	
	
	
	/*___________Counter enabled during delay state_______*/
	DelayCar d1(
						.Clock(clk),
						.resetn(resetn),
						.delay_length(delay_frames),
						.Enable(delay),
						.delay_done(delay_done_wire));
	
	draw_car c1(
			.clk(clk),
			.resetn(resetn),
			.enable(draw_car),
			.COUNTER_X(Counter_X),
			.COUNTER_Y(Counter_Y),
			.colour(colour_car),
			.draw_done(draw_done_wire),
			.x(coord_draw_car[14:7]),
			.y(coord_draw_car[6:0])
			);
			
	erase_car_background e1(
			.clk(clk),
			.resetn(resetn),
			.enable(erase_car),
			.COUNTER_X_INPUT(Counter_X),
			.COUNTER_Y_INPUT(Counter_Y),
			.colour(colour_erase_car),
			.erase_car_done(erase_done_wire),
			.x(coord_erase_car[14:7]),
			.y(coord_erase_car[6:0])
			);
	 
	 always @ (posedge clk) begin
		if (!resetn) begin
			Counter_X <= 0;
			Counter_Y <= 6'b111100; //60

			initial_delay_done <= 0;
			draw_done <= 0;
			erase_done <= 0;
			game_over <= 0;
			
			coordinates <= {9'b0, 6'b111100}; //{0, 60}
		end
		else if (wait_start) begin
			Counter_X <= 0;
			Counter_Y <= 6'b111100;
			game_over <= 0;
			
			initial_delay_done <= 0;
			draw_done <= 0;
			erase_done <= 0;

			coordinates <= {9'b0, 6'b111100};
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
		end//Separating right / down case is for state machine. Actual deletion is the same functionality
		else if(erase_car) begin 	
			//Erase current cell's car
			coordinates <= coord_erase_car;
			colour <= colour_erase_car;
			erase_done <= erase_done_wire;
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
			coordinates <= coord_draw_car;
			colour <= colour_car;
			draw_done <= draw_done_wire;
		end
		else if(destroyed_state) begin
			Counter_X <= 0;
			Counter_Y <= 0;
			draw_done <= enable_draw;
		end
	end
endmodule

// Module to count initial delay
module DelayCar(Clock, resetn, delay_length, Enable, delay_done);
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
