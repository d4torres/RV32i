module floprnen#(parameter WIDTH)(
	input  logic  [WIDTH-1:0] d,
	input  logic  			  clk, rst, nen,
	output logic  [WIDTH-1:0] q
);
	always_ff @(posedge clk) begin
		if (rst) q <= 0;
		else if (!nen) q <= d;
	end
endmodule