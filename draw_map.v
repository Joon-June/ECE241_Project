module draw_map(
    input clk,
    input resetn,
    input enable,
    output reg map_done,
    output [8:0]colour,
    output [7:0]x, //Will go into VGA Input
    output [6:0]y //Will go into VGA Input
    );
    
    wire [14:0]mem_add;

    reg [7:0]temp_x;
    reg [6:0]temp_y;
	 reg [7:0]counter_x;
    reg [6:0]counter_y;
	 
	 reg delay;

    initial begin
        counter_x = 5'b0;
        counter_y = 5'b0;
        map_done = 0;
		  delay = 0;
    end
	
    //Memory Address Translator for 20x20 .mif files
    memory_address_translator_160x120 v1(
									  .x(counter_x), 
									  .y(counter_y), 
									  .mem_address(mem_add) //Connection A
									  ); 

    //.mif-initialized ram with map background
    ram19200x9_map_background U3(
            .address(mem_add),
			.clock(clk),
			.data(9'b0),
			.wren(1'b0),
			.q(colour)
        );  

    always @(posedge clk) begin
		  if(!resetn) begin
            counter_x <= 0;
            counter_y <= 0;
            map_done <= 0;
				temp_x <= 0;
				temp_y <= 0;
				delay <= 0;
        end
        else begin
            if(enable) begin
                if(counter_x == 0)
                    map_done <= 0;
				if(delay == 1) begin
					temp_x <= counter_x;
					temp_y <= counter_y;
							  
					counter_x <= counter_x + 1;
					if(counter_x == 8'b10011111) begin
					  counter_y <= counter_y + 1;
					  counter_x <= 0;
					end
			  
					if({counter_x, counter_y} == 15'b100111111110111) begin
						 map_done <= 1'b1;
						 counter_x <= 0;
						 counter_y <= 0;
						 delay <= 0;
					end
				end
				else
					delay <= 1;
            end
        end
    end

    assign x = temp_x;
    assign y = temp_y;
endmodule
