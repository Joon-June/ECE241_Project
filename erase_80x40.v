module erase_80x40(
    input clk,
    input resetn,
    input enable,
    input [8:0]colour_erase_from_ram,
    output reg erase_done,
    output [8:0]colour,
    output [14:0]mem_add_read_from_ram,
    output [7:0]x, //Will go into VGA Input
    output [6:0]y //Will go into VGA Input
    );
    
    wire [14:0]mem_add;

    reg [6:0]temp_x;
    reg [6:0]temp_y;
	 reg [6:0]counter_x;
    reg [6:0]counter_y;
	 
	 reg delay;

    initial begin
        counter_x = 7'b0 + 6'b100111;
        counter_y = 7'b0 + 6'b100111;
        erase_done = 0;
		delay = 0;
    end

    //Connection to current state ram
    assign mem_add_read_from_ram = mem_add;
    assign colour = colour_erase_from_ram;

    assign x = 8'b0 + temp_x;
    assign y = 7'b0 + temp_y;


    //Memory Address Translator for 20x20 .mif files
    memory_address_translator_160x120 v1(
									  .x(counter_x), 
									  .y(counter_y), 
									  .mem_address(mem_add) //Connection A
									  ); 

    always @(posedge clk) begin
		  if(!resetn) begin
            counter_x <= 7'b0 + 6'b100111;
            counter_y <= 7'b0 + 6'b100111;
            erase_done <= 0;
				temp_x <= 7'b0 + 6'b100111;
				temp_y <= 7'b0 + 6'b100111;
				delay <= 0;
        end
        else begin
            if(enable) begin
				if(delay == 1) begin
					temp_x <= counter_x;
					temp_y <= counter_y;
					if(counter_x == 6'b100111)
						 erase_done <= 0;
							  
				  
					counter_x <= counter_x + 1;
					if(counter_x == 7'b1110111) begin //119
					  counter_y <= counter_y + 1;
					  counter_x <= 7'b0 + 6'b100111; //39
					end
			  
					//Same as {counter_x, counter_y} >= {119, 79} - i.e. done accessing square memory
					if({counter_x, counter_y} == 14'b11101111001111) begin
						 erase_done <= 1;
						 counter_x <= 6'b100111;
						 counter_y <= 6'b100111;
						 delay <= 0;
					end
				end
				else
					delay <= 1;
            end
        end
    end
endmodule
