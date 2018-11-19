/* This module converts a user specified coordinates into a memory address. */
module memory_address_translator_20x20(
        input [4:0]x, 
        input [4:0]y, 
        output reg [8:0]mem_address
    );
	
	always @(*)
			mem_address = 9'b0 + y * (5'b10100) + x;
endmodule
