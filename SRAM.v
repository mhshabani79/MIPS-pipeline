
module SRAM(CLK, RST, SRAM_WE_N, SRAM_ADDR, SRAM_DQ0, SRAM_DQ1);
	input CLK, RST, SRAM_WE_N;
	input [16:0]SRAM_ADDR;
	inout [31:0]SRAM_DQ0,SRAM_DQ1;

	reg [31:0]memory[0:100];
	
	assign #30 SRAM_DQ0 = SRAM_WE_N ? memory[{SRAM_ADDR[16:1],1'b0}] : 32'bz;
	assign #60 SRAM_DQ1 = SRAM_WE_N ? memory[{SRAM_ADDR[16:1],1'b1}] : 32'bz;	
	always@(posedge CLK) begin
		if(~SRAM_WE_N) begin
			memory[SRAM_ADDR] = SRAM_DQ0;
		end
	end
endmodule
