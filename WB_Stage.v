module WB_Stage(ALU_result, MEM_result, MEM_R_en, out);
input [31:0] ALU_result, MEM_result;
input MEM_R_en;
output [31:0] out;

	assign out = MEM_R_en ? MEM_result : ALU_result;

endmodule 
