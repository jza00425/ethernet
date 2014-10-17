//-----------------
// Define the packet class
//---------------

class eth_packet_c;

	rand bit [31:0] src_addr;
	rand bit [31:0] dst_addr;
	rand byte pkt_data[$];
	bit [31:0] pkt_crc;

	int pkt_size_bytes;
	byte pkt_full[$];

	constraint addr_c {
		src_addr inside {'hABCD, 'hBEEF};
		dst_addr inside {'hABCD, 'hBEEF};
	}

	constraint pkt_data_c {
		pkt_data.size() >= 4;
		pkt_data.size() <= 32;
		pkt_data.szie() % 4 == 0;
	}

	function new()
	endfunction

	function bit[31:0] compute_crc();
		return 'hABCDDEAD;
	endfunction

	function void post_ramdomize();
		pkt_crc = compute_crc();
		pkt_size_bytes = pkt_data.size() + 4 + 4 + 4;	//data bytes + 4 bytes src + 4 bytes dest + 4 bytes crc
		for(int i = 0; i < 4; i++) begin
			pkt_full.push_back(dst_addr >> i * 8);
		end
		for(int i = 0; i < 4; i++) begin
			pkt_full.push_back(src_addr >> i * 8);
		end
		for(int i = 0; i < pkt_data.size(); i++) begin
			pkt_full.push_back(pkt_data[i]);
		end
		for(int i = 0; i < 4; i++) begin
			pkt_full.push_back(pkt_crc >> i * 8);
		end
	endfunction

	function string to_string();	//return a string that print all fields
		string msg;
		msg = $sformatf("sa=%x, da=%x, crc=%x", src_addr, dst_addr, pkt_crc);
		return msg;
	endfunction

	function bit compare_pkt(eth_packet_c pkt);
		if((this.src_addr == pkt.src_addr) &&
		   (this.dst_addr == pkt.dst_addr) &&
		   (this.pkt_crc == pkt.pkt_crc) &&
		   is_data_match(this.pkt_data, pkt.pkt_data)) begin
		   return 1'b1;
	  	 end
		 return 1'b0;
	 endfunction

	 function bit is_data_match(byte data1[], byte data2[]);
		 int cnt1 = data1.size();
		 int cnt2 = data2.size();
		 int cnt3 = 0;
		 if(cnt1 == cnt2) begin
			 for(int i = 0; i < cnt1; i++) begin
				 if(data1[i] == data2[i]) begin
					 cnt3++;
				 end
			 end
			 if(cnt3 == cnt1) begin
				 return 1'b1;
			 end
		 end
		 
		 return 1'b0;

	 endfunction
 endclass: eth_packet_c
