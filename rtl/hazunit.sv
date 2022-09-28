module hazunit(
	//Forwarding
	input logic  [4:0]  Rs1E, Rs2E,
	input logic  [4:0]  RdM, RdW,
	input logic 		RegWriteM, RegWriteW,
	//Stalling
	input logic 		ResultSrcEb0,
	input logic  [4:0] 	Rs1D, Rs2D, RdE,
	//branch control hazard
	input logic 		PCSrcE,
	output logic [1:0]  ForwardAE, ForwardBE,
	output logic 		StallF, StallD, FlushE,
	output logic 		FlushD
	
);
	//if either source register matches a register we are writing to in a previous 
	//instruction we must forward that value from the previous instruction so the updated
	//value is used.
	always_comb begin														
		if ( ( (Rs1E == RdM) & RegWriteM ) & (Rs1E != 0) ) ForwardAE =  2'b10;		//Forward from memory stage
		else if ( ( (Rs1E == RdW) & RegWriteW ) & (Rs1E != 0) ) ForwardAE = 2'b01;	//Forward from Writeback stage
		else ForwardAE = 2'b00;														//No Forwarding
		
		if ( ( (Rs2E == RdM) & RegWriteM ) & (Rs2E != 0) ) ForwardBE =  2'b10;
		else if ( ( (Rs2E == RdW) & RegWriteW ) & (Rs2E != 0)) ForwardBE = 2'b01;
		else ForwardBE = 2'b00;
	end
	
	always_comb begin
		//We must stall if a load instruction is in the execute stage while another instruction has a matching source register to that write register in the decode stage
		if ((ResultSrcEb0 & ((Rs1D == RdE) | (Rs2D == RdE))) ) {StallF, StallD} = 2'b1_1;
		else 											  	   {StallF, StallD} = 2'b0_0;
	end
	
	assign FlushD = PCSrcE ;
	assign FlushE = StallD | PCSrcE;
endmodule 