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

module tb_3_stage();
  reg  clk;
  reg  rst;
  reg out_ack;
  reg   mul_stb;
  wire [1:0] state;
  reg [63:0] memory[31:0];
  reg   [63:0] mul_in;
  int i;
initial begin
  $readmemb("D:/PKU/fpu/fpu.srcs/sim_1/imports/multiplier/stim_bi.txt",memory);
  i = 0;
  mul_in = 'd0;
  #55;
  repeat(32)begin
       begin
        mul_in = memory[i];
        mul_stb = 1;
       end
       #10 begin
        i = i+1;
        mul_stb = 0;
       end
        #20;
  end
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
  wire   [31:0] wire_o;
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
    

  mul_3_stage dut(
        .input_mul(mul_in),          //inputa[63:32] inputb[31:0]
        .input_mul_stb(mul_stb),  
        .s_input_mul_ack(wire_mul_ack),        
        .clk(clk),
        .rst(rst),
        .z(wire_o),
        .s_output_z_stb(wire_o_stb),      //output z valid
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

//wire [31:0] memory1;
//wire [31:0] memory2;
//MEM_input #
//(
//    .WIDTH( 64 ),
//    .DEPTH( 64 ),
//    .log2_DEPTH(6)
//) u_Input_Memory
//(
//    .clk(clk),
//    .rst_n(~rst),
//    .start(wire_mul_ack),
//    .num_of_dat(64),
    
//    .dat_out(wire_mul),
//    .dat_out_vld(wire_mul_stb),
//    .done()
//);

    
    
endmodule

