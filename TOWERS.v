module TOWERS(
//_________________________Inputs_____________________________//
        input clk,
        input resetn,
        //________User Input________//
		  input go_down,
		  input go_right,
		  input go_draw,
    
        //_____Control Signlas______//
        input stage_1_draw_tower,
        input stage_2_draw_tower,
        input stage_3_draw_tower,
//___________________________________________________________//


//_______________________Outputs_____________________________//
        output tower_wren,
        //_____Control Feedback_____//
        output stage_1_tower_done,
        output stage_2_tower_done,
        output stage_3_tower_done,

        //_______VGA Outputs________//
        output reg [14:0]coord,
        output reg [8:0]colour,
		  
		  //_______Map Memory Outputs/Inputs________//
		  input [8:0]colour_erase_square_from_mem,
		  output [14:0]erase_mem_address,
		  output writeToMapEnable
		  
 
//__________________________________________________________//
);

//_________________________Wires & Registers_________________________//
        wire stage_1_tower_wren;
        wire stage_2_tower_wren;
        wire stage_3_tower_wren;

        //Stage 1
        wire [14:0]coord_tower_1;
        wire [8:0]colour_tower_1;
		  wire [14:0]erase_mem_address_1;

        //Stage 2
        wire [14:0]coord_tower_2;
        wire [8:0]colour_tower_2;
		  wire [14:0]erase_mem_address_2;

        //Stage 3
        wire [14:0]coord_tower_3;
        wire [8:0]colour_tower_3;
		  wire [14:0]erase_mem_address_3;

		  
		  //Mux for Cood and Tower Selection
        always @(*) begin
          if(stage_1_draw_tower) begin
                coord = coord_tower_1;
                colour = colour_tower_1;
					 erase_mem_address = erase_mem_address_1;
          end
          else if(stage_2_draw_tower) begin
                coord = coord_tower_2;
                colour = colour_tower_2;
					 erase_mem_address = erase_mem_address_2;
          end
          else if(stage_3_draw_tower) begin
                coord = coord_tower_3;
                colour = colour_tower_3;
					 erase_mem_address = erase_mem_address_3;
          end
			 else begin
					coordr = 0;
					colour = 0;
			 end
        end 
		  
		 // Tower WriteEn Signal for VGA
       assign tower_wren = stage_1_tower_wren | stage_2_tower_wren | stage_3_tower_wren;
		 
		 // writeToMap signal
		 wire [2:0]writeToMap;
		 assign writeToMapEnable = |writeToMap;

//___________________________________________________________________//


//______________________Module Instatiations_________________________//
	tower TOWER1(
		//______Inputs______//
		.clk(clk),
		.resetn(resetn),
		.go_down(go_down),
		.go_right(go_right),
		.go_draw(go_draw),
      .enable_draw(stage_1_draw_tower),
		.colour_erase_square_from_mem(colour_erase_square_from_mem),
		
		//______Outputs______//
		.vga_WriteEn(stage_1_tower_wren),
      .vga_coords(coord_tower_1), 
		.vga_colour(colour_tower_1),
      .tower_done_out(stage_1_tower_done),
		.erase_mem_address(erase_mem_address_1),
		.writeToMap(writeToMap[0])
   );

   	tower TOWER2(
		//______Inputs______//
		.clk(clk),
		.resetn(resetn),
		.go_down(go_down),
		.go_right(go_right),
		.go_draw(go_draw),
		.enable_draw(stage_2_draw_tower),
		.colour_erase_square_from_mem(colour_erase_square_from_mem),

		//______Outputs______//
		.vga_WriteEn(stage_2_tower_wren),
      .vga_coords(coord_tower_2), 
		.vga_colour(colour_tower_2),
      .tower_done_out(stage_2_tower_done),
		.erase_mem_address(erase_mem_address_2),
		.writeToMap(writeToMap[1])
   );

   	tower TOWER3(
		//______Inputs______//
		.clk(clk),
		.resetn(resetn),
		.go_down(go_down),
		.go_right(go_right),
		.go_draw(go_draw),
      .enable_draw(stage_3_draw_tower),
		.colour_erase_square_from_mem(colour_erase_square_from_mem),
		
		//______Outputs______//
		.vga_WriteEn(stage_3_tower_wren),
      .vga_coords(coord_tower_3), 
		.vga_colour(colour_tower_3),
      .tower_done_out(stage_3_tower_done),
		.erase_mem_address(erase_mem_address_3),
		.writeToMap(writeToMap[2])
   );
//___________________________________________________________________//


endmodule
