`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/21 16:49:15
// Design Name: 
// Module Name: TB_top_allone_bram_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module TB_top_allone_bram_ctrl();
  wire [(4*`DW-1):0] wire_o;
  wire output_vld;
  wire input_ready;
  wire [1:0] state;
  wire stop;
  reg  [1:0] mode;
  reg  clk;
  reg  rst;
  reg input_vld;
  reg [255:0] memory [2047:0];
  reg [255:0] interface_in;
  int i;
  int f_in;
  int f_out;

  
initial begin
  mode <= 2'b01;
  $readmemb("D:/PKU/fpu/fpu.srcs/sim_1/imports/multiplier/stim_bram_ctrl.txt",memory);
  i = 0;
  interface_in = 0;
  #45;
  repeat(1024)begin
       begin
        interface_in = memory[i];
        input_vld = 1;
       end
       #10 i=i+1;
  end
      input_vld = 0;
end
  
  initial
  begin
    rst <= 1'b1;
    
    #50 rst <= 1'b0;
  end

  
  initial
  begin
    #1000000 $finish;
  end


  initial
  begin
    clk <= 1'b0;
    while (1) begin
      #5 clk <= ~clk;
    end
  end
  

  initial
  begin
    rst <= 1'b1;
    #50 rst <= 1'b0;
  end

  
  initial
  begin
    #100000000 $finish;
  end

  
  initial
  begin
    clk <= 1'b0;
    while (1) begin
      #5 clk <= ~clk;
    end
  end

    top_allone_bram_ctrl dut (
        .clk(clk),
        .rst(rst),
        .interface_in(interface_in),
        .input_vld(input_vld),
        .input_ready(input_ready),
        .mode(mode),
        .interface_out(wire_o),
        .output_vld(output_vld),
        .state(state),
        .stop(stop)
    );

//initial begin
//    f_in = $fopen("D:/PKU/fpu/fpu.srcs/soft_test/stim_inputs.txt","w");
//    #50;
//    repeat(16)begin
//        #10;
//        $fdisplay(f_in, "%h", mul_in);
//    end
//    $fclose(f_in);
//end

//string output_string;
//initial begin
//    mode <= 2'b10;
//    f_out = $fopen("D:/PKU/fpu/fpu.srcs/soft_test/stim_outputs_TB_bram_ctrl.txt","w");
//    #100;
//    //mode 1 --- 70
//    //mode2,3 --- 100
//    //mode 4 --- 130
//    repeat(15)begin
//        #10;
//        $fdisplay(f_out,"%h", wire_o);
//    end
//    $fclose(f_out);
//end

endmodule
