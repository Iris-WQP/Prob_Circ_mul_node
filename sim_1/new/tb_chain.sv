`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/12 20:38:07
// Design Name: 
// Module Name: tb_chain
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

module tb_chain();

  reg  clk;
  reg  rst;
  reg   mul_stb;
  reg [(64*6-1):0] memory[15:0];
  reg [(64*6-1):0] mul_in;
  int i;
  
initial begin
  $readmemb("D:/PKU/fpu/fpu.srcs/sim_1/imports/multiplier/stim_chain.txt",memory);
  i = 0;
  #45;
  repeat(16)begin
       begin
        mul_in = memory[i];
        mul_stb = 1;
       end
       #10 i=i+1;
  end
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


  wire   [(6*32-1):0] wire_o;
  wire   [5:0] wire_o_stb;
  reg [1:0] mode;

  mul_chain dut(
        .clk(clk),
        .rst(rst),
        .mul_ins(mul_in),          //inputa[63:32] inputb[31:0]
        .mul_stb(mul_stb),  
        .mode (mode),
        .outputs(wire_o),
        .final_output_stbs(wire_o_stb)      //output z valid
  );
    
  
  initial
  begin
    rst <= 1'b1;
    mode <= 2'b11;
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
    
    
endmodule


