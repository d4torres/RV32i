module dt1_IF_stage(
	input  		clk,rst,
	//control signals from execute 
	input   		PCSrcE,//set PC = PC + 4 or PcC Target
	//control signals fom hazard unit
	input  		StallF,//stall instruction fetch
	input  		StallD, FlushD,//stall and flush decode input
	//data signal from Writeback 
	input   [31:0] PCTargetE,//next PC if branch or jump taken
	//instruction memory input
	input   [31:0] InstrF,//Instruction received from Instruction Memory
	//output to instruction memory
	output  [31:0] PCF,//PC to receive instruction from Instruction Memory
	//IF/ID Register outputs
	output  [31:0] InstrD,PCD,PCPlus4D//signals required for decode stage
);
	wire [31:0] PCFTick, PCPlus4F;
	//adder
	assign PCPlus4F = PCF + 32'd4;
	//2 to 1 mux
	assign PCFTick = PCSrcE ? PCTargetE : PCPlus4F;
	//instruction fetch to instruction decode register
	always@(posedge clk) begin
		if (FlushD)   {InstrD, PCD, PCPlus4D} <= 0; 
		else if (rst) {InstrD, PCD, PCPlus4D} <= 0; 
		else if (!StallD) {InstrD, PCD, PCPlus4D} <= {InstrF, PCF, PCPlus4F};
	end 
	//flip flop with low enable
	always@(posedge clk) begin
		if (rst) PCF <= 0;
		else if (!StallF) PCF <= PCFTick;
	end
endmodule