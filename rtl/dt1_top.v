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
	input  wire        clk, 
	input  wire        rst,
	input  wire [31:0] InstrF,
	
	input  wire [31:0] ReadDataMTick,
	
	output reg  [31:0] PCF, 
	output reg [31:0] ALUResultM, 
	output reg [31:0] WriteDataM,
	output reg [1:0]  MemWriteM
);
	/*****************************************/
	/* PARAMETER, REG, AND WIRE DECLARATIONS */
	/*****************************************/
	localparam OPCODE_LOAD  			= 7'b0000011;
	localparam OPCODE_STORE 			= 7'b0100011;
	localparam OPCODE_R-TYPE 			= 7'b0110011;
	localparam OPCODE_I-TYPE 			= 7'b0010011;
	localparam OPCODE_BRANCH 			= 7'b1100011;
	localparam OPCODE_JAL 				= 7'b1101111;
	localparam OPCODE_LUI 				= 7'b0110111;
	localparam OPCODE_AUIPC 			= 7'b0010111;
	localparam OPCODE_JALR 				= 7'b1100111;
	localparam OPCODE_RESET 			= 7'b0000000;
	localparam FUNCT3_LB				= 3'b000;
	localparam FUNCT3_SB				= 3'b000;
	localparam FUNCT3_SUB_ADD_ADDI		= 3'b000;
	localparam FUNCT3_ADDI		        = 3'b000;
	localparam FUNCT3_BEQ				= 3'b000;
	localparam FUNCT3_SLL				= 3'b001;
	localparam FUNCT3_BNE				= 3'b001;
	localparam FUNCT3_LH	 			= 3'b001;
	localparam FUNCT3_SH	 			= 3'b001;
	localparam FUNCT3_SLL_SLLI	 	    = 3'b001;
	localparam FUNCT3_SW        		= 3'b010;
	localparam FUNCT3_LW        		= 3'b010;
	localparam FUNCT3_SLTI        		= 3'b010;
	localparam FUNCT3_SLT_SLTI          = 3'b010;
	localparam FUNCT3_XORI	        	= 3'b100;
	localparam FUNCT3_LBU        		= 3'b100;
	localparam FUNCT3_BLT        		= 3'b100;
	localparam FUNCT3_XOR_XORI        	= 3'b100;
	localparam FUNCT3_SLTU_SLTIU	    = 3'b011;
	localparam FUNCT3_SLTIU	        	= 3'b011;
	localparam FUNCT3_BGE     			= 3'b101;
	localparam FUNCT3_LHU     			= 3'b101;
	localparam FUNCT3_SRLI	         	= 3'b101;
	localparam FUNCT3_SRAI				= 3'b101;
	localparam FUNCT3_SRA_SRL_SRLI_SRAI	= 3'b101;
	localparam FUNCT3_SRAI_SRLI			= 3'b101;
	localparam FUNCT3_ORI				= 3'b110;
	localparam FUNCT3_OR_ORI			= 3'b110;
	localparam FUNCT3_BLTU				= 3'b110;
	localparam FUNCT3_ANDI				= 3'b111;
	localparam FUNCT3_AND_ANDI			= 3'b111;
	localparam FUNCT3_BGEU			    = 3'b111;
	localparam ALUOPCODE_I-LOAD_S_U		= 2'b00
	localparam ALUOPCODE_B				= 2'b01
	localparam ALUOPCODE_R_I			= 2'b10
	localparam IMM_I-ALU 				= 3'b000;
	localparam IMM_I-SHIFT 				= 3'b100;
	localparam IMM_S 					= 3'b001;
	localparam IMM_B 					= 3'b010;
	localparam IMM_J 					= 3'b100;
	localparam IMM_LUI 					= 3'b101;
	localparam ALUCONTROL_ADD_ADDI_U_LOAD_S_JALR_J				 = 4'b0000;
	localparam ALUCONTROL_SUB_BEQ								 = 4'b0001;
	localparam ALUCONTROL_AND_ANDI								 = 4'b0010;
	localparam ALUCONTROL_OR_ORI								 = 4'b0011;
	localparam ALUCONTROL_SLL_SLLI								 = 4'b0100;
	localparam ALUCONTROL_SLT_SLTI_BLT							 = 4'b0101;
	localparam ALUCONTROL_SLTU_SLTIU_BLTU						 = 4'b0110;
	localparam ALUCONTROL_XOR_XORI								 = 4'b0111;
	localparam ALUCONTROL_SRA_SRAI								 = 4'b1000;
	localparam ALUCONTROL_SRL_SRLI								 = 4'b1001;
	localparam ALUCONTROL_BGE									 = 4'b1010;
	localparam ALUCONTROL_BGEU									 = 4'b1011;
	localparam ALUCONTROL_BNE									 = 4'b1100;
	//fetch connections
	reg [31:0]  InstrD;
	//decode connections
	reg [31:0] ImmExtD,ImmExtE;
	wire [4:0]  Rs1D;
	wire [4:0]  Rs2D;
	wire [31:0] RD1D;
	wire [31:0] RD2D;
	reg [4:0]  Rs1E;
	reg [4:0]  Rs2E;
	reg [31:0] RD1E;
	reg [31:0] RD2E;
	assign Rs1D = InstrD[19:15];
	assign Rs2D = InstrD[24:20];	
	//execute connections
	wire [31:0] SrcAETick;
	wire [31:0] SrcAE,SrcBE;
	wire [31:0] WriteDataE;
	reg [31:0]  ALUResultE;
	reg		    BranchCondE;
	//data memory
	reg [31:0] ReadDataM;
	reg [31:0] ALUResultW;
	reg [31:0] ReadDataW;
	//writeback
	wire [31:0] ResultW;
	/*******************/
	/* Control Signals */
	/*******************/
	reg	       RegWriteD, RegWriteE, RegWriteM, RegWriteW;
	reg [1:0]  ResultSrcD, ResultSrcE, ResultSrcM, ResultSrcW;
	reg [2:0]  LoadSizeD, LoadSizeE, LoadSizeM;
	reg [1:0]  MemWriteD, MemWriteE;
	reg 	   JumpD, JumpE;
	reg        BranchD, BranchE;
	reg [3:0]  ALUControlD, ALUControlE;
	reg [1:0]  ALUASrcD, ALUASrcE;
	reg        ALUBSrcD, ALUBSrcE;
	reg        PCTargetALUSrcD, PCTargetALUSrcE;
	reg [2:0]  ImmSrcD;
	wire 	   PCSrcE;
	/***********************/
	/* Hazard Unit Signals */
	/***********************/
	reg  		StallF;
	reg  		StallD;
	wire 		FlushD;
	wire 		FlushE;
	reg [1:0]   ForwardAE;
	reg [1:0]   ForwardBE;
	wire        ResultSrcEb0;
	assign      ResultSrcEb0 = ResultSrcE[0];
	wire [4:0]  RdD;
	assign      RdD = InstrD[11:7];
	reg [4:0]   RdE, RdM, RdW;
	/***********************/
	/* PC signals */
	/***********************/
	wire  [31:0]   PCFTick;
	reg   [31:0]   PCD, PCE;
	wire  [31:0]   PCPlus4F; 
	reg   [31:0]   PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W;
	wire  [31:0]   PCTargetSrcAE, PCTargetE;
	//
	/*****************************/
	/* instruction fetch stage   */
	/*****************************/
	//add 4 to PC to fetch next instruction
	assign PCPlus4F = PCF + 32'd4;
	//select PC + 4 or branch/jump address
	assign PCFTick = PCSrcE ? PCTargetE : PCPlus4F;
	//instruction fetch to instruction decode register
	always@(posedge clk) begin
		if 		(FlushD)  {InstrD, PCD, PCPlus4D} <= 0; 
		else if (rst)     {InstrD, PCD, PCPlus4D} <= 0; 
		else if (!StallD) {InstrD, PCD, PCPlus4D} <= {InstrF, PCF, PCPlus4F};
	end 
	//stall logic
	always@(posedge clk) begin
		if 		(rst)     PCF <= 0;
		else if (!StallF) PCF <= PCFTick;
	end
	/****************************/
	/* instruction decode stage */
	/****************************/
	//datapath outputs to ID/IE register input

	
	
	//control
	wire [1:0] ALUOp;	
	
	/******************************************/
	reg [18:0] controls;
	wire [6:0] op;
	wire       funct7b5;
	wire [2:0] funct3;
    assign op = InstrD[6:0];
    assign funct7b5 = InstrD[30];
	assign funct3 = InstrD[14:12];

	always@(*) begin
		{RegWriteD, ImmSrcD, ALUASrcD, ALUBSrcD, 
		MemWriteD, ResultSrcD, BranchD, ALUOp, 
		JumpD, LoadSizeD,PCTargetALUSrcD} = controls;
	end
	
	always@(*) begin
		case (op)
			OPCODE_LOAD: case(funct3)
							FUNCT3_LB:        controls = 19'b1_000_00_1_00_01_0_00_0_001_0;	
							FUNCT3_LH:        controls = 19'b1_000_00_1_00_01_0_00_0_011_0;	
							FUNCT3_LW:        controls = 19'b1_000_00_1_00_01_0_00_0_000_0;
							FUNCT3_LBU:       controls = 19'b1_000_00_1_00_01_0_00_0_010_0;	
							FUNCT3_LHU:       controls = 19'b1_000_00_1_00_01_0_00_0_100_0;
							default:    	  controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;   //?
						 endcase
			OPCODE_STORE: case(funct3)
							FUNCT3_SB:        controls = 19'b0_001_00_1_11_00_0_00_0_000_0;	
							FUNCT3_SH:        controls = 19'b0_001_00_1_10_00_0_00_0_000_0;	
							FUNCT3_SW:        controls = 19'b0_001_00_1_01_00_0_00_0_000_0;	
							default:          controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;   //?
						  endcase
			OPCODE_R-TYPE: 			          controls = 19'b1_000_00_0_00_00_0_10_0_000_0;	
			OPCODE_BRANCH: 			          controls = 19'b0_010_00_0_00_00_1_01_0_000_0;	
			OPCODE_I-TYPE: case (funct3)
							FUNCT3_ADDI,
							FUNCT3_SLTI,
							FUNCT3_SLTIU,
							FUNCT3_XORI,
							FUNCT3_ORI,
							FUNCT3_ANDI:      controls = 19'b1_000_00_1_00_00_0_10_0_000_0;	
							FUNCT3_SLLI,
							FUNCT3_SRAI_SRLI: controls = 19'b1_100_00_1_00_00_0_10_0_000_0;	
							default			: controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;   //?
						endcase											
			OPCODE_JAL: 					  controls = 19'b1_011_00_0_00_10_0_00_1_000_0; 
			OPCODE_LUI: 					  controls = 19'b1_101_01_1_00_00_0_00_0_000_0;  
			OPCODE_AUIPC: 					  controls = 19'b1_101_10_1_00_00_0_00_0_000_0; 
			OPCODE_JALR: 					  controls = 19'b1_000_00_1_00_10_0_00_1_000_1; 
			OPCODE_RESET: 					  controls = 19'b0_000_00_0_00_00_0_00_0_000_0;
			default: 						  controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;   //?
		endcase

	end
	wire RtypeSub,ItypeSub;
	assign RtypeSub = op[5] & funct7b5;		
	assign ItypeSub = ~op[5] & funct7b5;
	always@(*) begin
		case (ALUOp)
			ALUOPCODE_I-LOAD_S_U_JAL_JALR: 		            						    ALUControlD = 4'b0000; 
			ALUOPCODE_B:    case (funct3)														
								FUNCT3_BEQ:     										ALUControlD = 4'b0001; 
								FUNCT3_BNE:  			     							ALUControlD = 4'b1100; 
								FUNCT3_BLT: 			    							ALUControlD = 4'b0101; 
								FUNCT3_BGE:				     							ALUControlD = 4'b1010; 
								FUNCT3_BLTU: 		         							ALUControlD = 4'b0110; 
								FUNCT3_BGEU:											ALUControlD = 4'b1011; 
								default: 			     	    						ALUControlD = 4'bxxxx; //unknown
							endcase		
			ALUOPCODE_R_I:  case (funct3)													
								FUNCT3_SUB_ADD_ADDI:		if (RtypeSub)       		ALUControlD = 4'b0001; 
															else 		     			ALUControlD = 4'b0000; 
								FUNCT3_SLL_SLLI:  			     						ALUControlD = 4'b0100; 
								FUNCT3_SLT_SLTI: 			    						ALUControlD = 4'b0101; 
								FUNCT3_SLTU_SLTIU:				     					ALUControlD = 4'b0110; 
								FUNCT3_XOR_XORI: 		         						ALUControlD = 4'b0111; 
								FUNCT3_SRA_SRL_SRLI_SRAI:	if (RtypeSub | ItypeSub)    ALUControlD = 4'b1000; 
															else		     			ALUControlD = 4'b1001; 
								FUNCT3_OR_ORI: 			     							ALUControlD = 4'b0011; 
								FUNCT3_AND_ANDI: 			     						ALUControlD = 4'b0010; 
								default: 			     								ALUControlD = 4'bxxxx; //unknown
						    endcase
			default:  			     			            							ALUControlD = 4'bxxxx; //unknown
		endcase
	end
	/*******************************************/

	/*******************************************/
	integer 			    i;
	reg       [31:0] rf[31:0];  
	wire [4:0]				a1,
	wire [4:0] 				a2;
	
	assign a1 = InstrD[19:15];
	assign a2 = InstrD[24:20];
	// three ported register file
	// read two ports combinationally (A1/RD1, A2/RD2)
	// write third port on rising edge of clock (A3/WD3/WE3)
	// register 0 hardwired to 0
	
	always@(negedge clk) begin
		if (rst) begin
			for (i = 0; i < 32; i = i + 1) rf[i] <= 32'd0;
		end
		else if (RegWriteW) begin
			rf[RdW] <= ResultW;
		end
	end
	assign RD1D = (a1 != 0) ? rf[a1] : 0;
	assign RD2D = (a2 != 0) ? rf[a2] : 0;
	//extend module

	always@(*) begin
		case (ImmSrcD)
			IMM_I-ALU:   ImmExtD = { {20{InstrD[31]}}, InstrD[31:20] }; 				    		    
			IMM_S: 		 ImmExtD = { {20{InstrD[31]}}, InstrD[31:25], InstrD[11:7] }; 		     	
			IMM_B: 		 ImmExtD = { {20{InstrD[31]}}, InstrD[7], InstrD[30:25], InstrD[11:8], 1'b0};   
			IMM_J: 		 ImmExtD = { {12{InstrD[31]}}, InstrD[19:12], InstrD[20], InstrD[30:21], 1'b0}; 
			IMM_I-SHIFT: ImmExtD = { {27{1'b0}}, InstrD[24:20]};						                 
			IMM_LUI:     ImmExtD = { InstrD[31:12] , {12{1'b0}} };
			default:     ImmExtD = {32{1'bx}};
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
	/*****************************/
	/* instruction execute stage */
	/*****************************/
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
	//ALU
	always@(*) begin
		case (ALUControlE)
			ALUCONTROL_ADD_ADDI_U_LOAD_S_JALR_J:begin
													ALUResultE = SrcAE + SrcBE;
													BranchCondE = 1'b0;
												end
			ALUCONTROL_SUB_BEQ: 				begin
													ALUResultE = SrcAE - SrcBE;
													if (ALUResultE != 0) BranchCondE = 1'b0;
													else                 BranchCondE = 1'b1;
												end
			ALUCONTROL_AND_ANDI: 				begin
													ALUResultE = SrcAE & SrcBE;
													BranchCondE = 1'b0;
												end
			ALUCONTROL_OR_ORI: 					begin
													ALUResultE = SrcAE | SrcBE;
													BranchCondE = 1'b0;
												end
			ALUCONTROL_SLL_SLLI:				begin 
													ALUResultE = SrcAE << SrcBE;
													BranchCondE = 1'b0;
												end
			ALUCONTROL_SLT_SLTI_BLT: 			begin
													ALUResultE = $signed(SrcAE) < $signed(SrcBE);				
													if (ALUResultE != 0) BranchCondE = 1'b1;
													else   				 BranchCondE = 1'b0;
												end
			ALUCONTROL_SLTU_SLTIU_BLTU:			begin 
													ALUResultE = SrcAE <  SrcBE;			
													if (ALUResultE != 0) BranchCondE = 1'b1;
													else   			     BranchCondE = 1'b0;
												end
			ALUCONTROL_XOR_XORI:  				begin
													ALUResultE = SrcAE ^ SrcBE;
													BranchCondE = 1'b0;
												 end
			ALUCONTROL_SRA_SRAI: 				begin
													ALUResultE = SrcAE >>> SrcBE;
													BranchCondE = 1'b0;
												end
			ALUCONTROL_SRL_SRLI: 				begin
													ALUResultE = SrcAE >> SrcBE;
													BranchCondE = 1'b0;
												 end
			ALUCONTROL_BGE: 					begin
													ALUResultE = $signed(SrcAE) >= $signed(SrcBE);				
													if (ALUResultE != 0) BranchCondE = 1'b1;
													else   				 BranchCondE = 1'b0;
												end
			ALUCONTROL_BGEU:					begin 
													ALUResultE = SrcAE >= SrcBE;				
													if (ALUResultE != 0) BranchCondE = 1'b1;
													else   				 BranchCondE = 1'b0;
												end
			ALUCONTROL_BNE:						begin 									
													ALUResultE = SrcAE - SrcBE;			
													if (ALUResultE != 0) BranchCondE = 1'b1;
													else   				 BranchCondE = 1'b0;
												end
			default:							begin 
													ALUResultE = {32{1'bx}}; //??
													BranchCondE = 1'bx;
												end
		endcase
	end
	/*********************/
	/* data memory stage */
	/*********************/
	// get correct load data size
	localparam WORD = 3'b000;
	localparam BYTE_SIGNED = 3'b001;
	localparam BYTE_UNSIGNED = 3'b010;
	localparam HALF_SIGNED = 3'b011;
	localparam HALF_UNSIGNED = 3'b100;
	always@(*) begin
		case (LoadSizeM)
			WORD:	ReadDataM = ReadDataMTick;
			BYTE_SIGNED:	case(ALUResultM[1:0])
					2'b00: ReadDataM = { {24{ReadDataMTick[7]}}, ReadDataMTick[7:0] };
					2'b01: ReadDataM = { {24{ReadDataMTick[15]}}, ReadDataMTick[15:8] };
					2'b10: ReadDataM = { {24{ReadDataMTick[23]}}, ReadDataMTick[23:16] };
					2'b11: ReadDataM = { {24{ReadDataMTick[31]}}, ReadDataMTick[31:24] };
				endcase
			BYTE_UNSIGNED:	case(ALUResultM[1:0])
					2'b00: ReadDataM = { {24{1'b0}},ReadDataMTick[7:0] };
					2'b01: ReadDataM = { {24{1'b0}},ReadDataMTick[15:8] };
					2'b10: ReadDataM = { {24{1'b0}},ReadDataMTick[23:16] };
					2'b11: ReadDataM = { {24{1'b0}},ReadDataMTick[31:24] };
				endcase
			HALF_SIGNED: case(ALUResultM[1])
					1'b0: ReadDataM = { {16{ReadDataMTick[15]}},ReadDataMTick[15:0] };
					1'b1: ReadDataM = { {16{ReadDataMTick[31]}},ReadDataMTick[31:16] };
				endcase
			HALF_UNSIGNED: case(ALUResultM[1])
					1'b0: ReadDataM = { {16{1'b0}},ReadDataMTick[15:0] };
					1'b1: ReadDataM = { {16{1'b0}},ReadDataMTick[31:16] };
				endcase
			default:ReadDataM = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
		endcase
	end
	//data memory to writeback register
	always@(posedge clk) begin
		if(rst){ALUResultW, ReadDataW, PCPlus4W, RdW,RegWriteW, ResultSrcW} <= 0;
		else {ALUResultW, ReadDataW, PCPlus4W, RdW,RegWriteW, ResultSrcW} <= {ALUResultM, ReadDataM, PCPlus4M, RdM,RegWriteM, ResultSrcM};
	end
	/*********************/
	/* write back stage  */
	/*********************/
	//selects data to write to regfile and to forward to execute stage
	assign ResultW = ResultSrcW[1] ? PCPlus4W : (ResultSrcW[0] ? ReadDataW : ALUResultW);
	/************************/
	/* hazard control unit  */
	/************************/
	//if either source register matches a register we are writing to in a previous 
	//instruction we must forward that value from the previous instruction so the updated
	//value is used.
	always@(*) begin														
		if ( ( (Rs1E == RdM) & RegWriteM ) & (Rs1E != 0) ) ForwardAE =  2'b10;		//Forward from memory stage
		else if ( ( (Rs1E == RdW) & RegWriteW ) & (Rs1E != 0) ) ForwardAE = 2'b01;	//Forward from Writeback stage
		else ForwardAE = 2'b00;														//No Forwarding
		
		if ( ( (Rs2E == RdM) & RegWriteM ) & (Rs2E != 0) ) ForwardBE =  2'b10;
		else if ( ( (Rs2E == RdW) & RegWriteW ) & (Rs2E != 0)) ForwardBE = 2'b01;
		else ForwardBE = 2'b00;
	end
	
	always@(*) begin
		//We must stall if a load instruction is in the execute stage while another instruction has a matching source register to that write register in the decode stage
		if ((ResultSrcEb0 & ((Rs1D == RdE) | (Rs2D == RdE))) ) {StallF, StallD} = 2'b1_1;
		else 											  	   {StallF, StallD} = 2'b0_0;
	end
	
	assign FlushD = PCSrcE ;
	assign FlushE = StallD | PCSrcE;
endmodule