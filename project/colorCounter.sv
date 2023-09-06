module colorCounter(reset, clk, VGA_H_CNT, VGA_V_CNT, VGA_R, VGA_G, VGA_B, redCount, greenCount, redLED, greenLED);
	input logic reset, clk; 
	input logic [12:0] VGA_H_CNT, VGA_V_CNT;			
	input logic	[7:0]	VGA_R, VGA_G, VGA_B;
	output logic [3:0] redCount, greenCount;
	output logic redLED, greenLED;
	
	parameter rowStart = 0;
	parameter rowEnd = 640;
	parameter colStart = 0;
	parameter colEnd = 480;
	parameter redRange = 100;
	parameter greenRange = 150;
	parameter whiteRange = 50; 

	logic [31:0] redPixels;
	logic [31:0] greenPixels;
	logic [31:0] whitePixels;
	logic getColor;
	
	always_ff @(posedge clk)begin 
		if (reset) begin 
			redPixels <= 0; 
	      greenPixels <= 0; 
	      whitePixels <= 0;
			redCount <= 0;
			greenCount <= 0;	
		   getColor <= 0; 	
			redLED <= 0; 
			greenLED <= 0;
		end else if ((VGA_H_CNT > rowStart) && (VGA_H_CNT < rowEnd) && (VGA_V_CNT > colStart) && (VGA_V_CNT < colEnd)) begin  // Check if given pixel is within processed region
			if (VGA_R > (255 - redRange) && VGA_G < (0 + redRange) && VGA_B < (0 + redRange)) begin // If within region, check if the pixel looks something roughly red
				redPixels <= redPixels + 1;
			end 
			if (VGA_R < (0 + greenRange) && VGA_G > (255 - greenRange) && VGA_B < (0 + greenRange)) begin  // If within region, check if the pixel looks something roughly green
				greenPixels <= greenPixels + 1;
			end	
			if (VGA_R > (255 - whiteRange) && VGA_G > (255 - whiteRange) && VGA_B > (255 - whiteRange)) begin // If within region, check if the pixel looks something roughly white
				whitePixels <= whitePixels + 1;
			end				
		end else if ((VGA_H_CNT == 640) && (VGA_V_CNT == 480)) begin // At the end of the frame
			if ((redPixels > ((rowEnd - rowStart) * (colEnd - colStart)) / 3) && getColor) begin // Check if 1/3 or more of the pixels were red within region
				redCount <= (redCount + 1) % 6; 
				redLED <= 1;
				getColor <= 0; 
			end else if ((greenPixels > ((rowEnd - rowStart) * (colEnd - colStart)) / 3) && getColor) begin // Check if 1/3 or more of the pixels were green within region
				greenCount <= (greenCount + 1) % 6;
				greenLED <= 1;
				getColor <= 0; 
			end 
			if ((whitePixels > ((rowEnd - rowStart) * (colEnd - colStart)) / 3)) begin // Check if 1/3 or more of the pixels were white within region
				getColor <= 1;
				redLED <= 0; 
				greenLED <= 0;
			end
			redPixels <= 0; 
			greenPixels <= 0;
			whitePixels <= 0; 
		end
	end
	
endmodule 	

module colorCounter_testbench();
	logic reset, clk; 
	logic [12:0] VGA_H_CNT, VGA_V_CNT;			
	logic	[7:0]	VGA_R, VGA_G, VGA_B;
	logic [3:0] redCount, greenCount;
	logic redLED, greenLED;

	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end 
	
	colorCounter dut(.reset, .clk, .VGA_H_CNT, .VGA_V_CNT, .VGA_R, .VGA_G, .VGA_B, .redCount, .greenCount, 
					.greenLED, .redLED);
	
	integer i;
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; @(posedge clk);
		VGA_R <= 255; VGA_G <= 0; VGA_B <= 0; @(posedge clk);
		for (i = 0; i < 10; i++) begin 
			VGA_H_CNT <= i; VGA_V_CNT <= 0; @(posedge clk);
		end
		for (i = 0; i < 10; i++) begin 
			VGA_H_CNT <= i; VGA_V_CNT <= 1; @(posedge clk);
		end
		for (i = 0; i < 10; i++) begin 
			VGA_H_CNT <= i; VGA_V_CNT <= 3; @(posedge clk);
		end
		for (i = 0; i < 10; i++) begin 
			VGA_H_CNT <= i; VGA_V_CNT <= 4; @(posedge clk);
		end
		for (i = 0; i < 10; i++) begin 
			VGA_H_CNT <= i; VGA_V_CNT <= 5; @(posedge clk);
		end
		$stop(); 
	end
	
endmodule 	
	