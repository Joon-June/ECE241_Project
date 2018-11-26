module datapath(
   input clk,
   input resetn,
	input [8:0]colour_erase_square_from_mem, // will come from common map memory
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
	output [14:0]tower_coordinates, // Top left location where tower is drawn
	output reg tower_drawn,

	//________Control Feedback__________//
	output reg square_done,
	output reg erase_square_done,
	output reg tower_done,
	output reg [14:0]map_mem_address // will go to common map memory
    );
	 
	reg [3:0] Counter_X; // Column in grid, not coordinates on vga
	reg [3:0] Counter_Y; // Row in grid, not coordinates on vga
	reg [1:0]two_cycle_delay;


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
	wire [8:0] colour_tower;
	wire tower_done_wire;
	wire [14:0]coord_tower;
	
	wire [8:0] colour_square;
	wire square_done_wire;
	wire [14:0]coord_square;
	
	wire [8:0]colour_erase_square;
	wire erase_square_done_wire;
	wire [14:0]coord_erase_square;
			
	// For map background
	wire [14:0]w_map_draw_add, w_map_erase_add;
	
	// For lasers
	assign tower_coordinates = {(5'b10100 * Counter_X) + 8'b0, (5'b10100 * Counter_Y) + 7'b0};
	
	draw_tower t1(
			.clk(clk && draw_tower),
			.resetn(resetn),
			.COUNTER_X(Counter_X),
			.COUNTER_Y(Counter_Y),
			.colour(colour_tower),
			.tower_done(tower_done_wire),
			.x(coord_tower[14:7]),
			.y(coord_tower[6:0]),
			.map_mem_add(w_map_draw_add)
			);
	
	draw_square_grid s1(
			.clk(clk && draw_square),
			.resetn(resetn),
			.COUNTER_X(Counter_X), //Uppercase indicates grid coutner
			.COUNTER_Y(Counter_Y), //Uppercase indicates grid coutner
			.colour(colour_square),
			.square_done(square_done_wire),
			.x(coord_square[14:7]), //Will go into VGA Input
			.y(coord_square[6:0]) //Will go into VGA Input
		 );
	
	erase_square e1(
			//________Inputs__________//
			.clk(clk && (erase_square_down | erase_square_right | erase_square_tower)),
			.resetn(resetn),
			.COUNTER_X(Counter_X), //Uppercase indicates grid coutner
			.COUNTER_Y(Counter_Y), //Uppercase indicates grid coutner
			.colour_erase_square(colour_erase_square_from_mem), // Will come from to map memory
			
			//________Outputs__________//
			.colour(colour_erase_square),
			.erase_square_done(erase_square_done_wire),
			.x(coord_erase_square[14:7]), //Will go into VGA Input
			.y(coord_erase_square[6:0]), //Will go into VGA Input
			.map_address(w_map_erase_add) // Will go to map memory
		 );
	 
	 always @ (posedge clk) begin
		if (!resetn) begin
			Counter_X <= 0;
			Counter_Y <= 0;
			valid <= 0;

			square_done <= 0;
			erase_square_done <= 0;
			tower_done <= 0;
			coordinates <= 0;
			tower_drawn <= 0;

			//for(int i = 0; i < 6; i++) begin
			game_grid[0] <= 8'b0;
			game_grid[1] <= 8'b0;
			game_grid[2] <= 8'b0;
			game_grid[3] <= 8'b0;
			game_grid[4] <= 8'b0;
			game_grid[5] <= 8'b0;
			//end
		end
		else if (top_left) begin
			Counter_X <= 0;
			Counter_Y <= 0;
			valid <= 0;

			square_done <= 0;
			erase_square_done <= 0;
			tower_done <= 0;
			coordinates <= 0;
			tower_drawn <= 0;
		end
		else if (draw_square) begin
			if(!square_done) begin
				coordinates <= coord_square;
				colour <= colour_square;
				square_done <= square_done_wire;
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
			valid <= 0;
		end
		else if (move_right_wait) begin
			valid <= 0;
		end
		else if(draw_tower) begin
			//Reset the flag for next use
			erase_square_done <= 0;
			coordinates <= coord_tower;
			colour <= colour_tower;
			tower_done <= tower_done_wire;
			map_mem_address <= w_map_draw_add;
			// for lasers
			tower_drawn <= 1'b1;
		end
		//Separating right / down case is for state machine. Actual deletion is the same functionality
		else if(erase_square_down | erase_square_right | erase_square_tower) begin 		
			//Reset the flag for next use
			square_done <= 0;
			//Erase current cell's square
			colour <= colour_erase_square;
			coordinates <= coord_erase_square;
			erase_square_done <= erase_square_done_wire;
			// send address to map background
			map_mem_address <= w_map_erase_add;
		end
	end
endmodule
