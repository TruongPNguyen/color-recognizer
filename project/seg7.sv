module seg7 (bcd, leds);
	input logic [3:0] bcd;
	output logic [6:0] leds;
 	always_comb begin
			case (bcd)
				//			Light: 6543210
				4'b0000: leds = ~7'b0111111; // 0
				4'b0001: leds = ~7'b0000110; // 1
				4'b0010: leds = ~7'b1011011; // 2
				4'b0011: leds = ~7'b1001111; // 3
				4'b0100: leds = ~7'b1100110; // 4
				4'b0101: leds = ~7'b1101101; // 5
				4'b0110: leds = ~7'b1111101; // 6
				4'b0111: leds = ~7'b0000111; // 7
				4'b1000: leds = ~7'b1111111; // 8
				4'b1001: leds = ~7'b1101111; // 9
				4'b1010: leds = 7'b0001000; // 10, A
				4'b1011: leds = 7'b0000011; // 11, B 
				4'b1100: leds = 7'b1000110; // 12, C 
				4'b1101: leds = 7'b0100001; // 13, D
				4'b1110: leds = 7'b0000110; // 14, E
				4'b1111: leds = 7'b0001110; // 15, F
			endcase
	end
endmodule 
 module seg7_testbench();
	logic [3:0] bcd;
	logic [6:0] leds;
	
	seg7 dut(.bcd, .leds);
	
	initial begin
		bcd = 4'b0000;       #10;	
									#10;
		bcd = 4'b0001;       #10;
									#10;	
		bcd = 4'b0010;       #10;	
									#10;
		bcd = 4'b0011;       #10;
									#10;
		bcd = 4'b0100;       #10;	
									#10;
		bcd = 4'b0101;       #10;
									#10;
		bcd = 4'b0110;       #10;	
									#10;
		bcd = 4'b0111;       #10;
									#10;
		bcd = 4'b1000;       #10;	
									#10;
		bcd = 4'b1001;       #10;
									#10;
	   bcd = 4'b1010;       #10;	
									#10;
		bcd = 4'b1011;       #10;
									#10;
		bcd = 4'b1100;       #10;	
									#10;
		bcd = 4'b1101;       #10;
									#10;
		bcd = 4'b1110;       #10;	
									#10;
		bcd = 4'b1111;       #10;	
		
	end	
	
endmodule