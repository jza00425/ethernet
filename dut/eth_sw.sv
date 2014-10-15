
module eth_sw(
	input clk,
	input resetN,
	input [31:0] inDataA,
	input inSopA,
	input inEopA,
	input [31:0] inDataB,
	input inSopA,
	input inEopB,
	output reg [31:0] outDataA,
	output reg outSopA,
	output reg outEopA,
	output reg [31:0] outDataB,
	output reg outSopB,
	output reg outEopB,
	output reg portAStall,
	output reg portBStall
);

parameter PORTA_ADDR = 'hABCD;
parameter PORTB_ADDR = 'hBEEF;

wire fifo_wr_en[2];
wire [33:0] fifo_wr_data[2];
wire [33:0] fifo_rddata[2];
wire fifo_empty[2];
wire fifo_full[2];
reg fifo_rd_en[2];

fifo #(.FIFO_DEPTH(32), .FIFO_WIDTH(34)) inA_queue(
	.clk(clk),
	.resetN(resetN),
	.write_en(fifo_wr_en[0]),
	.read_en(fifo_rd_en[0]),
	.data_in(fifo_wr_data[0]),
	.data_out(fifo_rddata[0]),
	.empty(fifo_empty[0]),
	.full(fifo_full[0])
);

fifo #(.FIFO_DEPTH(32), .FIFO_WIDTH(34)) inB_queue(
	.clk(clk),
	.resetN(resetN),
	.write_en(fifo_wr_en[1]),
	.read_en(fifo_rd_en[1]),
	.data_in(fifo_wr_data[1]),
	.data_out(fifo_rddata[1]),
	.empty(fifo_empty[1]),
	.full(fifo_full[1])
);

eth_rcv_fsm portA_rcv_fsm(
	.clk(clk),
	.resetN(resetN),
	.inData(inDataA),
	.inSop(inSopA),
	.inEop(inEopA),
	.outWrEn(fifo_wr_en[0]),
	.outData(fifo_wr_data[0])
);

eth_rcv_fsm portB_rcv_fsm(
	.clk(clk),
	.resetN(resetN),
	.inData(inDataB),
	.inSop(inSopB),
	.inEop(inEopB),
	.outWrEn(fifo_wr_en[1]),
	.outData(fifo_wr_data[1])
);

logic read_fifo_head[2];
logic read_fifo_data[2];
logic port_busy[2];
logic [1:0] dest_port[2];

always_ff @ (posedge clk) begin
	if(!resetN) begin
		for(int i = 0; i < 2; i++) begin
			read_fifo_head[i] = 1'b1;
			read_fifo_data[i] = 1'b0;
			port_busy[i] = 'b0;
			dest_port[i] = 2'b11;	//invalid
		end
		outDataA <= 'x;
		outDataB <= 'x;
		outSopA <= 'b0;
		outSopB <= 'b0;
		outEopA <= 'b0;
		outEopB <= 'b0;
	end else begin
		outSopA <= 'b0;
		outSopB <= 'b0;
		outEopA <= 'b0;
		outEopB <= 'b0;
		for(int i = 0; i < 2; i++) begin
			if(read_fifo_head[i] && ~fifo_empty[i]) begin
				fifo_rd_en[i] <= 1'b1;
				read_fifo_head <= 1'b0;
				read_fifo_data <= 1'b1;
			end else if(read_fifo_data[i] && ~fifo_empty[i]) begin
				if(fifo_rddata[i][32]) begin
					dest_port[i] = (fifo_rddata[i][31:0] == PORTB_ADDR) ? 'b01 : 'b00;
					if(port_busy[dest_port[i]]) begin
						fifo_rd_en[i] <= 1'b0;
					end else begin
						fifo_rd_en[i] <= 1'b1;
						port_busy[dest_port[i]] <= 1'b1;
					end
				end else if(fifo_rddata[i][33]) begin
					fifo_rd_en[i] <= 1'b0;
					port_busy[dest_port[i]] <= 1'b0;
					read_fifo_head[i] <= 1'b1;
					read_fifo_data[i] <= 1'b0;
				end else begin
					fifo_rd_en[i] <= 1'b1;
				end

				if(dest_port[i] == 0) begin
					outDataA <= fifo_rddata[i][31:0];
					outSopA <= fifo_rddata[i][32];
					outEopA <= fifo_rddata[i][33];
				end
				if(dest_port[i] == 1) begin
					outDataB <= fifo_rddata[i][31:0];
					outSopB <= fifo_rddata[i][32];
					outEopB <= fifo_rddata[i][33];
				end
			end
		end
	end
end

always_ff @ (posedge clk) begin
	if(resetN == 0) begin
		portAStall <= 0;
		portBStall <= 0;
	end else begin
		portAStall <= fifo_full[0];
		portBStall <= fifo_full[0];
	end
end

endmodule

endmodule





