module datapath(
   input clk,
   input resetn,
	 //____Control Signals___//
   input top_left, 
	input draw_square, 
	input move_right, 
	input move_down, 
	input move_down_wait, 
	input move_right_wait,
	input draw_tower,
	input erase_square_right,
	input erase_square_down,
	input erase_square_tower,
	 //_______________________//
   	output reg valid,
	output reg [8:0] colour,
	output reg [14:0] coordinates,

	//________Control Feedback__________//
	output reg square_done,
	output reg erase_square_done,
	output reg tower_done
    );
	 
	reg [3:0] Counter_X; // Column in grid, not coordinates on vga
	reg [3:0] Counter_Y; // Row in grid, not coordinates on vga
	reg [1:0] two_cycle_delay;


	/*____________Map Related Registers___________*/
	reg [7:0] counter_memory_x_map; //counter to access map memory
	reg [6:0] counter_memory_y_map; //counter to access map memory
	reg [14:0] memory_address_map; //need 15 bits to access map.mif (19200 addresses - 160 x 120)
	
	/*___________Square Related Registers___________*/
	reg [7:0] counter_memory_x_square; //coutner to acess square memory
	reg [6:0] counter_memory_y_square; //coutner to acess square memory
	reg [8:0] memory_address_square; //need 8 bit to access square.mif (400 addresses - 20 x 20)
	 
	  /*___________Register for Gamie Grid___________*/
	reg [7:0] game_grid [5:0];
	initial begin //Initialize the game grid
		//for(int i = 0; i < 6; i++) begin
			game_grid[0] = 8'b0;
			game_grid[1] = 8'b0;
			game_grid[2] = 8'b0;
			game_grid[3] = 8'b0;
			game_grid[4] = 8'b0;
			game_grid[5] = 8'b0;
		//end
	end
	 
	/*___________________Flags____________________*/
	//  reg down_wait = 1'b0;
	 
	/*___________Memory Accessing Wires___________*/
	wire [8:0] colour_map;
	wire [8:0] colour_square;
	wire [8:0] colour_tower;
	wire tower_done_wire;
	wire [14:0]coord;

	

	ram19200x9_map_background map_background(
						.address(memory_address_map),
						.clock(clk),
						.data(9'b0),
						.wren(1'b0),
						.q(colour_map)
						);
							
	ram400x9_square_grid_selection select_grid(
									.address(memory_address_square),
									.clock(clk),
									.data(9'b0),
									.wren(1'b0),
									.q(colour_square)
									);
	
	draw_tower t1(
			.clk(clk && draw_tower),
			.resetn(resetn),
			.COUNTER_X(Counter_X),
			.COUNTER_Y(Counter_Y),
			.colour(colour_tower),
			.tower_done(tower_done_wire),
			.x(coord[14:7]),
			.y(coord[6:0])
			);




	//  ram1x48_game_grid(
	// 				.address(memory_address_square),
	// 				.clock(clk),
	// 				.data(9'b0),
	// 				.wren(1'b0),
	// 				.q(colour_square)
	// 				);
	 
	 always @ (posedge clk) begin
		if (!resetn) begin
			Counter_X <= 0;
			Counter_Y <= 0;
			valid <= 0;
			counter_memory_x_map <= 0;
	 		counter_memory_y_map <= 0;
			memory_address_map <= 0;

			counter_memory_x_square <= 0;
			counter_memory_y_square <= 0;
			memory_address_square <= 0;

			square_done <= 0;
			erase_square_done <= 0;
			tower_done <= 0;
			coordinates <= 0;

			//for(int i = 0; i < 6; i++) begin
			game_grid[0] <= 8'b0;
			game_grid[1] <= 8'b0;
			game_grid[2] <= 8'b0;
			game_grid[3] <= 8'b0;
			game_grid[4] <= 8'b0;
			game_grid[5] <= 8'b0;
			//end

			two_cycle_delay = 2'b00;
		end
		else if (top_left) begin
			Counter_X <= 0;
			Counter_Y <= 0;
			valid <= 0;
			counter_memory_x_map <= 0;
	 		counter_memory_y_map <= 0;
			memory_address_map <= 0;

			counter_memory_x_square <= 0;
			counter_memory_y_square <= 0;
			memory_address_square <= 0;

			square_done <= 0;
			erase_square_done <= 0;
			tower_done <= 0;
			coordinates <= 0;

			two_cycle_delay = 2'b00;
		end
		else if (draw_square) begin
			if(!square_done) begin
				colour <= colour_square;
				if (two_cycle_delay == 2'b10) begin
					memory_address_square <= memory_address_square + 1;
					coordinates <= {counter_memory_x_square + 1'b1 + (Counter_X * 5'b10100), 
									counter_memory_y_square + (Counter_Y * 5'b10100)};
					

					counter_memory_x_square <= counter_memory_x_square + 1;
					if(counter_memory_x_square >= 8'b00010011) begin
						counter_memory_y_square <= counter_memory_y_square + 1;
						counter_memory_x_square <= 0;
						coordinates <= {(8'b0 + (Counter_X * 5'b10100)), coordinates[6:0]};
					end

					//Same as {x, y} >= {19, 19} - i.e. done accessing square memory
					if({counter_memory_x_square, counter_memory_y_square} >= 15'b000100110010011) begin
						square_done <= 1;
						memory_address_square <= 0;
						counter_memory_x_square <= 0;
						counter_memory_y_square <= 0;
					end
				end
				if(two_cycle_delay >= 2'b10)
					two_cycle_delay <= 2'b00;
				else
					two_cycle_delay <= two_cycle_delay + 1;
			end
		end
		else if (move_right) begin
			//Reset the flag for next use
			erase_square_done <= 0;
			// increment counter, update valid
			if(!valid) begin
				if(Counter_X < 3'b111) begin 
					Counter_X <= Counter_X + 1;
					coordinates <= {(5'b10100 * (Counter_X + 1)) + 8'b0, (5'b10100 * Counter_Y) + 7'b0};
					valid <= 1'b1; //~(game_grid[Counter_X + 1][Counter_Y]);
				end
				else begin
					Counter_X <= 0;
					coordinates <= {8'b0, (5'b10100 * Counter_Y) + 7'b0};
					valid <= 1'b1; //~(game_grid[0][Counter_Y]);
				end
			end
		end
		else if (move_down) begin // because move down needs to get a new memory from memory, it has to wait for one cycle
			//Reset the flag for next use
			erase_square_done <= 0;
			//increment counter, update valid
			if(!valid) begin
				if(Counter_Y < 3'b101) begin
					Counter_Y <= Counter_Y + 1;
					coordinates <= {(5'b10100 * Counter_X) + 8'b0, (5'b10100 * (Counter_Y + 1)) + 7'b0};
					valid <= 1'b1; //~(game_grid[Counter_X][Counter_Y + 1]);
				end
				else begin
					Counter_Y <= 0;
					coordinates <= {(5'b10100 * Counter_X) + 8'b0, 7'b0};
					valid <= 1'b1; //~(game_grid[Counter_X][0]);
				end
			end
		end
		else if (move_down_wait) begin
			two_cycle_delay = 2'b00;
			valid <= 0;
		end
		else if (move_right_wait) begin
			two_cycle_delay = 2'b00;
			valid <= 0;
		end
		else if(draw_tower) begin
			//Reset the flag for next use
			erase_square_done <= 0;
			coordinates <= coord;
			colour <= colour_tower;
			tower_done <= tower_done_wire;
		end
		//Separating right / down case is for state machine. Actual deletion is the same functionality
		else if(erase_square_down | erase_square_right | erase_square_tower) begin 		
				//Reset the flag for next use
				square_done <= 0;
				//Erase current cell's square
				colour <= colour_map;
				if (two_cycle_delay == 2'b10) begin
					coordinates <= {((Counter_X * 5'b10100) + counter_memory_x_square), 
									((Counter_Y * 5'b10100) + counter_memory_y_square)};
									
					memory_address_map <= (Counter_Y * 8'b10100000 * 5'b10100) + (Counter_X * 5'b10100) + 
												(8'b10100000 * counter_memory_y_square) + counter_memory_x_square;
											
					counter_memory_x_square <= counter_memory_x_square +1;
					if(counter_memory_x_square >= 8'b00010011) begin
						counter_memory_y_square <= counter_memory_y_square +1;
						counter_memory_x_square <= 0;
					end

					//Same as {x, y} >= {19, 19} - i.e. done accessing map memory
					if({counter_memory_x_square, counter_memory_y_square} >= 15'b000100110010011) begin
						erase_square_done <= 1;
						memory_address_map <= 0;
						counter_memory_x_square <= 0;
						counter_memory_y_square <= 0;
					end
				end
				if(two_cycle_delay >= 2'b10)
					two_cycle_delay <= 2'b00;
				else
					two_cycle_delay <= two_cycle_delay + 1;
			end
	end
endmodule
