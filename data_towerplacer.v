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
	 
	reg [2:0] Counter_X; // Column in grid, not coordinates on vga
	reg [2:0] Counter_Y; // Row in grid, not coordinates on vga
	
	/*____________Map Related Registers___________*/
	reg [7:0] counter_memory_x_map; //counter to access map memory
	reg [6:0] counter_memory_y_map; //counter to access map memory
	reg [14:0] memory_address_map; //need 15 bits to access map.mif (19200 addresses - 160 x 120)
	
	/*___________Square Related Registers___________*/
	reg [4:0] counter_memory_x_square; //coutner to acess square memory
	reg [4:0] counter_memory_y_square; //coutner to acess square memory
	reg [8:0] memory_address_square; //need 8 bit to access square.mif (400 addresses - 20 x 20)
	 
	  /*___________Register for Gamie Grid___________*/
	reg [7:0] game_grid [5:0];
	initial begin //Initialize the game grid
		for(int i = 0; i < 6; i++) begin
			game_grid[i] = 8'b11111111;
		end
	end
	 
	/*___________________Flags____________________*/
	//  reg down_wait = 1'b0;
	 
	/*___________Memory Accessing Wires___________*/
	wire [8:0] colour_map;
	wire [8:0] colour_square;
	wire [8:0] colour_tower;

	

	ram19200x9 map_background(
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

	ram400x9_tower tower_unit(
					.address(memory_address_square),
					.clock(clk),
					.data(9'b0),
					.wren(1'b0),
					.q(colour_tower)
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

			for(int i = 0; i < 6; i++) begin
				game_grid[i] = 8'b11111111;
			end
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
		end
		else if (draw_square) begin
			colour <= colour_square;
			coordinates <= {Counter_X * 20 + counter_memory_x_square, 
							Counter_Y * 20 + counter_memory_y_square};
			memory_address_square <= memory_address_square + 1;

			counter_memory_x_square <= counter_memory_x_square +1;
			if(counter_memory_x_square >= 5'b10011) begin
				counter_memory_y_square <= counter_memory_y_square +1;
				counter_memory_x_square <= 0;
			end

			//Same as {x, y} >= {19, 19} - i.e. done accessing square memory
			if({counter_memory_x_square, counter_memory_y_square} >= 10'b1001110011) begin
				square_done <= 1;
				memory_address_square <= 0;
				counter_memory_x_square <= 0;
				counter_memory_y_square <= 0;
			end
		end
		else if (move_right) begin
			//Reset the flag for next use
			erase_square_done <= 0;
			// increment counter, update valid
			if(Counter_X < 3'b111) begin 
				Counter_X <= Counter_X + 1;
				valid <= ~(game_grid[Counter_X + 1][Counter_Y]);
			end
			else begin
				Counter_X <= 0;
				valid <= ~(game_grid[0][Counter_Y]);
			end
		end
		else if (move_down) begin // because move down needs to get a new memory from memory, it has to wait for one cycle
			//Reset the flag for next use
			erase_square_done <= 0;
			//increment counter, update valid
			if(Counter_Y < 3'b101)
				Counter_Y <= Counter_Y + 1;
				valid <= ~(game_grid[Counter_X][Counter_Y]);
			else
				Counter_Y <= 0;
				valid <= ~(game_grid[Counter_X][0]);
		end
		else if (move_down_wait) begin
			valid <= 0;
		end
		else if (move_right_wait) begin
			valid <= 0;
		end
		else if(draw_tower) begin
			colour <= colour_tower;
			coordinates <= {Counter_X * 20 + counter_memory_x_square, 
							Counter_Y * 20 + counter_memory_y_square};
			memory_address_square <= memory_address_square + 1;

			counter_memory_x_square <= counter_memory_x_square +1;
			if(counter_memory_x_square >= 5'b10011) begin
				counter_memory_y_square <= counter_memory_y_square +1;
				counter_memory_x_square <= 0;
			end

			//Same as {x, y} >= {19, 19} - i.e. done accessing square memory
			if({counter_memory_x_square, counter_memory_y_square} >= 10'b1001110011) begin
				tower_done <= 1;
				memory_address_square <= 0;
				counter_memory_x_square <= 0;
				counter_memory_y_square <= 0;
				game_grid[Counter_X][Counter_Y] <= 0;
			end
		end
		//Separating right / down case is for state machine. Actual deletion is the same functionality
		else if(erase_square_down | erase_square_right | erase_square_tower) begin 
			//Reset the flag for next use
			square_done <= 0;
			//Erase current cell's suqare
			colour <= colour_map;
			coordinates <= {Counter_X * 20 + counter_memory_x_square, 
							Counter_Y * 20 + counter_memory_y_square};
			memory_address_map <= memory_address_map + 1;

			counter_memory_x_square <= counter_memory_x_square +1;
			if(counter_memory_x_square >= 5'b10011) begin
				counter_memory_y_square <= counter_memory_y_square +1;
				counter_memory_x_square <= 0;
			end

			//Same as {x, y} >= {19, 19} - i.e. done accessing square memory
			if({counter_memory_x_square, counter_memory_y_square} >= 10'b1001110011) begin
				erase_square_done <= 1;
				memory_address_map <= 0;
				counter_memory_x_square <= 0;
				counter_memory_y_square <= 0;
			end
		end
	end
endmodule
