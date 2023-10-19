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

module mul_one_tb();
  reg  clk;
  reg  rst;
  reg [2:0] cnt_max;
  wire [2:0] cnt;
  reg out_ack;
  wire [3:0] state;
  
  initial
  begin
    rst <= 1'b1;
    cnt_max <= 3'd5;
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

  wire   [31:0] wire_b;
  wire   wire_b_stb;
  wire   wire_b_ack;
  wire   [31:0] wire_o;
  wire   wire_o_stb;
//  wire   wire_o_ack;
//  wire   read_bram;
//  wire   write_bram;

  file_reader_b file_reader_b_0(
    .clk(clk),
    .rst(rst),
    .output_z(wire_b),
    .output_z_stb(wire_b_stb),
    .output_z_ack(wire_b_ack));
    
  file_writer file_writer_0(
    .clk(clk),
    .rst(rst),
    .input_a(wire_o),
    .input_a_stb(wire_o_stb),
    .input_a_ack());
    
  mul_one mul_one_0(
    .clk(clk),
    .rst(rst),
    .mul_data(wire_b),
    .mul_stb(wire_b_stb),
    .mul_ack(wire_b_ack),
    .cnt_max(cnt_max),
    .s_output_z(wire_o),
    .s_output_z_stb(wire_o_stb),
    .output_z_ack(out_ack),
    .cnt(cnt),
    .state(state)
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

