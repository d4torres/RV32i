module dt1_top(
//riscv-formal output signals
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
	input  clk, rst,
	input   [31:0] InstrF, ReadDataMTick,
	output [31:0] PCF, ALUResultM, WriteDataM,
	output  [1:0]  MemWriteM
);
	//fetch connections
	wire PCSrcE, StallF, StallD,FlushD;
	wire [31:0] InstrD, PCD, PCPlus4D,PCTargetE;
	//decode connections
	wire 		RegWriteW,FlushE;
	wire [4:0] Rs1E,Rs2E,RdE,RdW;
	wire	   	RegWriteE,JumpE,BranchE,ALUBSrcE,PCTargetALUSrcE;
	wire [1:0] ResultSrcE,MemWriteE,ALUASrcE;
	wire [2:0] LoadSizeE;
	wire [3:0] ALUControlE;
	wire [31:0]RD1E,RD2E,PCE,ImmExtE,PCPlus4E,ResultW;
	//EXECUTE CONNECTIONS
	wire [1:0] ForwardAE, ForwardBE, ResultSrcM;
	wire	   	RegWriteM;
	wire [2:0] LoadSizeM;
	wire [31:0]PCPlus4M;
	wire [4:0] RdM;
	//data memory connections
	wire [1:0] ResultSrcW;
	wire [31:0]ALUResultW, ReadDataW, PCPlus4W;


	rv32i_fetch fetchstage(
		.clk(clk),
		.rst(rst),
		.PCSrcE(PCSrcE),
		.StallF(StallF),
		.StallD(StallD), 
		.FlushD(FlushD),
		.PCTargetE(PCTargetE),
		.InstrF(InstrF),
		.PCF(PCF),
		.InstrD(InstrD),
		.PCD(PCD),
		.PCPlus4D(PCPlus4D)
	);
	rv32i_decode decodestage(
		.clk(clk),
		.rst(rst),
		.FlushE(FlushE),
		.RegWriteW(RegWriteW),
		.InstrD(InstrD),
		.PCD(PCD),
		.PCPlus4D(PCPlus4D),
		.ResultW(ResultW),
		.RdW(RdW),
		.RD1E(RD1E),
		.RD2E(RD2E),
		.PCE(PCE),
		.ImmExtE(ImmExtE),
		.PCPlus4E(PCPlus4E),
		.Rs1E(Rs1E),
		.Rs2E(Rs2E),
		.RdE(RdE),
		.RegWriteE(RegWriteE),
		.JumpE(JumpE),
		.BranchE(BranchE),
		.ALUBSrcE(ALUBSrcE),
		.PCTargetALUSrcE(PCTargetALUSrcE),
		.ResultSrcE(ResultSrcE),
		.MemWriteE(MemWriteE),
		.ALUASrcE(ALUASrcE),
		.LoadSizeE(LoadSizeE),
		.ALUControlE(ALUControlE)
	);
	rv32i_execute executestage(
		.clk(clk),
		.rst(rst),
		.RD1E(RD1E),
		.RD2E(RD2E),
		.PCE(PCE),
		.ImmExtE(ImmExtE),
		.PCPlus4E(PCPlus4E),
		.RdE(RdE),
		.RegWriteE(RegWriteE),
		.JumpE(JumpE),
		.BranchE(BranchE),
		.ALUBSrcE(ALUBSrcE),
		.PCTargetALUSrcE(PCTargetALUSrcE),
		.ResultSrcE(ResultSrcE),
		.MemWriteE(MemWriteE),
		.ALUASrcE(ALUASrcE),
		.LoadSizeE(LoadSizeE),
		.ALUControlE(ALUControlE),
		.ForwardAE(ForwardAE),
		.ForwardBE(ForwardBE),
		.ResultW(ResultW), 
		.PCTargetE(PCTargetE),
		.PCSrcE(PCSrcE),
		.RegWriteM(RegWriteM),
		.ResultSrcM(ResultSrcM),
		.LoadSizeM(LoadSizeM),
		.PCPlus4M(PCPlus4M),
		.MemWriteM(MemWrite),
		.WriteDataM(WriteDataM),
		.ALUResultM(ALUResultM),
		.RdM(RdM)
	);
	rv32i_datamemory datamemorystage(
		.clk(clk),
		.rst(rst),
		.RegWriteM(RegWriteM),
		.ResultSrcM(ResultSrcM),
		.LoadSizeM(LoadSizeM),
		.ALUResultM(ALUResultM), 
		.PCPlus4M(PCPlus4M),
		.RdM(RdM),
		.ReadDataMTick(ReadDataMTick),
		.RegWriteW(RegWriteW),
		.RdW(RdW),
		.ResultSrcW(ResultSrcW),
		.ALUResultW(ALUResultW), 
		.ReadDataW(ReadDataW), 
		.PCPlus4W(PCPlus4W)
	);
	rv32i_writeback writebackstage(
		.ResultSrcW(ResultSrcW),
		.ALUResultW(ALUResultW), 
		.ReadDataW(ReadDataW), 
		.PCPlus4W(PCPlus4W),
		.ResultW(ResultW)
	);
	hazunit hazardunit(
		.Rs1E(Rs1E), 
		.Rs2E(Rs2E),
		.RdM(RdM), 
		.RdW(RdW),
		.RegWriteM(RegWriteM), 
		.RegWriteW(RegWriteW),
		.ResultSrcEb0(ResultSrcE[0]),
		.Rs1D(InstrD[19:15]), 
		.Rs2D(InstrD[24:20]), 
		.RdE(RdE),
		.PCSrcE(PCSrcE),
		.ForwardAE(ForwardAE), 
		.ForwardBE(ForwardBE),
		.StallF(StallF), 
		.StallD(StallD), 
		.FlushE(FlushE),
		.FlushD(FlushD)
	);
endmodule