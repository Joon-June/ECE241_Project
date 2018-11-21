module grid_selection_square(
    input clk,
    input resetn,
    input [3:0]COUNTER_X, //Uppercase indicates grid coutner
    input [3:0]COUNTER_Y, //Uppercase indicates grid coutner
    output reg [8:0]colour,
	output reg square_done,
    output [7:0]x, //Will go into VGA Input
    output [6:0]y //Will go into VGA Input
    );
    
    wire [8:0]mem_add;
    wire [8:0]colour_square;

    reg [4:0]temp_x;
    reg [4:0]temp_y;
	 reg [4:0]counter_x;
    reg [4:0]counter_y;

    initial begin
        counter_x = 5'b0;
        counter_y = 5'b0;
        square_done = 0;
    end

    //Memory Address Translator for 20x20 .mif files
    memory_address_translator_20x20 m1(
                                .x(counter_x), 
                                .y(counter_y), 
                                .mem_address(mem_add) //Connection A
                                ); 

	ram400x9_square_grid_selection select_grid(
									.address(mem_add),
									.clock(clk),
									.data(9'b0),
									.wren(1'b0),
									.q(colour_square)
									);

    always @(posedge clk) begin
		  if(!resetn) begin
            counter_x <= 0;
            counter_y <= 0;
        end
        else begin
            temp_x <= counter_x;
			   temp_y <= counter_y;
			   if(counter_x == 0)
                square_done <= 0;
                    
           
				counter_x <= counter_x + 1;
				if(counter_x == 5'b10011) begin
				  counter_y <= counter_y + 1;
				  counter_x <= 0;
				end
        
            //Same as {counter_x, counter_y} >= {19, 19} - i.e. done accessing square memory
            if({counter_x, counter_y} == 10'b1001110011) begin
                square_done <= 1;
                counter_x <= 0;
                counter_y <= 0;
					 temp_x <= counter_x;
					 temp_y <= counter_y;
            end
        end
    end

    always @(colour_square) //1 cycle delay from counter_x & counter_y
        colour = colour_square;

    assign x = COUNTER_X * 5'b10100 + temp_x;
    assign y = COUNTER_Y * 5'b10100 + temp_y;
endmodule
