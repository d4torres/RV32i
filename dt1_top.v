`include "macros.vh"
module dt1_top(
//riscv-formal output signals
	`ifdef RISCV_FORMAL
		output reg[`NRET        - 1 : 0] rvfi_valid,
		output reg[`NRET *   64 - 1 : 0] rvfi_order,
		output reg[`NRET * `ILEN - 1 : 0] rvfi_insn,
		output reg[`NRET        - 1 : 0] rvfi_trap,
		output reg[`NRET        - 1 : 0] rvfi_halt,
		output reg[`NRET        - 1 : 0] rvfi_intr,
		output reg[`NRET * 2    - 1 : 0] rvfi_mode,
		output reg[`NRET * 2    - 1 : 0] rvfi_ixl,
		
		output reg[`NRET *    5 - 1 : 0] rvfi_rs1_addr,
		output reg[`NRET *    5 - 1 : 0] rvfi_rs2_addr,
		output reg[`NRET * `XLEN - 1 : 0] rvfi_rs1_rdata,
		output reg[`NRET * `XLEN - 1 : 0] rvfi_rs2_rdata,
		
		output reg[`NRET *    5 - 1 : 0] rvfi_rd_addr,
		output reg[`NRET * `XLEN - 1 : 0] rvfi_rd_wdata,
		
		output reg[`NRET * `XLEN - 1 : 0] rvfi_pc_rdata,
		output reg[`NRET * `XLEN - 1 : 0] rvfi_pc_wdata,
		
		output reg[`NRET * `XLEN   - 1 : 0] rvfi_mem_addr,
		output reg[`NRET * `XLEN/8 - 1 : 0] rvfi_mem_rmask,
		output reg[`NRET * `XLEN/8 - 1 : 0] rvfi_mem_wmask,
		output reg[`NRET * `XLEN   - 1 : 0] rvfi_mem_rdata,
		output reg[`NRET * `XLEN   - 1 : 0] rvfi_mem_wdata,
	`endif
	input  wire        clk, 
	input  wire        rst,
	output reg  [31:0] PCF, 
	output reg [31:0]  ALUResultM, 
	output reg [31:0]  WriteDataM,
	output reg [1:0]   MemWriteM
);
	/*****************************************/
	/* PARAMETER, REG, AND WIRE DECLARATIONS */
	/*****************************************/
	localparam OPCODE_LOAD  			= 7'b0000011;
	localparam OPCODE_STORE 			= 7'b0100011;
	localparam OPCODE_RTYPE 			= 7'b0110011;
	localparam OPCODE_ITYPE 			= 7'b0010011;
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
	localparam FUNCT3_SLLI				= 3'b001;
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
	localparam ALUOPCODE_ILOAD_S_U_JAL_JALR		= 2'b00;
	localparam ALUOPCODE_B				= 2'b01;
	localparam ALUOPCODE_R_I			= 2'b10;
	localparam IMM_IALU 				= 3'b000;
	localparam IMM_ISHIFT 				= 3'b100;
	localparam IMM_S 					= 3'b001;
	localparam IMM_B 					= 3'b010;
	localparam IMM_J 					= 3'b011;
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
	localparam WORD = 3'b000;
	localparam BYTE_SIGNED   = 3'b001;
	localparam BYTE_UNSIGNED = 3'b010;
	localparam HALF_SIGNED   = 3'b011;
	localparam HALF_UNSIGNED = 3'b100;
	localparam NOT_MEM_OP   = 2'b00;
	localparam NO_WRITE     = 2'b00;
	localparam BYTE_MEM_OP  = 2'b01;
	localparam WORD_WRITE   = 2'b01;
	localparam HALF_MEM_OP  = 2'b10;
	localparam HALF_WRITE   = 2'b10;
	localparam WORD_MEM_OP  = 2'b11;
	localparam BYTE_WRITE   = 2'b11;
	
	//fetch connections
	reg [31:0]  InstrD;
	wire [31:0] InstrF;
	//decode connections
	reg [31:0] ImmExtD,ImmExtE;
	wire [4:0] RdD;
	assign      RdD = InstrD[11:7];
	wire [31:0] RD1D;
	wire [31:0] RD2D;
	reg [31:0] RD1E;
	reg [31:0] RD2E;	
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
	reg [31:0] ReadDataMTick;
	//writeback
	wire [31:0] ResultW;
	
	`ifdef DEBUG
	//DEBUGGING
	wire   debug_validD;
	assign debug_validD = debug_valid_maindec & debug_valid_aludec;
	reg    debug_valid_maindec, debug_valid_aludec;
	//valid is high when instruction is decoded and propagates through the pipeline
	//trapD is high when the instruction cannot be decoded in decode stage
	//trapE is high when trapD is high or when there is a datamem or instruction mem misalignment
	reg    debug_trap_maindec,debug_trap_aludec;
	wire   debug_trapD,debug_trapE;
	assign debug_trapD = debug_trap_maindec & debug_trap_aludec;
	//debug in execute stage
	reg debug_insn_half_alignedD,debug_insn_word_aligned_dmemD,debug_insn_word_aligned_imemD;
	//LH,LHU,SH are half aligned
	//LW,SW,Branches and jumps are word aligned
	wire debug_addr_half_aligned, debug_addr_word_aligned_dmem,debug_addr_word_aligned_imem;
	assign debug_addr_half_aligned = ~(ALUResultE[0]);
	//for store and load
	assign debug_addr_word_aligned_dmem = (~(ALUResultE[1]) & ~(ALUResultE[0]));
	//for branch and jump
	assign debug_addr_word_aligned_imem = (~(PCTargetE[1]) & ~(PCTargetE[0]));
	wire debug_mem_violationE;
	assign debug_mem_violationE = (debug_insn_half_alignedE & ~(debug_addr_half_aligned)) | 
								 (debug_insn_word_aligned_dmemE & ~(debug_addr_word_aligned_dmem))
								 |(debug_insn_word_aligned_imemE & ~(debug_addr_word_aligned_imem) & PCSrcE);
	//if PCSrcE is low, the branch is not taken 
	//trapEtick is for unidentified instructions.
	assign debug_trapE = debug_trapEtick | debug_mem_violationE;
	//trap is high when instruction could not be decoded, misaligned read/writes/branch/jump
	wire [31:0] debug_insnD;
	assign debug_insnD = InstrD;
	//
	reg[4:0] debug_rs1_addrD,debug_rs2_addrD,debug_rd_addrD;
	//PC debug
	wire [31:0] debug_rs1_rdata, debug_rs2_rdata;
	assign debug_rs1_rdata = rf[debug_rs1_addrW];
	assign debug_rs2_rdata = rf[debug_rs2_addrW];
	//memory debug
	reg [31:0] debug_mem_addr;
	reg debug_mem_rmaskE,debug_mem_wmaskE;
	reg debug_mem_rdataE,debug_mem_wdataE;
	//used for bitmasl
	wire [1:0] debug_byte_locE;
	assign debug_byte_locE = ALUResultE[1:0];
	wire debug_half_locE;
	assign debug_half_locE = ALUResultE[1];
	//register outputs - no combinational logic
	//execute
	//Memory
	
	//Writeback
	reg    debug_validE,debug_validM,debug_validW;
	reg debug_insn_half_alignedE,debug_insn_word_aligned_dmemE,debug_insn_word_aligned_imemE;
	reg    debug_trapEtick, debug_trapM, debug_trapW;
	reg [31:0] debug_insnE,debug_insnM,debug_insnW;
	reg[4:0] debug_rs1_addrE,debug_rs2_addrE,debug_rd_addrE;
	reg[4:0] debug_rs1_addrM,debug_rs2_addrM,debug_rd_addrM;
	reg[4:0] debug_rs1_addrW,debug_rs2_addrW,debug_rd_addrW;
	reg [31:0] debug_pcM, debug_pcW;
	reg debug_PCSrcM, debug_PCSrcW;
	
	
	
	reg debug_is_loadE,debug_is_loadM,debug_is_loadW;
	reg debug_is_storeE,debug_is_storeM,debug_is_storeW;
	reg [1:0] debug_insn_memtypeE,debug_insn_memtypeM,debug_insn_memtypeW;
	reg debug_mem_violationM, debug_mem_violationW;
	reg [1:0] debug_byte_locM,debug_byte_locW;
	reg  debug_half_locM, debug_half_locW;
	reg [31:0]debug_ReadDataWTick;
	
	always@(posedge clk) begin
		if (rst)
			{debug_validE, debug_insn_half_alignedE,
			debug_insn_word_aligned_dmemE,
			debug_insn_word_aligned_imemE,
			debug_trapEtick, debug_insnE,
			debug_rs1_addrE, debug_rs2_addrE,
			debug_rd_addrE, debug_is_loadE,
			debug_is_storeE, debug_insn_memtypeE} <= 0;
		else
			{debug_validE, debug_insn_half_alignedE,
			debug_insn_word_aligned_dmemE,
			debug_insn_word_aligned_imemE,
			debug_trapEtick, debug_insnE,
			debug_rs1_addrE, debug_rs2_addrE,
			debug_rd_addrE, debug_is_loadE,
			debug_is_storeE, debug_insn_memtypeE}<=	{debug_validD,debug_insn_half_alignedD,
													debug_insn_word_aligned_dmemD,
													debug_insn_word_aligned_imemD,
													debug_trapD,debug_insnD,
													debug_rs1_addrD,debug_rs2_addrD,
													debug_rd_addrD,debug_is_loadD,
													debug_is_storeD,debug_insn_memtypeD};
	end
	always@(posedge clk) begin
		if (rst)
			{debug_validM,debug_trapM,debug_rs1_addrM,
			debug_rs2_addrM, debug_rd_addrM,debug_pcM,
			debug_is_loadM,debug_is_storeM,
			debug_insn_memtypeM,debug_mem_violationM,
			debug_byte_locM,debug_half_locM,debug_PCSrcM} <= 0;
		else
			{debug_validM,debug_insnM,debug_trapM,debug_rs1_addrM,
			debug_rs2_addrM, debug_rd_addrM,debug_pcM,
			debug_is_loadM,debug_is_storeM,
			debug_insn_memtypeM,debug_mem_violationM,
			debug_byte_locM,debug_half_locM,debug_PCSrcM} <=	{debug_validE,debug_insnE,debug_trapE,debug_rs1_addrE,
																debug_rs2_addrE, debug_rd_addrE,PCE,
																debug_is_loadE,debug_is_storeE,
																debug_insn_memtypeE,debug_mem_violationE,
																debug_byte_locE,debug_half_locE,PCSrcE};			
	end
	always@(posedge clk) begin
		if (rst)
			{debug_validW,debug_trapW,debug_insnW,
			debug_rs1_addrW,debug_rs2_addrW,
			debug_rd_addrW,debug_pcW,debug_is_loadW,
			debug_is_storeW,debug_insn_memtypeW,
			debug_mem_violationW,debug_byte_locW,
			debug_half_locW,debug_ReadDataWTick,debug_PCSrcW} <= 0;
		else
			{debug_validW,debug_trapW,debug_insnW,
			debug_rs1_addrW,debug_rs2_addrW,
			debug_rd_addrW,debug_pcW,debug_is_loadW,
			debug_is_storeW,debug_insn_memtypeW,
			debug_mem_violationW,debug_byte_locW,
			debug_half_locW,debug_ReadDataWTick,debug_PCSrcW} <= {debug_validM,debug_trapM,debug_insnM,
													debug_rs1_addrM,debug_rs2_addrM,
													debug_rd_addrM,debug_pcM,debug_is_loadM,
													debug_is_storeM,debug_insn_memtypeM,
													debug_mem_violationM,debug_byte_locM,
													debug_half_locM,ReadDataMTick,debug_PCSrcM};												
	end
	`endif
	`ifdef RISCV_FORMAL
		always@(negedge clk) begin 
			if(rst) rvfi_valid <= 1'b0;
			else    rvfi_valid <= debug_validW;
		end
		always@(posedge clk) begin
			if (rst) begin
				rvfi_insn  <= {32{1'bx}};
				rvfi_trap  <= 1'bx;
				rvfi_mode  <= 2'b11;
				rvfi_ixl   <= 1'b0;
				rvfi_order <= 64'd0;
			end
			else  begin   
				if (rvfi_valid == 1'b1) rvfi_order <= rvfi_order + 64'd1;
				else 					rvfi_order <= rvfi_order;
				rvfi_insn  <= debug_insnW;
				rvfi_trap  <= debug_trapW;
				rvfi_mode  <= 2'b11;
				rvfi_ixl   <= 1'b0;
				rvfi_rs1_addr <= debug_rs1_addrW;
				rvfi_rs2_addr <= debug_rs2_addrW;
				rvfi_rs1_rdata <= debug_rs1_rdata;
				rvfi_rs2_rdata <= debug_rs2_rdata;
				rvfi_rd_addr <= debug_rd_addrW;
				rvfi_rd_wdata <= rf[debug_rd_addrW];
				rvfi_pc_rdata <= debug_pcW;
				if(debug_PCSrcW) rvfi_pc_wdata <= debug_pcM; 
				//if there is a jump, there will be a delay for the next instruction
				else			 rvfi_pc_wdata <= PCD;
				rvfi_mem_addr <= ALUResultW;
				rvfi_mem_rdata <= debug_ReadDataWTick;
				rvfi_mem_wdata <= dmem[ALUResultW];
					case (debug_insn_memtypeW)
						NOT_MEM_OP:	begin	
													rvfi_mem_rmask <= 4'b0000;
													rvfi_mem_wmask <= 4'b0000;
								end		  
						BYTE_MEM_OP:if(debug_is_loadW) begin
										rvfi_mem_wmask <= 4'b0000;
										case(debug_byte_locW)
											2'b00:		rvfi_mem_rmask <= 4'b0001;
											2'b01:		rvfi_mem_rmask <= 4'b0010;
											2'b10:		rvfi_mem_rmask <= 4'b0100;
											2'b11:		rvfi_mem_rmask <= 4'b1000;
											default:	rvfi_mem_rmask <= 4'bxxxx;
										endcase
									end
									else if(debug_is_storeW) begin
										rvfi_mem_rmask <= 4'b0000;
										case(debug_byte_locW)
											2'b00:		rvfi_mem_wmask <= 4'b0001;
											2'b01:		rvfi_mem_wmask <= 4'b0010;
											2'b10:		rvfi_mem_wmask <= 4'b0100;
											2'b11:		rvfi_mem_wmask <= 4'b1000;
											default:	rvfi_mem_wmask <= 4'bxxxx;
										endcase

									end
									else begin 
														rvfi_mem_rmask <= 4'bxxxx;
														rvfi_mem_wmask <= 4'bxxxx;
									end
						HALF_MEM_OP:if(debug_is_loadW) begin
										rvfi_mem_wmask <= 4'b0000;
										if (debug_mem_violationW) rvfi_mem_rmask <= 4'bxxxx;
										else
											case(debug_half_locW)
												1'b0:		rvfi_mem_rmask <= 4'b0011;
												1'b1:		rvfi_mem_rmask <= 4'b1100;
												default:	rvfi_mem_rmask <= 4'bxxxx;
											endcase
									end
									else if(debug_is_storeW) begin
															rvfi_mem_rmask <= 4'b0000;
										if (debug_mem_violationW) rvfi_mem_wmask <= 4'bxxxx;
										else 
											case(debug_half_locW)
												1'b0:		rvfi_mem_wmask <= 4'b0011;
												1'b1:		rvfi_mem_wmask <= 4'b1100;
												default:	rvfi_mem_wmask <= 4'bxxxx;
											endcase
									end
									else begin 
														rvfi_mem_rmask <= 4'bxxxx;
														rvfi_mem_wmask <= 4'bxxxx;
									end
						WORD_MEM_OP:if(debug_is_loadW) begin
										rvfi_mem_wmask <= 4'b0000;
										if (debug_mem_violationW) rvfi_mem_rmask <= 4'bxxxx;
										else 					  rvfi_mem_rmask <= 4'b1111;
									end
									else if(debug_is_storeW) begin
										rvfi_mem_rmask <= 4'b0000;
										if (debug_mem_violationW) rvfi_mem_wmask <= 4'bxxxx;
										else 					  rvfi_mem_wmask <= 4'b1111;
										
									end
									else begin 
														rvfi_mem_rmask <= 4'bxxxx;
														rvfi_mem_wmask <= 4'bxxxx;
									end
						default:begin
									rvfi_mem_rmask <= 4'bxxxx;
									rvfi_mem_wmask <= 4'bxxxx;
								end
					endcase
			end								
		end
	`endif
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
	wire [4:0]  Rs1D,Rs2D;
	assign      Rs1D = InstrD[19:15];
	assign      Rs2D = InstrD[24:20];
	reg [4:0]  Rs1E;
	reg [4:0]  Rs2E;
	reg [4:0]   RdE, RdM, RdW;
	/***********************/
	/* PC signals */
	/***********************/
	wire  [31:0]   PCFTick;
	reg   [31:0]   PCD, PCE;
	wire  [31:0]   PCPlus4F; 
	reg   [31:0]   PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W;
	wire  [31:0]   PCTargetSrcAE, PCTargetE;
	/**********************************/
	/* instruction memory interface   */
	/**********************************/
	reg [31:0] imem [63:0];
	
	initial $readmemh("C:/Users/david/Desktop/RV32I CPU - Verilog/riscvtest.txt",imem);
	
	assign InstrF = imem[PCF[31:2]];	
    /*********************************/
	/* data memory interface   *******/
	/*********************************/
	reg [31:0] dmem[63:0];
	always@(*) ReadDataMTick = dmem[ALUResultM[31:2]]; //read
	always@(posedge clk) begin//write
		case(MemWriteM)
			NO_WRITE: begin end
			WORD_WRITE: dmem[ALUResultM[31:2]]<= WriteDataM[31:0];
			HALF_WRITE: case(ALUResultM[1])
						1'b0:dmem[ALUResultM[31:2]][15:0]<= WriteDataM[15:0];
						1'b1:dmem[ALUResultM[31:2]][31:16]<= WriteDataM[15:0];
						default: dmem[ALUResultM[31:2]]<= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
				   endcase
			BYTE_WRITE: case(ALUResultM[1:0])
						2'b00:dmem[ALUResultM[31:2]][7:0] <= WriteDataM[7:0];
						2'b01:dmem[ALUResultM[31:2]][15:8] <= WriteDataM[7:0];
						2'b10:dmem[ALUResultM[31:2]][23:16] <= WriteDataM[7:0];
						2'b11:dmem[ALUResultM[31:2]][31:24] <= WriteDataM[7:0];
						default: dmem[ALUResultM[31:2]]<= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
				   endcase 
				   
			default: dmem[ALUResultM[31:2]]    <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
		endcase
	 end
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
	//control
	reg [1:0] ALUOp;	
	
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
							FUNCT3_LB: 			controls = 19'b1_000_00_1_00_01_0_00_0_001_0;
							FUNCT3_LH:  		controls = 19'b1_000_00_1_00_01_0_00_0_011_0;
							FUNCT3_LW: 			controls = 19'b1_000_00_1_00_01_0_00_0_000_0;
							FUNCT3_LBU:     	controls = 19'b1_000_00_1_00_01_0_00_0_010_0;	
							FUNCT3_LHU:     	controls = 19'b1_000_00_1_00_01_0_00_0_100_0;
							default:	    	controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;
						 endcase
			OPCODE_STORE: case(funct3)
							FUNCT3_SB:      	controls = 19'b0_001_00_1_11_00_0_00_0_000_0;	
							FUNCT3_SH:      	controls = 19'b0_001_00_1_10_00_0_00_0_000_0;								
							FUNCT3_SW:      	controls = 19'b0_001_00_1_01_00_0_00_0_000_0;			
							default:  	    	controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;	
						  endcase
			OPCODE_RTYPE: 			        	controls = 19'b1_000_00_0_00_00_0_10_0_000_0;	
			OPCODE_BRANCH: 			        	controls = 19'b0_010_00_0_00_00_1_01_0_000_0;	
			OPCODE_ITYPE: case (funct3)
							FUNCT3_ADDI,
							FUNCT3_SLTI,
							FUNCT3_SLTIU,
							FUNCT3_XORI,
							FUNCT3_ORI,
							FUNCT3_ANDI:    	controls = 19'b1_000_00_1_00_00_0_10_0_000_0;			
							FUNCT3_SLLI,
							FUNCT3_SRAI_SRLI:  	controls = 19'b1_100_00_1_00_00_0_10_0_000_0;
							default:  	  		controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;		
						endcase											
			OPCODE_JAL: 				  		controls = 19'b1_011_00_0_00_10_0_00_1_000_0; 			
			OPCODE_LUI: 				  		controls = 19'b1_101_01_1_00_00_0_00_0_000_0; 			
			OPCODE_AUIPC: 					  	controls = 19'b1_101_10_1_00_00_0_00_0_000_0; 		
			OPCODE_JALR: 					  	controls = 19'b1_000_00_1_00_10_0_00_1_000_1; 		
			OPCODE_RESET: 				  		controls = 19'b0_000_00_0_00_00_0_00_0_000_0;	
			default:    	  
												controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;
		endcase
	end
	
	wire RtypeSub,ItypeSub;
	assign RtypeSub = op[5] & funct7b5;		
	assign ItypeSub = ~op[5] & funct7b5;
	always@(*) begin
		case (ALUOp)
			ALUOPCODE_ILOAD_S_U_JAL_JALR: 		            						ALUControlD = 4'b0000;
			ALUOPCODE_B:    case (funct3)														
								FUNCT3_BEQ:     									ALUControlD = 4'b0001; 
								FUNCT3_BNE:  			     						ALUControlD = 4'b1100; 
								FUNCT3_BLT: 			    						ALUControlD = 4'b0101; 
								FUNCT3_BGE:				     						ALUControlD = 4'b1010; 
								FUNCT3_BLTU: 		         						ALUControlD = 4'b0110; 
								FUNCT3_BGEU:										ALUControlD = 4'b1011; 
								default: 			     	    					ALUControlD = 4'bxxxx;
							endcase		
			ALUOPCODE_R_I:  case (funct3)													
								FUNCT3_SUB_ADD_ADDI:		if (RtypeSub)       	ALUControlD = 4'b0001; 
															else 		     		ALUControlD = 4'b0000;
								FUNCT3_SLL_SLLI:  			     					ALUControlD = 4'b0100; 
								FUNCT3_SLT_SLTI: 			    					ALUControlD = 4'b0101; 
								FUNCT3_SLTU_SLTIU:				     				ALUControlD = 4'b0110;
								FUNCT3_XOR_XORI: 		         					ALUControlD = 4'b0111; 
								FUNCT3_SRA_SRL_SRLI_SRAI:	if (RtypeSub | ItypeSub)ALUControlD = 4'b1000; 
															else		     		ALUControlD = 4'b1001; 
								FUNCT3_OR_ORI: 			     						ALUControlD = 4'b0011; 
								FUNCT3_AND_ANDI: 			     					ALUControlD = 4'b0010; 
								default: 			     	    					ALUControlD = 4'bxxxx;
						    endcase
			default: 			     	    										ALUControlD = 4'bxxxx;
		endcase
	end
	/*******************************************/
	`ifdef DEBUG
	//debug signals
	reg[23:0] debug;
	reg[1:0] debug_alu;
	reg debug_is_loadD,debug_is_storeD;
	//00 for non memory operation,01 for byte load/store, 10 for half,11 for word
	reg [1:0] debug_insn_memtypeD;

		always@(*) begin
			{debug_valid_maindec,debug_trap_maindec,
			 debug_insn_half_alignedD, debug_insn_word_aligned_dmemD,
			 debug_insn_word_aligned_imemD,debug_rs1_addrD,debug_rs2_addrD,
			 debug_rd_addrD,debug_is_loadD,debug_is_storeD,debug_insn_memtypeD} = debug;
		end
		always@(*) begin
			case (op)
				OPCODE_LOAD: case(funct3)
								FUNCT3_LB:  		debug = {5'b1_0_0_0_0, Rs1D,5'b00000,RdD,2'b10,BYTE_MEM_OP};
								FUNCT3_LH: 			debug = {5'b1_0_1_0_0, Rs1D,5'b00000,RdD,2'b10,HALF_MEM_OP};
								FUNCT3_LW:   		debug = {5'b1_0_0_1_0, Rs1D,5'b00000,RdD,2'b10,WORD_MEM_OP};
								FUNCT3_LBU:     	debug = {5'b1_0_0_0_0, Rs1D,5'b00000,RdD,2'b10,BYTE_MEM_OP};
								FUNCT3_LHU:    		debug = {5'b1_0_1_0_0, Rs1D,5'b00000,RdD,2'b10,HALF_MEM_OP};
								default:			debug = {5'b0_1_x_x_x, 5'b00000,5'b00000,5'b00000,4'bxxxx};	
							 endcase
				OPCODE_STORE: case(funct3)
								FUNCT3_SB:  		debug = {5'b1_0_0_0_0, Rs1D,Rs2D,5'b00000,2'b01,BYTE_MEM_OP};
								FUNCT3_SH:     		debug = {5'b1_0_1_0_0, Rs1D,Rs2D,5'b00000,2'b01,HALF_MEM_OP};
								FUNCT3_SW:      	debug = {5'b1_0_0_1_0, Rs1D,Rs2D,5'b00000,2'b01,WORD_MEM_OP};
								default:  	  		debug = {5'b0_1_x_x_x, 5'b00000,5'b00000,5'b00000,4'bxxxx};
							  endcase
				OPCODE_RTYPE: 			    		debug = {5'b1_0_0_0_0, Rs1D,Rs2D,RdD,2'b00,NOT_MEM_OP};
				OPCODE_BRANCH: 			     		debug = {5'b1_0_0_0_1, Rs1D,Rs2D,5'b00000,2'b00,NOT_MEM_OP};
				OPCODE_ITYPE: case (funct3)
								FUNCT3_ADDI,
								FUNCT3_SLTI,
								FUNCT3_SLTIU,
								FUNCT3_XORI,
								FUNCT3_ORI,
								FUNCT3_ANDI:		debug = {5'b1_0_0_0_0, Rs1D,5'b00000,RdD,2'b00,NOT_MEM_OP};
								FUNCT3_SLLI,
								FUNCT3_SRAI_SRLI: 	debug = {5'b1_0_0_0_0, Rs1D,5'b00000,RdD,2'b00,NOT_MEM_OP};
								default:			debug = {5'b0_1_x_x_x, 5'b00000,5'b00000,5'b00000,4'bxxxx};
							endcase											
				OPCODE_JAL: 						debug = {5'b1_0_0_0_1, 5'b00000, 5'b00000,RdD,2'b00,NOT_MEM_OP};
				OPCODE_LUI: 						debug = {5'b1_0_0_0_0, 5'b00000, 5'b00000,RdD,2'b00,NOT_MEM_OP};
				OPCODE_AUIPC: 			  			debug = {5'b1_0_0_0_0, 5'b00000, 5'b00000,RdD,2'b00,NOT_MEM_OP};
				OPCODE_JALR: 						debug = {5'b1_0_0_0_1, Rs1D,5'b00000,RdD,2'b00,NOT_MEM_OP};
				OPCODE_RESET: 			  			debug = {5'b0_1_0_0_0, 5'b00000, 5'b00000,5'b00000,2'b00,NOT_MEM_OP};
				default:    	   					debug = {5'b0_1_x_x_x, 5'b00000,5'b00000,5'b00000,4'bxxxx};
			endcase
		end
		always@(*) {debug_valid_aludec, debug_trap_aludec} = debug_alu;
		always@(*) begin
		case (ALUOp)
			ALUOPCODE_ILOAD_S_U_JAL_JALR: 					debug_alu = 2'b10;
			ALUOPCODE_B:    case (funct3)														
								FUNCT3_BEQ: 				debug_alu = 2'b10;
								FUNCT3_BNE:					debug_alu = 2'b10;
								FUNCT3_BLT: 				debug_alu = 2'b10;
								FUNCT3_BGE:					debug_alu = 2'b10;
								FUNCT3_BLTU:				debug_alu = 2'b10;
								FUNCT3_BGEU:				debug_alu = 2'b10;
								default:					debug_alu = 2'b01;
							endcase		
			ALUOPCODE_R_I:  case (funct3)													
								FUNCT3_SUB_ADD_ADDI:		debug_alu = 2'b10;
								FUNCT3_SLL_SLLI:  			debug_alu = 2'b10;
								FUNCT3_SLT_SLTI: 			debug_alu = 2'b10;
								FUNCT3_SLTU_SLTIU:			debug_alu = 2'b10;
								FUNCT3_XOR_XORI: 			debug_alu = 2'b10;
								FUNCT3_SRA_SRL_SRLI_SRAI:	debug_alu = 2'b10;
								FUNCT3_OR_ORI: 				debug_alu = 2'b10;
								FUNCT3_AND_ANDI:			debug_alu = 2'b10;
								default:					debug_alu = 2'b01;
						    endcase
			default:										debug_alu = 2'b10;
		endcase
	end

	`endif
	/*******************************************/
	integer 			    i;
	reg       [31:0] rf[31:0];  
	wire [4:0]				a1;
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
			IMM_IALU:   ImmExtD = { {20{InstrD[31]}}, InstrD[31:20] }; 				    		    
			IMM_S: 		 ImmExtD = { {20{InstrD[31]}}, InstrD[31:25], InstrD[11:7] }; 		     	
			IMM_B: 		 ImmExtD = { {20{InstrD[31]}}, InstrD[7], InstrD[30:25], InstrD[11:8], 1'b0};   
			IMM_J: 		 ImmExtD = { {12{InstrD[31]}}, InstrD[19:12], InstrD[20], InstrD[30:21], 1'b0}; 
			IMM_ISHIFT: ImmExtD = { {27{1'b0}}, InstrD[24:20]};						                 
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
			  RD1E, RD2E,PCE, ImmExtE, PCPlus4E, 
			  RdE, Rs1E,Rs2E,LoadSizeE,PCTargetALUSrcE} <= {RegWriteD, MemWriteD, JumpD, BranchD, ALUASrcD, 
															ALUBSrcD, ResultSrcD, ALUControlD, 
															RD1D, RD2D, PCD, ImmExtD, PCPlus4D, 
															RdD, Rs1D, Rs2D,LoadSizeD,PCTargetALUSrcD};
		
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