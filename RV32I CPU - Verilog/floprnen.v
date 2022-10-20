module floprnen#(parameter WIDTH)(
	input    [WIDTH-1:0] d,
	input    			  clk, rst, nen,
	output reg  [WIDTH-1:0] q
);
	always@(posedge clk) begin
		if (rst) q <= 0;
		else if (!nen) q <= d;
	end
endmodule