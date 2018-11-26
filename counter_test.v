module test(
        input CLOCK_50,
        output counter_done
    );

    reg enable;
    wire [5:0]Q;

    counter_2seconds uu(
            .clk(CLOCK_50), 
            .resetn(1'b0), 
            .enable(enable),
            .out(counter_done),
            .Q(Q)
        );

    always @(posedge CLOCK_50) 
    begin
        if(counter_done == 0)
            enable <= 1;
        
        if(counter_done) begin
            enable <= 0;

        end
    end


endmodule



// Module to separate clock pulses to every 1/60th of a second
module counter_2seconds(clk, resetn, enable, out, Q);
	input clk;
	input resetn;
	input enable;
	output reg out;
	output reg [5:0] Q;

    initial
        out = 0;

	always @(posedge clk) begin
		if (!resetn) begin
			Q <= 0;
			out <= 0;
		end

        if(enable) begin
            if (Q == 6'b111111) begin //10 Million = 2 seconds
                out <= 1;
                Q <= 0;
            end
            else begin
                Q <= Q + 1;
                out <= 0;
            end
        end
        else begin
            Q <= 0;
            out <= 0;
        end

	end
endmodule
