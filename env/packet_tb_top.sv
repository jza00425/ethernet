//----------------
//top level module
//---------------

`include "packet_tb_env.svh"
`include "eth_sw_if.svh"

import packet_tb_env_pkg::*;

module packet_tb_top;

reg clk;
reg resetN;
wire [31:0] inDataA; //Port A input data, start and end of packet pulses
wire inSopA;
wire inEopA;
wire [31:0] inDataB;
wire inSopB;
wire inEopB;
wire [31:0] outDataA; //output Data and Sop and Eop packet pulses
wire outSopA;
wire outEopA;
wire [31:0] outDataB;
wire outSopB;
wire outEopB;
wire portAStall; //Backpressure or stall signals on portA/B
wire portBStall;

eth_sw eth_sw1(
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

eth_sw_if eth_sw_if1(
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

packet_tb_evn_c packet_tb_env;

always #5 clk = ~clk;

initial begin
	resetN = 0;
	clk = 0;
	repeat(5) @ (posedge clk);

	resetN = 1;

	packet_tb_env = new("ethernet_switch_env", eth_sw_if1);
	$display("created packet tb env");
	fork
		packet_tb_env.run();
	join
end
endmodule
