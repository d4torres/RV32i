module dt1_IE_stage(
	input  			clk,rst,
	//input from ID/IE register output
	
		//data signals
	input  [31:0]	RD1E,RD2E,PCE,ImmExtE,PCPlus4E,
	input  [4:0] 	RdE,
		//control signals
	input 	   		RegWriteE,JumpE,BranchE,ALUBSrcE,PCTargetALUSrcE,
	input  [1:0] 	ResultSrcE,MemWriteE,ALUASrcE,
	input  [2:0] 	LoadSizeE,
	input  [3:0] 	ALUControlE,
	//input from hazard unit
	input  [1:0] 	ForwardAE,ForwardBE,
	//forwarded inputs
	input  [31:0] 	ResultW, 
	
	//connects to fetch stage
	output  [31:0] PCTargetE,
	//connects to fetch stage and hazard unit
	output  		PCSrcE,
	//connects to Data Memory stage
	output 	   	RegWriteM,
	output   [1:0] 	ResultSrcM,
	output   [2:0] 	LoadSizeM,
	output   [31:0] PCPlus4M,
		
	//connects to data memory 
	output  [1:0] 	MemWriteM,
	output  [31:0]	WriteDataM,
	//connects to data memory,data memory stage, and execute stage
	output  [31:0] ALUResultM,
	//connects to data memory and hazard unit
	output  [4:0]  RdM
);
	wire [31:0] SrcAETick,SrcAE,WriteDataE,SrcBE,PCTargetSrcAE, ALUResultE;
	wire 		 BranchCondE;
	assign PCSrcE = (BranchE & BranchCondE) | (JumpE);
	//2 to 1 mux - chooses between sign extended immediate or data from rs2
	assign SrcBE = ALUBSrcE ? ImmExtE : WriteDataE;
	//adder - adds branch offset to PC for B-type instructions
	assign PCTargetE = PCTargetSrcAE + ImmExtE;
	//3 to 1 mux - forwards data from writeback or Memory stage if there is a hazard
	assign SrcAETick = ForwardAE[1] ? ALUResultM : (ForwardAE[0] ? ResultW : RD1E);
	//3 to 1 mux - forwards data from writeback or Memory stage if there is a hazard
	assign WriteDataE = ForwardBE[1] ? ALUResultM : (ForwardBE[0] ? ResultW : RD2E);
	//3 to 1 mux
	assign SrcAE = ALUASrcE[1] ? PCE : (ALUASrcE[0] ? 32'd0 : SrcAETick);  
	//2 to 1 mux
	assign PCTargetSrcAE = PCTargetALUSrcE ? SrcAETick : PCE;
	//Instruction execute to data memory register
	always@(posedge clk) begin
		if(rst) 
			{RegWriteM, MemWriteM, ResultSrcM, ALUResultM, WriteDataM, PCPlus4M, RdM, LoadSizeM} <= 0;
		
		else 
			{RegWriteM, MemWriteM, ResultSrcM, 
			 ALUResultM, WriteDataM, PCPlus4M, RdM, LoadSizeM} <= {RegWriteE, MemWriteE, ResultSrcE, 
													    ALUResultE, WriteDataE, PCPlus4E, RdE, LoadSizeE};
		
	end
	dt1_alu #(.WIDTH(32)) alu1(//performs arithmetic calculations of instruction
		.a(SrcAE),
		.b(SrcBE), 
		.control(ALUControlE), 
		.y(ALUResultE),
		.BranchCond(BranchCondE) 
	);
	
endmodule
