module dt1_ID_stage(
	`ifdef RISCV-FORMAL
		output reg 			    rvfi_valid_ie,
		output reg [63 : 0] 	rvfi_order_ie,
		output reg [31 : 0] 	rvfi_insn_ie,
		output reg				rvfi_trap_ie,
		output reg				rvfi_halt_ie,
		output reg 			    rvfi_intr_ie,
		output reg [1:0] 		rvfi_mode_ie,
		output reg [1:0] 		rvfi_ixl_ie,
	`endif
	input  wire		    clk,
	input  wire 		rst,
	//control signals from hazard unit output
	input  wire         FlushE,
	//control signals from Writeback output
	input  wire		    RegWriteW,
	//data signals from ifid register output
	input  wire [31:0] 	InstrD,
	input  wire [31:0]	PCD,
	input  wire [31:0]  PCPlus4D
	//data signals from Writeback output
	input  wire [31:0]	ResultW,
	input  wire [4:0]   RdW,
	//ID/IE register outputs
	//to Execute stage
	output wire [31:0]	RD1E,
	output wire [31:0]  RD2E,
	output wire [31:0]  PCE,
	output wire [31:0]  ImmExtE,
	output wire [31:0]  PCPlus4E,
	//to hazard unit
	output wire [4:0] 	Rs1E,
	output wire [4:0]   Rs2E,
	output wire [4:0]   RdE,
	//to execute stage control
	output reg     	    RegWriteE,
	output reg 		    JumpE,
	output reg 		    BranchE,
	output reg 		    ALUBSrcE,
	output reg 		    PCTargetALUSrcE,
	output reg [1:0] 	ResultSrcE,
	output reg [1:0]    MemWriteE,
	output reg [1:0]    ALUASrcE,
	output reg [2:0] 	LoadSizeE,
	output reg [3:0] 	ALUControlE
);
	
	//datapath outputs to ID/IE register input
	wire [31:0]	RD1D;
	wire [31:0] RD2D;
	reg  [31:0] ImmExtD;

	//control unit outputs to ID/IE register input
	wire	    RegWriteD;
	wire 	    JumpD;
	wire        BranchD;
	wire        ALUBSrcD;
	wire        PCTargetALUSrcD;
	wire [1:0]  ResultSrcD;
	wire [1:0]  MemWriteD;
	wire [1:0]  ALUASrcD;
	wire [2:0]  LoadSizeD;
	wire [3:0]  ALUControlD;
	//control unit to extend unit
	wire [2:0] ImmSrcD;
	
	`ifdef RISCV-FORMAL
		wire 			rvfi_valid_id,
		wire [63 : 0] 	rvfi_order_id,
		wire [31 : 0] 	rvfi_insn_id,
		wire			rvfi_trap_id,
		wire			rvfi_halt_id,
		wire 			rvfi_intr_id,
		wire [1:0] 		rvfi_mode_id,
		wire [1:0] 		rvfi_ixl_id,
	`endif
	dt1_control control(
		`ifdef RISCV-FORMAL
			.rvfi_valid_id(rvfi_valid_id),
			.rvfi_order_id(rvfi_order_id),
			.rvfi_insn_id(rvfi_insn_id),
			.rvfi_trap_id(rvfi_trap_id),
			.rvfi_halt_id(rvfi_halt_id),
			.rvfi_intr_id(rvfi_intr_id),
			.rvfi_mode_id(rvfi_mode_id),
			.rvfi_ixl_id(rvfi_ixl_id),
		`endif
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
	);
	dt1_regfile regfile1(
		.clk(clk),
		.we3(RegWriteW),	
		.rst(rst),
		.a1(InstrD[19:15]),
		.a2(InstrD[24:20]),
		.a3(RdW),
		.wd3(ResultW),
		//outputs
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
		if (rst) begin
					{RegWriteE, MemWriteE, JumpE, 
					 BranchE, ALUASrcE, ALUBSrcE,
				     ResultSrcE,  ALUControlE, 
					 RD1E, RD2E,PCE, ImmExtE, PCPlus4E, 
					 RdE, Rs1E, Rs2E,LoadSizeE,PCTargetALUSrcE} <= 0;
					 
				 end
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