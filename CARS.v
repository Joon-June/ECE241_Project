module CARS(
//_________________________Inputs_____________________________//
        input clk,
        input resetn,
        
        //________Control Signal__________//
        input stage_1_in_progress,
        input stage_2_in_progress,
        input stage_3_in_progress,
//___________________________________________________________//


//_______________________Outputs_____________________________//
        output car_wren,

        output stage_1_car_done, //It means all cars are destroyed
        output stage_2_car_done,
        output stage_3_car_done,

        //_________VGA Outputs_________//
        output reg [14:0]coord,
        output reg [8:0]colour,

        //Terminal States
        output game_over_feedback
//__________________________________________________________//
);

//___________________Module Instatiations_____________________//
    FrameCounter_30 FC1(.Clock(clk), .resetn(resetn), .Enable30(enable_car_draw[0]));



//____________________________________________________________//


//___________________Wires & Registers_______________________//
	wire [3:0]car_writeEn; //Goes into VGA input
	wire [3:0]enable_car_draw; //From counter
	wire [3:0]game_over; //Output feedback signal
	wire [8:0]colour_car_0, colour_car_1, colour_car_2, colour_car_3; //Output colour from each car
	wire [14:0]coord_car_0, coord_car_1, coord_car_2, coord_car_3; //Output coordinate from each car
    wire car_done_wire;

    assign stage_1_car_done = game_over[3]; // Needs to be updated once lasers
    assign stage_2_car_done = game_over[3]; // Needs to be updated once lasers
    assign stage_3_car_done = game_over[3]; // Needs to be updated once lasers

    assign car_wren = (|car_writeEn); //Unary Opeartor
    assign game_over_feedback = 1'b0/*(|game_over)*/; //Unary Operator
//___________________________________________________________//




//_____________________________Cars_______________________________//
	//Stage 1
    car CAR0(
		//___________Inputs_____________//
        .clk(clk),
		.resetn(resetn),
		.initiate(stage_1_in_progress || stage_2_in_progress || stage_3_in_progress), // beginning of stage
		.car_destroyed(1'b0 | (game_over[0] == 1'b1)), // input from towers
		.enable_draw(enable_car_draw[0]), // begin drawing cycle
		.delay_frames(8'b0), // 1 second @ 30fps

        //___________Outputs_____________//
		.game_over(game_over[0]),
      .car_done(enable_car_draw[1]),
		.vga_WriteEn(car_writeEn[0]), // enables the WriteEn in vga
      .vga_coords(coord_car_0), 
		.vga_colour(colour_car_0)
      //.car_location // for towers
   );
	
	car CAR1(
        //___________Inputs_____________//
		.clk(clk),
		.resetn(resetn),
		.initiate(stage_1_in_progress || stage_2_in_progress || stage_3_in_progress), // beginning of stage
		.car_destroyed(1'b0 | (game_over[1] == 1'b1)), // input from towers
		.enable_draw(enable_car_draw[1]), // begin drawing cycle
		.delay_frames(8'b00011110), // 1 second @ 30fps

        //___________Outputs_____________//
		.game_over(game_over[1]),
      .car_done(enable_car_draw[2]),
		.vga_WriteEn(car_writeEn[1]), // enables the WriteEn in vga
      .vga_coords(coord_car_1), 
		.vga_colour(colour_car_1)
      //.car_location // for towers
   );
	
	car CAR2(
        //___________Inputs_____________//
		.clk(clk),
		.resetn(resetn),
		.initiate(stage_1_in_progress || stage_2_in_progress || stage_3_in_progress), // beginning of stage
		.car_destroyed(1'b0 | (game_over[2] == 1'b1)), // input from towers
		.enable_draw(enable_car_draw[2]), // begin drawing cycle
		.delay_frames(8'b01000000), // 128 frames @ 30fps

        //___________Outputs_____________//
		.game_over(game_over[2]),
      .car_done(enable_car_draw[3]),
		.vga_WriteEn(car_writeEn[2]), // enables the WriteEn in vga
      .vga_coords(coord_car_2), 
		.vga_colour(colour_car_2)
      //.car_location // for towers
   );
	
	car CAR3(
        //___________Inputs_____________//
		.clk(clk),
		.resetn(resetn),
		.initiate(stage_1_in_progress || stage_2_in_progress || stage_3_in_progress), // beginning of stage
		.car_destroyed(1'b0 | (game_over[3] == 1'b1)), // input from towers
		.enable_draw(enable_car_draw[3]), // begin drawing cycle
		.delay_frames(8'b10000000), // 256 frames @ 30fps

        //___________Outputs_____________//
		.game_over(game_over[3]),
      .car_done(car_done_wire),
		.vga_WriteEn(car_writeEn[3]), // enables the WriteEn in vga
      .vga_coords(coord_car_3), 
		.vga_colour(colour_car_3)
      //.car_location // for towers
   );

	
	
/*________________Mux for colours and coords from cars to VGA_____________*/
	always @(*) begin
		if(car_writeEn[0] == 1'b1) begin
			colour = colour_car_0;
			coord = coord_car_0;
		end
		else if(car_writeEn[1] == 1'b1) begin
			colour = colour_car_1;
			coord = coord_car_1;
		end
		else if(car_writeEn[2] == 1'b1) begin
			colour = colour_car_2;
			coord = coord_car_2;
		end
		else if(car_writeEn[3] == 1'b1) begin
			colour = colour_car_3;
			coord = coord_car_3;
		end
		else begin
			colour = 0;
			coord = 0;
		end
	end
endmodule



// Testing module to count 30fps
module FrameCounter_30(Clock, resetn, Enable30); // tested
	input Clock;
	input resetn;
	output reg Enable30;

	reg [20:0] Q;

	always @(posedge Clock) begin
		if (!resetn) begin
			Q <= 0;
			Enable30 <= 0;
		end

		else if (Q >= 21'b110010110111001101010) begin // 30 fps @ 50MHz
			Enable30 <= 1'b1;
			Q <= 0;
		end

		else begin
			Enable30 <= 1'b0;
			Q <= Q + 1;
		end
	end
endmodule