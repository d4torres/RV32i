module dm_wb_reg(
	input   		   clk, rst,
	input   		   RegWriteM,	
	input    [1:0]     ResultSrcM,
	input    [31:0]    ALUResultM, ReadDataM, PCPlus4M,
	input    [11:7]    RdM,
	output reg  [31:0] ALUResultW, ReadDataW, PCPlus4W,
	output reg  [11:7] RdW,
	output reg		   RegWriteW, 	
	output reg  [1:0]  ResultSrcW
);
	always@(posedge clk) begin
		if(rst){ALUResultW, ReadDataW, PCPlus4W, RdW,RegWriteW, ResultSrcW} <= 0;
		else {ALUResultW, ReadDataW, PCPlus4W, RdW,RegWriteW, ResultSrcW} <= {ALUResultM, ReadDataM, PCPlus4M, RdM,RegWriteM, ResultSrcM};
	end
endmodule