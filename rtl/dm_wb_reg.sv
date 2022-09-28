module dm_wb_reg(
	input  logic 		clk, rst,
	//CONTROL SIGNALS
	input  logic 		RegWriteM, 	
	input  logic  [1:0] ResultSrcM,
	output logic 		RegWriteW, 	
	output logic  [1:0] ResultSrcW,
	
	//
	input  logic  [31:0] ALUResultM, ReadDataM, PCPlus4M,
	input  logic  [11:7] RdM,
	output logic  [31:0] ALUResultW, ReadDataW, PCPlus4W,
	output logic  [11:7] RdW
);
	always_ff @(posedge clk) begin
		if(rst){ALUResultW, ReadDataW, PCPlus4W, RdW,RegWriteW, ResultSrcW} <= 0;
		else {ALUResultW, ReadDataW, PCPlus4W, RdW,RegWriteW, ResultSrcW} <= {ALUResultM, ReadDataM, PCPlus4M, RdM,RegWriteM, ResultSrcM};
	end
endmodule