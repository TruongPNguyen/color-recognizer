module audioManager (redCount, greenCount, CLOCK_50, CLOCK2_50, reset, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT, PS2_DAT, PS2_CLK, LEDR);

	input CLOCK_50, CLOCK2_50, reset;
	input logic PS2_CLK, PS2_DAT;
	output logic LEDR[9:0]; 
	
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	//Audio CODEC locals
	logic read_ready, write_ready, read, write;
	logic [23:0] readdata_left, readdata_right;
	logic [23:0] writedata_left, writedata_right;
	logic [23:0] CODEC_write;
	logic sampleDone, sampleDoneAck;

	//Red/green counts
   input logic [3:0] redCount, greenCount;
	
	//PS2 signals
	logic makeBreak; 
	logic valid; 
	logic [7:0] outCode; 
	
	//Keyboard locals
	logic redCountAudioRequest, greenCountAudioRequest, redAudioRequest, greenAudioRequest;
	

	//Provided keyboard driver
	keyboard_press_driver keytest (.CLOCK_50(CLOCK_50), .valid(valid), .makeBreak(makeBreak),.outCode(outCode),
											.PS2_DAT(PS2_DAT), .PS2_CLK(PS2_CLK), .reset);
	

	//Keyboard controller module, outputs signals that control selection of audio tracks
	keyboardController keymanager (.clk(CLOCK_50), .reset, .makeBreak, .sampleDone, .outCode, 
                            .redCountAudioRequest, .greenCountAudioRequest, .redAudioRequest, .greenAudioRequest, .sampleDoneAck); 

	//Audio select module, outputs correct track to CODEC
	audioSelect audioSel (.CLOCK_50, .reset, .redCount, .greenCount, .redCountAudioRequest, .greenCountAudioRequest, 
								.redAudioRequest, .greenAudioRequest, .sampleDoneAck, .CODEC_write, .sampleDone);
	
	assign writedata_left = CODEC_write;
	assign writedata_right = CODEC_write;
	assign read = read_ready;
	assign write = write_ready;
	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		.CLOCK2_50,
		.reset,

		// outputs
		.AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule


