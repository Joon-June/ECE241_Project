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
        output reg [8:0]colour
 
//__________________________________________________________//
);

//_________________________Wires & Registers_________________________//
        wire stage_1_tower_wren;
        wire stage_2_tower_wren;
        wire stage_3_tower_wren;

        //Stage 1
        wire [14:0]coord_tower_1;
        wire [8:0]colour_tower_1;

        //Stage 2
        wire [14:0]coord_tower_2;
        wire [8:0]colour_tower_2;

        //Stage 3
        wire [14:0]coord_tower_3;
        wire [8:0]colour_tower_3;

        always @(*) begin
          if(stage_1_draw_tower) begin
                coord = coord_tower_1;
                colour = colour_tower_1;
          end
          else if(stage_2_draw_tower) begin
                coord = coord_tower_2;
                colour = colour_tower_2;
          end
          else if(stage_3_draw_tower) begin
                coord = coord_tower_3;
                colour = colour_tower_3;
          end
			 else begin
					coordr = 0;
					colour = 0;
			 end
        end 

        assign tower_wren = stage_1_tower_wren | stage_2_tower_wren | stage_3_tower_wren;

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
		
		//______Outputs______//
		.vga_WriteEn(stage_1_tower_wren),
        .vga_coords(coord_tower_1), 
		.vga_colour(colour_tower_1),
        .tower_done_out(stage_1_tower_done)
   );

   	tower TOWER2(
		//______Inputs______//
		.clk(clk),
		.resetn(resetn),
		.go_down(go_down),
		.go_right(go_right),
		.go_draw(go_draw),
		.enable_draw(stage_2_draw_tower),

		//______Outputs______//
		.vga_WriteEn(stage_2_tower_wren),
        .vga_coords(coord_tower_2), 
		.vga_colour(colour_tower_2),
        .tower_done_out(stage_2_tower_done)
   );

   	tower TOWER3(
		//______Inputs______//
		.clk(clk),
		.resetn(resetn),
		.go_down(go_down),
		.go_right(go_right),
		.go_draw(go_draw),
        .enable_draw(stage_3_draw_tower),
		
		//______Outputs______//
		.vga_WriteEn(stage_3_tower_wren),
        .vga_coords(coord_tower_3), 
		.vga_colour(colour_tower_3),
        .tower_done_out(stage_3_tower_done)
   );
//___________________________________________________________________//


endmodule
