//--------------
//package for top level env class
//--------------

package packet_tb_env_pkg;
	`define NUMPORTS 2
	`define PORTA_ADDR 'hABCD
	`define PORTB_ADDR 'hBEEF


	`include "eth_packet.svh"
	`include "eth_packet_gen.svh"
	`include "eth_packet_drv.svh"
	`include "eth_packet_mon.svh"
	`include "eth_packet_chk.svh"

	class packet_tb_env_c;
		string env_name;
		eth_packet_gen_c packet_gen;
		eth_packet_drv_c packet_driver;
		eth_packet_mon_c packet_mon;
		eth_packet_chk_c packet_checker;

		mailbox mbx_gen_drv;

		mailbox mbx_mon_chk[4];

		virtual interface eth_sw_if rtl_intf;

		function new(string name, virtual interface eth_sw_if rtl_intf);
			this.name = name;
			this.rtl_intf = rtl_intf;

			mbx_gen_drv = new();
			packet_gen = new(mbx_gen_drv);
			packet_drive = new(mbx_gen_drv, intf);

			for(int i = 0; i < 4; i++) begin
				mbx_mon_chk[i] = new();
			end

			packet_mon = new(mbx_mon_chk, intf);
			packet_checker = new(mbx_mon_chk);
		endfunction

		task run;
			$display("packet_tb_env::run() called");
			fork
				packet_gen.run();
				packet_driver.run();
				packet_mon.run();
				packet_checker.run();
			join
		endtask
	endclass: packet_tb_env_c
endpackage: packet_tb_env_pkg
