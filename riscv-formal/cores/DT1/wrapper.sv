module rvfi_wrapper (
	input         clock,
	input         reset,
	`RVFI_OUTPUTS
);
	wire [31:0] Instr;
	wire [31:0] ReadData;
	wire [31:0] PC;
	wire [31:0] ALUResult;
	wire [31:0] WriteData;
	wire [1:0]  MemWrite;
	dt1  uut (
		.clk       		(clock    ),
		.rst    		(reset    ),
		.InstrF			(Instr    ),
		.ReadDataMTick  (ReadData ),
		.PCF			(PC	      ),
		.ALUResultM		(ALUResult),
		.WriteDataM	    (WriteData),
		.MemWriteM	  	(MemWrite ),
		`RVFI_CONN
	);
	dmem dmem1(
		.clk			(clock    ),
		.we				(MemWrite ),
		.a				(ALUResult),
		.wd				(WriteData),
		.rd				(ReadData )
	);
	imem imem1(
		.a				(PC       ),
		.rd				(Instr    )
	);
endmodule