module draw_SAVE_GPA(
    input clk,
    input resetn,
    output reg SAVE_GPA_done,
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
        SAVE_GPA_done = 0;
		  delay = 0;
    end
	
    //Memory Address Translator for 20x20 .mif files
    memory_address_translator_160x120 v1(
									  .x(counter_x), 
									  .y(counter_y), 
									  .mem_address(mem_add) //Connection A
									  ); 

    //.mif-initialized ram with map background
    rom19200x9_SAVE_GPA U3(
            .address(mem_add),
            .clock(clk),
            .q(colour)
        );  

    always @(posedge clk) begin
		  if(!resetn) begin
            counter_x <= 0;
            counter_y <= 0;
            SAVE_GPA_done <= 0;
				temp_x <= 0;
				temp_y <= 0;
				delay <= 0;
        end
        else begin
				if(delay == 1) begin
					temp_x <= counter_x;
					temp_y <= counter_y;
					if(counter_x == 0)
						 SAVE_GPA_done <= 0;
							  
				  
					counter_x <= counter_x + 1;
					if(counter_x == 8'b10011111) begin
					  counter_y <= counter_y + 1;
					  counter_x <= 0;
					end
			  
					//Same as {counter_x, counter_y} >= {19, 19} - i.e. done accessing square memory
					if({counter_x, counter_y} == 15'b100111111110111) begin
						 SAVE_GPA_done <= 1;
						 counter_x <= 0;
						 counter_y <= 0;
						 delay <= 0;
					end
				end
				else
					delay <= 1;
        end
    end

    assign x = temp_x;
    assign y = temp_y;
endmodule
