/* This module converts a user specified coordinates into a memory address. */
module memory_address_translator_160x120(
        input [7:0]x, 
        input [6:0]y, 
        output reg [14:0]mem_address
    );
	
	always @(*)
			mem_address = 15'b0 + y * (8'b10100000) + x;
endmodule
