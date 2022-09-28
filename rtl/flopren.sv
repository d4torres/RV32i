module flopren#(parameter WIDTH)(
	input  logic  [WIDTH-1:0] d,
	input  logic  			  clk, rst, en,
	output logic  [WIDTH-1:0] q
);
	always_ff @(posedge clk or posedge rst) begin
		if (rst) q <= 0;
		else if (en) q <= d;
	end
endmodule