module audioSelect(input logic CLOCK_50, reset, 
						 input logic [3:0] redCount, greenCount,
						 input logic redCountAudioRequest, greenCountAudioRequest, redAudioRequest, 
											greenAudioRequest, sampleDoneAck,
						 output logic [23:0] CODEC_write,
						 output logic sampleDone);
	

	//audio controller signals 
	logic indexEn;
	logic [3:0] track;

	//index counter
	integer index; 
	
	
	//16 khz counter
	integer count16khz; 
	logic sixteenKhz; 

	//max index params
	logic [14:0] maxIndex [0:7]; 
	logic [14:0] maxIndexCurrent; 

	assign maxIndex[0] = 15'd5572;	//these constants are determined during matlab processing
	assign maxIndex[1] = 15'd4643;
	assign maxIndex[2] = 15'd5200;
	assign maxIndex[3] = 15'd19999;
	assign maxIndex[4] = 15'd21199;
	assign maxIndex[5] = 15'd27679;
	assign maxIndex[6] = 15'd5386;
	assign maxIndex[7] = 15'd6129; 

	//Sound ROM 
	logic [23:0] zero [0:5572];
	logic [23:0] one [0:4643];
	logic [23:0] two [0:5200];
	logic [23:0] three [0:19999];
	logic [23:0] four [0:21199];
	logic [23:0] five [0:27679];
	logic [23:0] red [0:5386];
	logic [23:0] green [0:6129];

	initial begin
		$readmemb(".\\audioClips\\zero.txt", zero); 
		$readmemb(".\\audioClips\\one.txt", one); 
		$readmemb(".\\audioClips\\two.txt", two); 
		$readmemb(".\\audioClips\\three.txt", three); 
		$readmemb(".\\audioClips\\four.txt", four); 
		$readmemb(".\\audioClips\\five.txt", five); 
		$readmemb(".\\audioClips\\red.txt", red); 
		$readmemb(".\\audioClips\\green.txt", green); 
		
	end

	//16 khz counter
	always_ff @(posedge CLOCK_50) begin
		if(reset) begin
			count16khz <= 0;
			sixteenKhz <= 0; 
		end else begin
			if(count16khz < 3) begin
				count16khz <= count16khz + 1; 
				sixteenKhz <= 0; 
			end else  begin
				count16khz <= 0;
				sixteenKhz <= 1; 
			end
		end
	end
	
	//index counter
	always_ff @(posedge CLOCK_50) begin
		if(reset) begin
			index <= 0; 
			sampleDone <= 0; 
		end else if(indexEn) begin
			if(index < maxIndexCurrent) begin
				if(sixteenKhz) begin	//sample @ 16 khz
					index <= index + 1; 
				end
			end else if (index >= maxIndexCurrent) begin
				sampleDone <= 1; 	//if you're at the index, sample is done. 
				index <= 0; 		//go back to zero.
			end else if (sampleDoneAck) begin
				sampleDone <= 0; 	//sample done goes back to zero once acknowledged by keyboard controller
			end
		end else begin
			sampleDone <= 0; 
		end
	end

	//track selector 
	always_ff @(posedge CLOCK_50) begin
		if(reset) begin
			CODEC_write <= 24'd0; 
		end else 
			case(track) 
				4'b000: CODEC_write <= zero[index];
				4'b001: CODEC_write <= one[index];
				4'b010: CODEC_write <= two[index];
				4'b011: CODEC_write <= three[index];
				4'b100: CODEC_write <= four[index];
				4'b101: CODEC_write <= five[index];
				4'b110: CODEC_write <= red[index];
				4'b111: CODEC_write <= green[index];
				default: CODEC_write <= 24'd0; 
			endcase
	end

	//audio controller
	always_ff @(posedge CLOCK_50) begin
		if(reset) begin
			indexEn <= 0; 
			track <= 0;
			maxIndexCurrent <= 0; 
		end else begin
			if(redCountAudioRequest) begin
				indexEn <= 1; 	//start the index counter
				track <= redCount; 	//load the correct track
				maxIndexCurrent <= maxIndex[redCount]; 	//tell it when to stop the sample
			end else if (greenCountAudioRequest) begin
				indexEn <= 1; 
				track <= greenCount; 
				maxIndexCurrent <= maxIndex[greenCount]; 
			end else if (redAudioRequest) begin
				indexEn <= 1; 
				track <= 6; 
				maxIndexCurrent <= maxIndex[6]; 
			end else if (greenAudioRequest) begin
				indexEn <= 1; 
				track <= 7; 
				maxIndexCurrent <= maxIndex[7]; 
			end else if (sampleDone) begin
				indexEn <= 0; 
				track <= 8; 
				maxIndexCurrent <= 0; 
			end 
		end 
	end


endmodule 


module audioSelect_testbench();
 	logic CLOCK_50, reset;
	logic [3:0] redCount, greenCount;
	logic redCountAudioRequest, greenCountAudioRequest, redAudioRequest, greenAudioRequest, sampleDoneAck;
	logic [23:0] CODEC_write;
	logic sampleDone;

	audioSelect dut (.*);

	initial begin
		CLOCK_50 <= 0;
		forever #50 CLOCK_50 <= ~ CLOCK_50;
	end

	initial begin
		reset <= 1; redCount <= 0; greenCount <= 1; redCountAudioRequest <= 0;
		greenCountAudioRequest <= 0; redAudioRequest <= 0; greenAudioRequest <= 0; 
		sampleDoneAck <= 0; @(posedge CLOCK_50); 
		reset <= 0; @(posedge CLOCK_50); 
		redCount <= 1; @(posedge CLOCK_50); 
		redCountAudioRequest <= 1; @(posedge CLOCK_50); 
		redCountAudioRequest <= 0; @(posedge CLOCK_50); 
		@(posedge CLOCK_50); @(posedge CLOCK_50); @(posedge CLOCK_50); @(posedge CLOCK_50); 
		@(posedge CLOCK_50); @(posedge CLOCK_50); @(posedge CLOCK_50);
		redAudioRequest <= 1; @(posedge CLOCK_50); 
		redAudioRequest <= 0; @(posedge CLOCK_50); 
		@(posedge CLOCK_50); @(posedge CLOCK_50); @(posedge CLOCK_50); @(posedge CLOCK_50); 
		@(posedge CLOCK_50); @(posedge CLOCK_50); @(posedge CLOCK_50);@(posedge CLOCK_50);
		@(posedge CLOCK_50);@(posedge CLOCK_50);
		$stop(); 
	end

endmodule 