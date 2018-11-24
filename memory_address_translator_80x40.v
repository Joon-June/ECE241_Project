/* This module converts a user specified coordinates into a memory address. */
module memory_address_translator_80x40(
        input [6:0]x, 
        input [5:0]y, 
        output reg [11:0]mem_address
    );
	
	always @(*)
			mem_address = 11'b0 + y * (7'b1001111) + x;
endmodule
