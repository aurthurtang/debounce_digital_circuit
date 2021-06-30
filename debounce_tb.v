`timescale 1ns / 1ps

module debounce_tb();

  reg clk;
  reg rstn;
  reg in;
  wire out;

parameter DEBOUNCE_PERIOD = 100;
task switchon;
  in = 0;
  repeat(10) begin
    #DEBOUNCE_PERIOD in = 1;
    #DEBOUNCE_PERIOD in = 0;
  end
  #10 in = 1;
endtask

task switchoff;
  in = 1;
  repeat(10) begin
    #DEBOUNCE_PERIOD in = 0;
    #DEBOUNCE_PERIOD in = 1;
  end
  #10 in = 0;
endtask

initial begin
  clk = 0;
  in = 0;
  forever #(12.5) clk = ~clk;
end

initial begin
  $recordfile ("sim.trn");
  $recordvars();
  rstn = 0;
  #2000 rstn = 1;

  #10000 switchon;
  #10000 switchoff;
  #2000 switchon;
  #4000 switchoff;

  #1000 $finish;
end

debounce #(7,10) DUT (clk,rstn,in,out);

endmodule
