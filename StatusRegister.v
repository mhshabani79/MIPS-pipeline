module StatusRegister(clk, rst, d, s, q, freeze);
input clk,rst;
input [3:0]d;
input s;
input freeze;
output reg [3:0]q;

	always @(negedge clk or posedge rst) begin
		if (rst)
			q <= {3{1'b0}};
		else if(s & ~freeze)
			q <= d;
	end

endmodule
