module draw_stage_1_start(
    input clk,
    input resetn,
    output reg stage_1_start_done,
    output [8:0]colour,
    output [7:0]x, //Will go into VGA Input
    output [6:0]y //Will go into VGA Input
    );

    
    wire [11:0]mem_add; //up to 3200

    reg [6:0]temp_x; //up to 79
    reg [5:0]temp_y; //up to 39
	 reg [6:0]counter_x;
    reg [5:0]counter_y;
	 
	 reg delay;

    initial begin
        counter_x = 0;
        counter_y = 0;
        stage_1_start_done = 0;
		  delay = 0;
    end
	
    //Memory Address Translator for 20x20 .mif files
    memory_address_translator_80x40 v1(
									  .x(counter_x), 
									  .y(counter_y), 
									  .mem_address(mem_add) //Connection A
									  ); 

    //.mif-initialized ram with map background
    rom3200x9_stage_1_start U1(
            .address(mem_add),
            .clock(clk),
            .q(colour)
        );

    always @(posedge clk) begin
		  if(!resetn) begin
            counter_x <= 0;
            counter_y <= 0;
				temp_x <= 0;
				temp_y <= 0;
                stage_1_start_done <= 0;
				delay <= 0;
        end
        else begin
				if(delay == 1) begin
					temp_x <= counter_x;
					temp_y <= counter_y;							  
				  
					counter_x <= counter_x + 1;
					if(counter_x == 7'b1001111) begin
					  counter_y <= counter_y + 1;
					  counter_x <= 0;
					end
			  
					//Same as {counter_x, counter_y} >= {79, 39} - i.e. done accessing square memory
					if({counter_x, counter_y} == 13'b1001111100111) begin
						 stage_1_start_done <= 1;
						 counter_x <= 0;
						 counter_y <= 0;
						 delay <= 0;
					end
				end
				else
					delay <= 1;
        end
    end

    //has to start at (x,y) = (39, 39) = (100111, 100111)
    assign x = 8'b0 + temp_x + 6'b100111; // + 39
    assign y = 7'b0 + temp_y + 6'b100111; // + 39
endmodule
