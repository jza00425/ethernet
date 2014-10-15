module eth_rcv_fsm(
	input clk,
	input resetN,
	input [31:0] inData,
	input inSop,
	input inEop,
	output reg outWrEn,
	output reg [33:0] outData	//bit 32 indicating start, bit 33 indicating end
);

parameter PORTA_ADDR = 'hABCD;
parameter PORTB_ADDR = 'hBEEF;

enum {IDLE, DEST_ADDR_RCVD, DATA_RCV, DONE} nState, pState;

logic [31:0] dest_addr;
logic [31:0] src_addr;
logic [33:0] data_word;
logic inSop_d;
logic inEop_d;
logic [31:0] inData_d;

always @ (*) begin
	nState = IDLE;
	case(pState)
		IDLE: begin
			if(inSop == 1) begin
				dest_addr = inData;
				nState = DEST_ADDR_RCVD;
			end else begin
				nState = IDLE;
			end
		end
		DEST_ADDR_RCVD:	begin
			scr_addr = inData;
			nState = DATA_RCV;
		end
		DATA_RCV: begin
			if(inEop) begin
				nState = DONE;
			end else begin
				nState = DATA_RCV;
			end
		DONE: begin
			nState = IDLE;
		end
	endcase
end

always_ff @(posedge clk) begin
	pState <= nState;
	inSop_d <= inSop;
	inEop_d <= inEop;
	inData_d <= inData;
end

always_ff @ (posedge clk) begin
	if(!resetN) begin
		outWrEn <= 1'b0;
	end else if(pState != IDLE) begin
		outWrEn <= 1'b1;
		outData <= {inEop_d, inSop_d, inData_d};
	end else begin
		outWrEn <= 1'b0;
	end
end

endmodule





