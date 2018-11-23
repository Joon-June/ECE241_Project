module draw_car(
    input clk,
    input resetn,
    input [7:0]COUNTER_X, //Uppercase indicates grid coutner
    input [6:0]COUNTER_Y, //Uppercase indicates grid coutner
    output reg [8:0]colour,
	 output reg draw_done,
    output [7:0]x, //Will go into VGA Input
    output [6:0]y //Will go into VGA Input
    );
    
    wire [8:0]mem_add;
    wire [8:0]colour_car;
	 
	 reg [4:0]temp_x;
	 reg [4:0]temp_y;
    reg [4:0]counter_x;
    reg [4:0]counter_y;

    initial begin
        counter_x = 8'b0;
        counter_y = 7'b0;
        draw_done = 0;
    end

    //Memory Address Translator for 20x20 .mif files
    memory_address_translator_20x20 m1(
                                .x(counter_x), 
                                .y(counter_y), 
                                .mem_address(mem_add) //Connection A
                                ); 

    //.mif-initialized ram with tower image
    ram400x9_car car_unit(
					.address(mem_add), //Connection A
					.clock(clk),
					.data(9'b0),
					.wren(1'b0),
					.q(colour_car)
					);

    always @(posedge clk) begin
        if(!resetn) begin
            counter_x <= 0;
            counter_y <= 0;
				temp_x <= 0;
				temp_y <= 0;
        end
        else begin            
            temp_x <= counter_x;
				temp_y <= counter_y;
				if(counter_x == 0)
                draw_done <= 0;

				 counter_x <= counter_x + 1;
				 if(counter_x == 5'b10011) begin
					  counter_y <= counter_y + 1;
					  counter_x <= 0;
				 end
        
            //Same as {counter_x, counter_y} >= {19, 19} - i.e. done accessing square memory
            if({counter_x, counter_y} == 10'b1001110011) begin
                draw_done <= 1'b1;
                counter_x <= 0;
                counter_y <= 0;
            end
        end
    end

    always @(colour_car) //1 cycle delay from counter_x & counter_y
        colour = colour_car;

    assign x = COUNTER_X + temp_x;
    assign y = COUNTER_Y + temp_y;
endmodule
