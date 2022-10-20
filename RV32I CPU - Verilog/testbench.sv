module testbench();

	logic clk;
	logic rst;
	logic[31:0] WriteData, DataAdr;
	logic MemWrite;
	
	top dut(
		.clk(clk),
		.rst(rst),
		.WriteData(WriteData),
		.DataAdr(DataAdr),
		.MemWrite(MemWrite)
	);
	
	initial begin
		rst <= 1; #22; rst <= 0;
	end
	
	always begin
		clk <= 1; #5; clk <= 0; #5;
	end
	
	always@(negedge clk)begin
		if(MemWrite) begin
			if (DataAdr === 100 & WriteData === 25) begin
				$display("Simulation Succeeded");
				$stop;
			end else if (DataAdr !== 96) begin
				$display("Simulation failed");
				$stop;
			end
		end
	end
	
endmodule