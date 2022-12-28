
module IF_Stage(PC, Instruction, clk, rst, BranchAddr, freeze, Branch_taken);
	output [31:0] PC, Instruction;
	input [31:0] BranchAddr;
	input clk, rst, freeze, Branch_taken;
	
	wire [31:0] pc_out, pc_in, pc4;

	PC_REG  PC_Reg(.pc_out(pc_out), .clk(clk),.rst(rst), .pc_in(pc_in), .freeze(freeze));
	MUX_PC  PC_Mux(.pc_in(pc_in), .pc4(PC), .branch_address(BranchAddr), .branch_taken(Branch_taken));
	ADD4  PC_Adder(.pc4(PC), .pc_out(pc_out));
	INST_MEM  Inst_Mem(.inst(Instruction), .pc_out(pc_out));
endmodule
