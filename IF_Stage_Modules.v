
module PC_REG(pc_out,clk,rst,pc_in,freeze);
	output reg[31:0]pc_out;
	input [31:0]pc_in;
	input clk,rst,freeze;

	always @(posedge clk,posedge rst) begin
		if(rst) pc_out <= 32'b0;
		else if(freeze)
		pc_out <= pc_out;
		else pc_out <= pc_in;
	end
endmodule


module MUX_PC(pc_in,pc4,branch_address,branch_taken);
	output [31:0]pc_in;
	input [31:0]pc4,branch_address;
	input branch_taken;

	assign pc_in = (branch_taken) ? branch_address : pc4;
endmodule


module ADD4(pc4,pc_out);
	output [31:0]pc4;
	input [31:0]pc_out;

	assign pc4 = pc_out + 32'h00000004;
endmodule


module INST_MEM(inst,pc_out);
	output [31:0]inst;
	input [31:0]pc_out;
	reg [31:0]instruction[0:1023];
	
	initial begin
	$readmemb ("instruction.txt",instruction);
	end

	assign inst = instruction[pc_out >> 2];
endmodule
