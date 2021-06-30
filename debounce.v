/////////////////////////////////////////////////////////////////////////
//
// Name: Debounce
//
// Purpose:  This module is use to filter out all the unnecessary switching 
//           from push button/switcher
//
////////////////////////////////////////////////////////////////////////

module debounce 
#(parameter SMP_CNT_MAX = 100,  //Sample pulse.  Higher value mean the pulse will generate wider apart
                                //Will miss short pulses
				//SAMPLE_CNT_MAX = (Clk_freq / Sample freq) - 1
				//E.X: with clk frequency = 40 Mhz.  Sample every 200 ns
				//     SAMPLE_CNT_MAX = 200 ns / 25 ns - 1  
  parameter PULSE_CNT_MAX = 10) // Set Debounce window.  Set higher for bigger debounce window
                                // With clk @ 40 Mhz (25 ns), 10 will give 250 ns debounce window
(
    input      iclk,
    input      irst_n,
    input      switchin,
    
    output reg switchout

);

  reg [1:0] switch_sync;
  reg [15:0] sample_cnt;
  reg [7:0] out_pulse_cnt;

  reg sample_pulse;

   //Synchronizer
  always @(posedge iclk or negedge irst_n)
    if (!irst_n) switch_sync[1:0] = 2'b00;
    else switch_sync[1:0] = {switch_sync[0], switchin};
 
  //Sample Pulse
  always @(posedge iclk or negedge irst_n)
    if (!irst_n) begin
      sample_cnt <= 'b0;
      sample_pulse <= 1'b0;
    end else begin
      if (sample_cnt == SMP_CNT_MAX) begin
        sample_pulse <= 1'b1;
	sample_cnt <= 16'b0;
      end else begin
        sample_cnt <= sample_cnt +1;
        sample_pulse <= 1'b0;
      end
    end

  //Debouncer
  always @(posedge iclk or negedge irst_n)
    if (!irst_n) begin
      out_pulse_cnt <= 'b0;
      switchout <= 1'b0;
    end else if (~switch_sync[1]) begin
      out_pulse_cnt <= 'b0;
      switchout <= 1'b0;
    end else begin
      if (out_pulse_cnt == PULSE_CNT_MAX) switchout <= 1'b1;
      else if (sample_pulse) begin
        out_pulse_cnt <= out_pulse_cnt + 1;
	switchout <= 1'b0;
      end
    end

endmodule      
