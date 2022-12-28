

module TB();
	
	reg clk = 1, rst = 0, FW = 1, clk2 = 1;
//	wire [31:0]SRAM_DQ;
//	wire [16:0]SRAM_ADDR;
//	wire SRAM_WE_N;
	wire [31:0] IF_Inst;


	ARM Arm(
		.clk(clk),
		.clk2(clk2),
		.rst(rst),
		.FW(FW),
		.IF_Inst(IF_Inst)
	);

	integer cycle = 0;
	always #20 cycle = cycle + 1;
	always #10 clk = ~clk;
	always #20 clk2 = ~clk2;

	initial begin
		#5
		rst = 1;
		#30
		rst = 0;

		#10000
		$stop;
	end

endmodule
