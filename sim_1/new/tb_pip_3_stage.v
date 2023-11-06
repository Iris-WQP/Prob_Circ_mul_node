`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/03 19:09:34
// Design Name: 
// Module Name: mul_one_tb
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
`include "tb_defines.vh"
module tb_pip_3_stage();
  reg  clk;
  reg  rst;
  reg out_ack;
  reg   mul_stb;
  reg [63:0] memory[31:0];
  reg   [2*`DW-1:0] mul_in;
//  wire [15:0] mul_men;
//  wire [7:0] a_mm;
//  wire [7:0] b_mm;
  int i;
initial begin
  $readmemb("D:/PKU/fpu/fpu.srcs/sim_1/imports/multiplier/stim_bi.txt",memory);
  i = 0;
  #45;
  repeat(32)begin
       begin
        mul_in = memory[i];
        mul_stb = 1;
       end
       #10 i=i+1;
  end
  mul_in = 32'h2490c225;
end
  
  initial
  begin
    rst <= 1'b1;
    #50 rst <= 1'b0;
    out_ack <= 1;
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

 

  wire   wire_mul_ack;
  wire   [`DW-1:0] wire_o;
  wire   wire_o_stb;
//  wire   wire_o_ack;
//  wire   read_bram;
//  wire   write_bram;

//  file_reader_b file_reader_b_0(
//    .clk(clk),
//    .rst(rst),
//    .output_z(wire_mul),
//    .output_z_stb(wire_mul_stb),
//    .output_z_ack(wire_mul_ack));
    
  file_writer file_writer_0(
    .clk(clk),
    .rst(rst),
    .input_a(wire_o),
    .input_a_stb(wire_o_stb),
    .input_a_ack());
    

  mul_3_stage_pipe_bf16 dut(
        .input_mul(mul_in),          //inputa[63:32] inputb[31:0]
        .input_mul_stb(mul_stb),  
        .s_input_mul_ack(wire_mul_ack),        
        .clk(clk),
        .rst(rst),
        .z(wire_o),
        .s_output_z_stb(wire_o_stb)      //output z valid
        
        //debug
//        ,
//        .mul_men(mul_men),
//        .a_mm(a_mm),
//        .b_mm(b_mm)
  );
    
  
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
    
endmodule

