module erase_square(
    input clk,
    input resetn,
	input enable,
    input [3:0]COUNTER_X, //Uppercase indicates grid coutner
    input [3:0]COUNTER_Y, //Uppercase indicates grid coutner
	 input [8:0]colour_erase_square,
    output [8:0]colour,
	 output reg erase_square_done,
    output [7:0]x, //Will go into VGA Input
    output [6:0]y, //Will go into VGA Input
	 output [14:0]map_address
    );
    

	 
    wire [14:0]mem_add;
	
    reg [4:0]temp_x;
    reg [4:0]temp_y;
	 reg [4:0]counter_x;
    reg [4:0]counter_y;
	 
	 reg [2:0]delay;

    initial begin
        counter_x = 5'b0;
        counter_y = 5'b0;
        erase_square_done = 0;
		  delay = 0;
    end
	
	//Connection to current state ram
	assign colour = colour_erase_square;
	assign map_address = mem_add;
	
	wire [7:0]x_temp_mem;
	wire [6:0]y_temp_mem;
	
	assign x_temp_mem = 8'b0 + (COUNTER_X * 5'b10100) + counter_x;
	assign y_temp_mem = 7'b0 + (COUNTER_Y * 5'b10100) + counter_y;

	assign x = 8'b0 + COUNTER_X * 5'b10100 + temp_x;
    assign y = 7'b0 + COUNTER_Y * 5'b10100 + temp_y;
	
    //Memory Address Translator for 20x20 .mif files
    memory_address_translator_160x120 v1(
									  .x(x_temp_mem), 
									  .y(y_temp_mem), 
									  .mem_address(mem_add) //Connection A
									  ); 

//    //.mif-initialized ram with map background
//	ram19200x9_map_background map_background(
//						.address(mem_add),
//						.clock(clk),
//						.data(9'b0),
//						.wren(1'b0),
//						.q(colour)
//						);

    always @(posedge clk) begin
		  if(!resetn) begin
            counter_x <= 0;
            counter_y <= 0;
			erase_square_done <= 0;
				temp_x <= 0;
				temp_y <= 0;
				delay <= 0;
        end
        else begin
			if(counter_x == 0)
				erase_square_done <= 0;

			if(enable) begin
				if(delay == 3'b111) begin
					temp_x <= counter_x;
					temp_y <= counter_y;
				  
					counter_x <= counter_x + 1;
					if(counter_x == 5'b10011) begin
					  counter_y <= counter_y + 1;
					  counter_x <= 0;
					end
			  
					//Same as {counter_x, counter_y} >= {19, 19} - i.e. done accessing square memory
					if({counter_x, counter_y} == 10'b1001110011) begin
						 erase_square_done <= 1;
						 counter_x <= 0;
						 counter_y <= 0;
						 delay <= 0;
					end
				end
				else
					delay <= delay + 1'b1;
			end
        end
    end
endmodule
