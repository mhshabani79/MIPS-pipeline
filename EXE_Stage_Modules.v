module ALU(in1, in2, exe_cmd, c_in, result, status);
	input signed[31:0]in1,in2;
	input [3:0]exe_cmd;
	input  c_in;
	output reg signed[31:0]result;
	output [3:0]status;
//
	wire signed [31:0]c_in2,c_in3;
	assign c_in2={31'b0,c_in};
	assign c_in3={31'b0,~c_in};

	wire n,z;
	reg c,v;
	assign status = {n,z,c,v};
	
	always@(*) begin
		c=1'b0;
		case(exe_cmd)
			4'b0001: {result} = in2; //mov
			4'b1001: {result} = ~in2; //mvn
			4'b0010: {c,result} = in1 + in2; //add,ldr,str
			4'b0011: {c,result} = in1 + in2 + c_in2; //adc
			4'b0100: {c,result} = in1 - in2; //sub,cmp
			4'b0101: {c,result} = in1 - in2 - c_in3; //sbc
			4'b0110: {result} = in1 & in2; //and,tst
			4'b0111: {result} = in1 | in2; //orr
			4'b1000: {result} = in1 ^ in2; //eor
			default: {c,result} = 33'bz;
		endcase
	end

	assign n = result[31];
	assign z = ~(|result);
	
	always@(*) begin
		v = 1'b0;
		if ((exe_cmd == 4'b0010) | (exe_cmd == 4'b0011)) //add
			v=(result[31] & ~in1[31] & ~in2[31]) | (~result[31] & in1[31] & in2[31]);
		else if ((exe_cmd == 4'b0100) | (exe_cmd == 4'b0101)) //sub
			v=(result[31] & ~in1[31] & in2[31]) | (~result[31] & in1[31] & ~in2[31]);
	end

endmodule

module VAL2_GENERATE(val_rm, shift_operand, imm, mem_flag, val2);
	input [31:0]val_rm;
	input [11:0]shift_operand;
	input imm,mem_flag;
	output reg [31:0]val2;

	wire [3:0]rotate_imm;
	wire [4:0]rotate_imm_val;
	wire [7:0]immed_8;
	wire [31:0]immed_8_extended;
	wire [1:0]shift_mode;
	wire [4:0]shift_imm;

	assign {rotate_imm,immed_8} = shift_operand;
	assign immed_8_extended = {{24{1'b0}},immed_8};
	assign rotate_imm_val = rotate_imm<<1;
	assign shift_mode = shift_operand[6:5];
	assign shift_imm = shift_operand[11:7];

	always@(*) begin
		val2 = 32'bz;
		if (mem_flag)
			val2 = {{20{shift_operand[11]}}, shift_operand};
		else if(imm)
			val2 = {immed_8_extended, immed_8_extended} >> (rotate_imm_val);
		else if (~shift_operand[4]) begin
			case (shift_mode)
				2'b00: val2 = val_rm << shift_imm; //LSL
				2'b01: val2 = val_rm >> shift_imm; //LSR
				2'b10: val2 = val_rm >>> shift_imm; //ASR
				2'b11: val2 = {val_rm,val_rm} >> shift_imm; //ROR
				default: val2 = 32'bz;
			endcase
		end
	end

endmodule

module ADDER32(in0, in1, out);
	input [31:0]in0;
	input [31:0]in1;
	output [31:0]out;

	assign out = in0 + in1;

endmodule
/////
///// forwarding modules
/////
module MUX_ALU1(alu_src1, val_rn, alu_res, wb_value, sel_src1);
	input [31:0]val_rn, alu_res, wb_value;
	output [31:0] alu_src1;
	input [1:0] sel_src1;

	assign alu_src1=(sel_src1==2'b00)? val_rn : (sel_src1==2'b01)? alu_res :(sel_src1==2'b10)? wb_value : val_rn; 
endmodule
///////////
module MUX_ALU2(val2_src, val_rm, alu_res, wb_value, sel_src2);
	input [31:0]val_rm, alu_res, wb_value;
	output [31:0] val2_src;
	input [1:0] sel_src2;

	assign val2_src=(sel_src2==2'b00)? val_rm : (sel_src2==2'b01)? alu_res : (sel_src2==2'b10)? wb_value : val_rm; 
endmodule
