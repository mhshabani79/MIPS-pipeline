module SRAM_Controller(clk, rst, write_en, read_en, address, writeData, readData, ready, SRAM_DQ0, SRAM_DQ1, SRAM_ADDR, SRAM_WE_N, hit);
	input clk, rst, write_en, read_en;
	input [31:0]address, writeData;
	output [63:0]readData;
	output ready;
	inout [31:0]SRAM_DQ0,SRAM_DQ1;
	output [16:0]SRAM_ADDR;
	output SRAM_WE_N;
	input hit;

	wire [31:0]shifted_addr;
	reg [2:0]count;
	reg sram_write_en, sram_read_en;

	assign shifted_addr = (address - 1024) >> 2;
	assign SRAM_ADDR = shifted_addr[16:0];
	assign SRAM_WE_N = ~sram_write_en;
	assign SRAM_DQ0 = sram_write_en ? writeData : 32'bz;
	assign readData = sram_read_en ? {SRAM_DQ1,SRAM_DQ0} : 64'bz;
	assign ready = ~(count < 6);

	always@(posedge clk) begin
		sram_write_en <= write_en;
		sram_read_en <= read_en;
	end

	always@(posedge clk) begin
		if(read_en | write_en) begin
			if((count == 6) | hit)
				count <= 3'b0;
			else
				count <= count + 3'b1;
		end
		else
			count <= 3'b0;
	end

endmodule
