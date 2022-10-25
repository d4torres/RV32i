module dt1_ID_stage(
	input  		clk,rst,
	//control signals from hazard unit output
	input  		FlushE,
	//control signals from Writeback output
	input  		RegWriteW,
	//data signals from ifid register output
	input  [31:0] 	InstrD,PCD,PCPlus4D,
	//data signals from Writeback output
	input  [31:0]	ResultW,
	input  [4:0]   RdW,
	//ID/IE register outputs
	
	`ifdef RISCV-FORMAL
		output  			rvfi_valid,
		output [63 : 0] 	rvfi_order,
		output [4095 : 0] 	rvfi_insn,
		output  			rvfi_trap,
		output  			rvfi_halt,
		output  			rvfi_intr,
		output [1:0] 		rvfi_mode,
		output [1:0] 		rvfi_ixl,
	`endif
	//to Execute stage
	output  [31:0]	RD1E,RD2E,PCE,ImmExtE,PCPlus4E,
	//to hazard unit
	output  [4:0] 	Rs1E,Rs2E,RdE,
	//to execute stage control
	output 	     	RegWriteE,JumpE,BranchE,ALUBSrcE,PCTargetALUSrcE,
	output  [1:0] 	ResultSrcE,MemWriteE,ALUASrcE,
	output  [2:0] 	LoadSizeE,
	output  [3:0] 	ALUControlE
);
	
	//datapath outputs to ID/IE register input
	wire [31:0]	RD1D,RD2D,ImmExtD;

	//control unit outputs to ID/IE register input
	wire	   	RegWriteD,JumpD,BranchD,ALUBSrcD,PCTargetALUSrcD;
	wire [1:0] ResultSrcD,MemWriteD,ALUASrcD;
	wire [2:0] LoadSizeD;
	wire [3:0] ALUControlD;
	//control unit to extend unit
	wire [2:0] ImmSrcD;
	dt1_control control(
		 //inputs
		.op(InstrD[6:0]),
		.funct3(InstrD[14:12]),
		.funct7b5(InstrD[30]),
		//outputs
		.ResultSrcD(ResultSrcD),
		.ALUControlD(ALUControlD),
		.ImmSrcD(ImmSrcD),
		.ALUASrcD(ALUASrcD),
		.ALUBSrcD(ALUBSrcD),
		.MemWriteD(MemWriteD),
		.RegWriteD(RegWriteD),
		.JumpD(JumpD),
		.BranchD(BranchD),
		.LoadSizeD(LoadSizeD),
		.PCTargetALUSrcD(PCTargetALUSrcD)
		.rvfi_valid
		.rvfi_valid
		.rvfi_valid
		.rvfi_valid
		.rvfi_valid
	);
	dt1_regfile regfile1(
		.clk(clk),
		.we3(RegWriteW),	
		.rst(rst),
		.a1(InstrD[19:15]),
		.a2(InstrD[24:20]),
		.a3(RdW),
		.wd3(ResultW),
		.rd1(RD1D),
		.rd2(RD2D)
	);
	//extend module
	always@(*) begin
		case (ImmSrcD)
			3'b000: ImmExtD = { {20{InstrD[31]}}, InstrD[31:20] }; 				    		     //I-type ALU
			3'b001: ImmExtD = { {20{InstrD[31]}}, InstrD[31:25], InstrD[11:7] }; 		     	 //S-type
			3'b010: ImmExtD = { {20{InstrD[31]}}, InstrD[7], InstrD[30:25], InstrD[11:8], 1'b0};   //B-type
			3'b011: ImmExtD = { {12{InstrD[31]}}, InstrD[19:12], InstrD[20], InstrD[30:21], 1'b0}; //J-type
			3'b100: ImmExtD = { {27{1'b0}}, InstrD[24:20]};						                 //I-type Shift
			3'b101: ImmExtD = { InstrD[31:12] , {12{1'b0}} };//U-type lui
			default:ImmExtD = {32{1'bx}};
		endcase
	end
	//Instruction Decode and Instruction execute register
	always@(posedge clk) begin
		if (rst) {RegWriteE, MemWriteE, JumpE, BranchE, ALUASrcE, ALUBSrcE,
							 ResultSrcE,  ALUControlE, RD1E, RD2E,PCE, ImmExtE, PCPlus4E, RdE, Rs1E, 
							 Rs2E,LoadSizeE,PCTargetALUSrcE} <= 0;
		else if (FlushE) {RegWriteE, MemWriteE, JumpE, BranchE, ALUASrcE, ALUBSrcE,
							 ResultSrcE,  ALUControlE, RD1E, RD2E,PCE, ImmExtE, PCPlus4E, RdE, Rs1E, 
							 Rs2E,LoadSizeE,PCTargetALUSrcE} <= 0;
		else {RegWriteE, MemWriteE, JumpE, BranchE, ALUASrcE,
				ALUBSrcE, ResultSrcE, ALUControlE, 
				RD1E, RD2E,PCE, ImmExtE, PCPlus4E, RdE, Rs1E, Rs2E,LoadSizeE,PCTargetALUSrcE} <= {RegWriteD, MemWriteD, JumpD, BranchD, ALUASrcD, ALUBSrcD, 
																						  ResultSrcD, ALUControlD, RD1D, RD2D, 
																						  PCD, ImmExtD, PCPlus4D, InstrD[11:7], InstrD[19:15], InstrD[24:20],LoadSizeD,PCTargetALUSrcD};
		
	end
endmodule