module dt1_IF_stage(
	input wire 		   clk,
	input wire         rst,
	//control signals from execute 
	input wire  	   PCSrcE,//set PC = PC + 4 or PcC Target
	//control signals fom hazard unit
	//stall signals
	input wire 		   StallF,
	input wire 		   StallD, 
	input wire         FlushD,
	//data signal from Writeback 
	input wire  [31:0] PCTargetE,//next PC if branch or jump taken
	//instruction memory input
	input wire  [31:0] InstrF,//Instruction received from Instruction Memory
	//output to instruction memory
	output wire [31:0] PCF,//PC to receive instruction from Instruction Memory
	//IF/ID Register outputs
	output wire [31:0] InstrD,
	output wire [31:0] PCD,
	output wire [31:0] PCPlus4D //signals required for decode stage
);
	wire [31:0] PCFTick, 
	wire [31:0] PCPlus4F;
	
	//add 4 to PC to fetch next instruction
	assign PCPlus4F = PCF + 32'd4;
	//select PC + 4 or branch/jump address
	assign PCFTick = PCSrcE ? PCTargetE : PCPlus4F;
	//instruction fetch to instruction decode register
	always@(posedge clk) begin
		if (FlushD)       {InstrD, PCD, PCPlus4D} <= 0; 
		else if (rst)     {InstrD, PCD, PCPlus4D} <= 0; 
		else if (!StallD) {InstrD, PCD, PCPlus4D} <= {InstrF, PCF, PCPlus4F};
	end 
	//stall logic
	always@(posedge clk) begin
		if (rst)          PCF <= 0;
		else if (!StallF) PCF <= PCFTick;
	end
endmodule