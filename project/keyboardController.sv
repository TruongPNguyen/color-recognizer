module keyboardController(input logic clk, reset, makeBreak, sampleDone, input logic [7:0] outCode, 
                            output logic redCountAudioRequest, greenCountAudioRequest, redAudioRequest, greenAudioRequest, sampleDoneAck); 


enum {idle, inputMade, inputBreak, greenRequest, redRequest, sampleOne, sampleTwo} ps, ns; 

enum {green, red} colorRequested;

logic [7:0] lastOutCode;
parameter rCode = 8'b00101101;
parameter gCode = 8'b00110100;


//Control signal next state logic
always_comb begin
    //Default
    ns = ps; 
    case(ps)
        idle: if(makeBreak) ns = inputMade;

        //Input made positive edge detector 
        inputMade: if(!makeBreak) ns = inputBreak;

        //Input broken negative edge detector
        inputBreak: if(lastOutCode == rCode)
                        ns = redRequest; 
                      else if (lastOutCode == gCode)
                        ns = greenRequest; 

        //Did I type a G (green) or R (red?) 
        redRequest: if(sampleDone) ns = sampleOne;
        greenRequest:if(sampleDone) ns = sampleOne;

        //First sample done (number audio) positive edge detector
        sampleOne: if(sampleDone) ns = sampleTwo;

        //Second sample done (color audio) positive edge detector
        sampleTwo: ns = idle; //go back to idle after finishing the "<number>" + "<color>" audio clip

        default: ns = idle; 
    endcase 

end

    //Control signals to start number audio playback 
    assign redCountAudioRequest = ((ps == inputBreak) & (ns == redRequest));
    assign greenCountAudioRequest = ((ps == inputBreak) & (ns == greenRequest)); 
    
    //Control signals to start color audio playback
    assign redAudioRequest = (ps == sampleOne) & (colorRequested == red);
	assign greenAudioRequest = (ps == sampleOne) & (colorRequested == green); 

    //Acknowledge sample done, might be needed.
    assign sampleDoneAck = (ps == sampleOne) | (ps == sampleTwo); 

    //Datapath
    always_ff @(posedge clk) begin
        if(reset) 
            lastOutCode <= 8'd0; 
        else if(ps == inputMade)
            lastOutCode <= outCode;     //save the outcode to read cyles later
        else if(ps == redRequest)
            colorRequested <= red;      //remember whether red or green was requested
        else if(ps == greenRequest)
            colorRequested <= green; 
    end

    //Next state flip flop 
    always_ff @(posedge clk) begin
        if(reset)
            ps <= idle;
        else 
            ps <= ns; 
    end

endmodule 


module keyboardController_testbench();
    logic clk, reset, makeBreak, sampleDone;
    logic [7:0] outCode;
    logic redCountAudioRequest, greenCountAudioRequest, redAudioRequest, greenAudioRequest, sampleDoneAck;

    keyboardController dut (.*);

    initial begin
        clk <= 0; 
        forever #50 clk <= ~clk; 
    end

    initial begin
        reset <= 1; makeBreak <= 0; sampleDone <= 0; @(posedge clk); 
        reset <= 0; @(posedge clk); 
        makeBreak <= 1; outCode <= 8'b00101101; @(posedge clk);
        makeBreak <= 0; @(posedge clk); 
        makeBreak <= 1; outCode <= 8'd0; @(posedge clk);
        makeBreak <= 0; @(posedge clk); //countAudio request should be true around here.
        @(posedge clk); @(posedge clk); @(posedge clk);
        sampleDone <= 1; @(posedge clk);    //redAudio request should be true around here. 
        sampleDone <= 0; @(posedge clk);
        @(posedge clk);@(posedge clk);@(posedge clk);
        sampleDone <= 1; @(posedge clk);
        sampleDone <= 0; @(posedge clk);    //go back to idle 
        @(posedge clk); @(posedge clk); @(posedge clk); 
        $stop(); 
    end

endmodule