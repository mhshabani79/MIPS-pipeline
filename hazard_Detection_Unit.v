module hazard_Detection_Unit(hazard_Detected, src1, src2, Exe_Dest, Exe_WB_EN, Mem_Dest, Mem_WB_EN, EXE_CMD, imm, MEM_W_EN,ID_EX_MEM_R_EN,FW);
	output reg hazard_Detected;
	input [3:0]src1, src2, Exe_Dest, Mem_Dest, EXE_CMD;
	input Exe_WB_EN, Mem_WB_EN, imm, MEM_W_EN;
	input ID_EX_MEM_R_EN;
	input FW;
	always @(*) begin
	if(!FW) begin	
		if(Exe_WB_EN & (src1 == Exe_Dest) & (EXE_CMD != 4'b1001) & (EXE_CMD != 4'b0001)) hazard_Detected = 1'b1;
		else if(Mem_WB_EN & (src1 == Mem_Dest) & (EXE_CMD != 4'b1001) & (EXE_CMD != 4'b0001)) hazard_Detected = 1'b1;
		else if(Exe_WB_EN & (src2 == Exe_Dest) & (~imm) & (~MEM_W_EN)) hazard_Detected = 1'b1;
		else if(Mem_WB_EN & (src2 == Mem_Dest) & (~imm) & (~MEM_W_EN)) hazard_Detected = 1'b1;
		else hazard_Detected = 1'b0;
		end
	else if(FW)
		begin
		if ( (ID_EX_MEM_R_EN && ( ((EXE_CMD != 4'b1001) && (EXE_CMD != 4'b0001)) && Exe_Dest == src1) | ( ((~imm) && (~MEM_W_EN)) && Exe_Dest == src2)))  hazard_Detected = 1'b1;
		else hazard_Detected = 1'b0;
		end
	end
endmodule
