


module tb();

reg clk;
reg resetN;
reg [31:0] inDataA;
reg inSopA;
reg inEopA;
reg [31:0] inDataB;
reg inSopB;
reg inEopB;

wire [31:0] outDataA;
wire [31:0] outDataB;
wire outSopA;
wire outEopA;
wire outSopB;
wire outEopB;
wire portAStall;
wire portBStall;





eth_sw switch(
	.clk(clk),
	.resetN(resetN),
	.inDataA(inDataA),
	.inSopA(inSopA),
	.inEopA(inEopA),
	.inDataB(inDataB),
	.inSopB(inSopB),
	.inEopB(inEopB),
	.outDataA(outDataA),
	.outSopA(outSopA),
	.outEopA(outEopA),
	.outDataB(outDataB),
	.outSopB(outSopB),
	.outEopB(outEopB),
	.portAStall(portAStall),
	.portBStall(portBStall)
);

always #10 clk = ~clk;

initial begin
	clk = 0;
	resetN = 0;
	inDataA = 0;
	inSopA = 0;
	inEopA = 0;
	inDataB = 0;
	inSopB = 0;
	inEopB = 0;

	#17 resetN = 1;
	inDataA = 'hABCD;
	inSopA = 1;
	#20 inDataA = 32'h76543210;
	inSopA = 0;
	#20 inDataA = 32'h99999999;
	inEopA = 1;

	#100 resetN = 0;
	#20 $finish;
end

endmodule;



