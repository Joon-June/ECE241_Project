module datapath_laser(
   input clk,
   input resetn,
	 //____Control Signals___//
   input wait_draw, 
   input draw_laser, 
	input delay, 
	input erase, 
   input disabled,
	//________Control Feedback__________//
	output reg car_in_range,
	output reg draw_done,
	output reg drawn,
	output reg delay_done,
	output reg erase_done,
	// ____ Data In ______ //
	input [7:0]pos_x, // location of corresponding tower
	input [6:0]pos_y,
	input [8:0]back_colour, // Colour from common background
	input [14:0]car0_coords,
	input [14:0]car1_coords,
	input [14:0]car2_coords,
	input [14:0]car3_coords,
	// ____ Data Out ______ //
	output [14:0]mem_add, // To get colour from common background
	output reg [14:0]vga_coords,
	output reg [8:0]vga_colour,
	output reg [3:0]destroyed_cars
);
	 
	/*___________________Counters____________________*/
	
	reg [7:0]counter_x; // for vga
	reg [6:0]counter_y;
	reg [1:0]laser_direction; // 0 - up, 1 - right, 2 -down, 3 - left
	// For car in_range and direction logic
	wire [3:0]cars_in_range; // 0 corresponding to car not being in range, 1 if car is in range
	wire [1:0]car0_laser_direction;
	wire [1:0]car1_laser_direction;
	wire [1:0]car2_laser_direction;
	wire [1:0]car3_laser_direction;
	
	/*___________________Flags____________________*/
	
	wire delay_done_wire;
	
	
	/*___________Counter enabled during delay state_______*/
	DelayLaser d1(
						.Clock(clk),
						.resetn(resetn),
						.Enable(delay),
						.delay_done(delay_done_wire));
	
	/*___________Module for translating coords to mem address for erasing_______*/
	memory_address_translator_160x120 v1(
									  .x(counter_x), 
									  .y(counter_y), 
									  .mem_address(mem_add) //Connection A
									  );
	
	/*___________Module for checking if a car is in range_______*/ 
	CheckCar C0(.resetn(resetn),
					 .car_x(car0_coords[14:7]),
					 .car_y(car0_coords[6:0]),
					 .tower_x(pos_x),
					 .tower_y(pos_y),
					 .car_in_range(cars_in_range[0]),
					 .laser_direction(car0_laser_direction)
					 );
	CheckCar C1(.resetn(resetn),
					 .car_x(car1_coords[14:7]),
					 .car_y(car1_coords[6:0]),
					 .tower_x(pos_x),
					 .tower_y(pos_y),
					 .car_in_range(cars_in_range[1]),
					 .laser_direction(car1_laser_direction)
					 );
	CheckCar C2(.resetn(resetn),
					 .car_x(car2_coords[14:7]),
					 .car_y(car2_coords[6:0]),
					 .tower_x(pos_x),
					 .tower_y(pos_y),
					 .car_in_range(cars_in_range[2]),
					 .laser_direction(car2_laser_direction)
					 );
	CheckCar C3(.resetn(resetn),
					 .car_x(car3_coords[14:7]),
					 .car_y(car3_coords[6:0]),
					 .tower_x(pos_x),
					 .tower_y(pos_y),
					 .car_in_range(cars_in_range[3]),
					 .laser_direction(car3_laser_direction)
					 );
	
	always @ (posedge clk) begin
		if (!resetn) begin
			counter_x <= pos_x;
			counter_y <= pos_y;

			car_in_range <= 0;
			draw_done <= 0;
			drawn <= 0;
			delay_done <= 0;
			erase_done <= 0;
			destroyed_cars <= 0;
			
			vga_coords <= {(pos_x + 4'b1010), (pos_y + 4'b1010)};
			laser_direction <= 0;
		end
		else if (disabled) begin
			counter_x <= pos_x;
			counter_y <= pos_y;

			car_in_range <= 0;
			draw_done <= 0;
			drawn <= 0;
			delay_done <= 0;
			erase_done <= 0;
			destroyed_cars <= 0;
			
			vga_coords <= {(pos_x + 4'b1010), (pos_y + 4'b1010)};
			laser_direction <= 0;
		end
		else if (wait_draw) begin
			// Reset flags
			delay_done <= 0;
			draw_done <= 0;
			counter_x <= pos_x;
			counter_y <= pos_y;
			vga_colour <= 9'b000000111; // Set colour for draw_laser to avoid delay
			// Check if car is within range and assign output accordingly
			if(cars_in_range[0] == 1'b1) begin
				car_in_range <= 1'b1;
				laser_direction <= car0_laser_direction;
			end
			else if(cars_in_range[1] == 1'b1) begin
				car_in_range <= 1'b1;
				laser_direction <= car1_laser_direction;
			end
			else if(cars_in_range[2] == 1'b1) begin
				car_in_range <= 1'b1;
				laser_direction <= car2_laser_direction;
			end
			else if(cars_in_range[3] == 1'b1) begin
				car_in_range <= 1'b1;
				laser_direction <= car3_laser_direction;
			end
			else begin
				car_in_range <= 0;
				laser_direction <= 0;
			end
		end
		else if (draw_laser) begin
			// Set flags
			drawn <= 1'b1;
			vga_colour = 9'b000000111; // Blue
			// 
			if((laser_direction == 2'b00) && (counter_y >= (pos_y - 5'b10100))) begin // Up
				counter_y <= counter_y - 1'b1;
			end
			else if((laser_direction == 2'b10) && (counter_y <= (pos_y + 5'b10100))) begin // Down
				counter_y <= counter_y + 1'b1;
			end
			else if((laser_direction == 2'b01) && (counter_x <= (pos_x + 5'b10100))) begin // Right
				counter_x <= counter_x + 1'b1;
			end
			else if((laser_direction == 2'b11) && (counter_x >= (pos_x - 5'b10100))) begin // Left
				counter_x <= counter_x - 1'b1;
			end
			else begin  // Reset counters
				draw_done <= 1'b1;
				counter_x <= pos_x;
				counter_y <= pos_y;
			end
			// Assign coordinates
			vga_coords <= {(counter_x + 4'b1010), (counter_y + 4'b1010)};
		end
		else if (erase) begin
			// Set flags
			drawn <= 1'b0;
			vga_colour = back_colour; // Blue
			// 
			if((laser_direction == 2'b00) && (counter_y >= (pos_y - 5'b10100))) begin // Up
				counter_y <= counter_y - 1'b1;
			end
			else if((laser_direction == 2'b10) && (counter_y <= (pos_y + 5'b10100))) begin // Down
				counter_y <= counter_y + 1'b1;
			end
			else if((laser_direction == 2'b01) && (counter_x <= (pos_x + 5'b10100))) begin // Right
				counter_x <= counter_x + 1'b1;
			end
			else if((laser_direction == 2'b11) && (counter_x >= (pos_x - 5'b10100))) begin // Left
				counter_x <= counter_x - 1'b1;
			end
			else begin
				// Reset counters
				draw_done <= 1'b1;
				counter_x <= pos_x;
				counter_y <= pos_y;
			end
			// Destroy car
			if(cars_in_range[0] == 1'b1) begin
				destroyed_cars[0]<= 1'b1;
			end
			else if(cars_in_range[1] == 1'b1) begin
				destroyed_cars[1]<= 1'b1;
			end
			else if(cars_in_range[2] == 1'b1) begin
				destroyed_cars[2]<= 1'b1;
			end
			else if(cars_in_range[3] == 1'b1) begin
				destroyed_cars[3]<= 1'b1;
			end
			// Assign coordinates
			vga_coords <= {(counter_x + 4'b1010), (counter_y + 4'b1010)};
		end
		else if(delay) begin
			//Set flags
			drawn <= 1'b0;
			draw_done <= delay_done_wire;
		end
	end
endmodule

// Module to count initial delay
module DelayLaser(Clock, resetn, Enable, delay_done);
	input Clock;
	input resetn;
	input Enable;
	output reg delay_done;

	reg [24:0] Q;

	always @(posedge Clock) begin
		if (!resetn) begin
			Q <= 0;
			delay_done <= 0;
		end

		else if (Q >= 25'b1111111001010000001010101) begin // 2/3 seconds on CLOCK_50, such that adjacent cars at 30pix/s will be out of range
			delay_done <= 1'b1;
			Q <= 0;
		end

		else if (Enable && delay_done != 1'b1) begin // do not count if delay has finished
			Q <= Q + 1;
		end
		
		else 
			delay_done <= 1'b0;
	end
endmodule

// Module to count initial delay // ModelSimmed
module CheckCar(input resetn,
					 input [7:0]car_x,
					 input [6:0]car_y,
					 input [7:0]tower_x,
					 input [6:0]tower_y,
					 output reg car_in_range,
					 output reg [1:0]laser_direction);
	always @(*) begin
		if(!resetn) begin
			car_in_range <= 0;
			laser_direction <= 0;
		end
		else if((car_x >= (tower_x - 4'b1010)) && (car_x <= (tower_x + 4'b1010)) && (car_y == (tower_y - 5'b10100))) begin
			car_in_range <= 1'b1;
			laser_direction <= 2'b00; // Up - 0
		end
		else if((car_x >= (tower_x - 4'b1010)) && (car_x <= (tower_x + 4'b1010)) && (car_y == (tower_y + 5'b10100))) begin
			car_in_range <= 1'b1;
			laser_direction <= 2'b10; // Down - 2
		end
		else if((car_y >= (tower_y - 4'b1010)) && (car_y <= (tower_y + 4'b1010)) && (car_x == (tower_x - 5'b10100))) begin
			car_in_range <= 1'b1;
			laser_direction <= 2'b11; // Left - 3
		end
		else if((car_y >= (tower_y - 4'b1010)) && (car_y <= (tower_y + 4'b1010)) && (car_x == (tower_x + 5'b10100))) begin
			car_in_range <= 1'b1;
			laser_direction <= 2'b01; // Right - 1
		end
		else begin // Car not in range
			car_in_range <= 1'b0;
			laser_direction <= 2'b00; // Down
		end
	end
endmodule
