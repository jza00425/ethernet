//-----------------
//packet checker class
//----------------


typedef eth_packet_c;
class eth_packet_chk_c;

	mailbox mbx_in[4];

	eth_packet_c exp_pkt_A_q[$];
	eth_packet_c exp_pkt_B_q[$];

	function new(mailbox mbx[4])
		for(int i = 0; i < 4; i++) begin
			this.mbx_in = mbx;
		end
	endfunction

	task run;
		$display("packet_chk::run() called");
		fork
			get_and_process_pkt(0);
			get_and_process_pkt(1);
			get_and_process_pkt(2);
			get_and_process_pkt(3);
		join_none
	endtask

	task get_and_process_pkt(int port);
		eth_packet_c pkt;
		$display("packet_chk::process_pkt on port=%0d called", port);
		forever begin
			mbx_in[port].get(pkt);
			if(port < 2) begin
				get_exp_packet_q(pkt);
			end else begin
				chk_exp_packet_q(port,pkt);
			end
		end
	endtask


	function void gen_exp_packet_q(eth_packet_c pkt);
		if(pkt.dst_addr == `PORTA_ADDR) begin
			exp_pkt_A_q.push_back(pkt);
		end else if(pkt.dst_addr == `PORTB_ADDR) begin
			exp_pkt_B_q.push_back(pkt);
		end else begin 
			$error("illegal packet received");
		end
	endfunction

	function void chk_exp_packet_q(int port, eth_packet_c pkt);
		eth_packet_c exp;
		if(port == 2) begin
			exp = exp_pkt_A_q.pop_front();
		end else if(port == 3) begin
			exp = exp_pkt_B_q.pop_front();
		end

		if(pkt.compare_pkt(exp)) begin
			$display("packet on port %0d match", port);
		end else begin
			$display("packet on port %0d not match", port);
		end
	endfunction
endclass


