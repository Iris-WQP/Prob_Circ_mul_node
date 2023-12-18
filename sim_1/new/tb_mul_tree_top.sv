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
`include "defines.vh"
module tb_mul_tree_top();
wire [(4*`DW-1):0] wire_o;
wire output_vld;
wire input_ready;

  reg  [1:0] mode;
  reg  clk;
  reg  rst;
  reg input_vld;
  reg [`bram_in_width-1:0] memory [2047:0];
  reg [`bram_in_width-1:0] interface_in;

  int i;
  int f_in;
  int f_out;
  reg max_exponent_ready;
  wire[7:0] max_exponent;
  wire max_exponent_vld;
  
//  //debug
//wire [1:0] state;
//wire [`bram_in_width-1:0] bram_in_wdata;
//wire bram_in_we;
//wire bram_in_re;
//wire [127:0]se_bram_read_data;
//wire [`bram_in_width-1:0]bram_read_data;
//wire [127:0] mul_in;
//wire mul_stb;
//wire fi_read;
//wire [`small_log2_bram_depth_in-1:0] bram_in_waddr;
//wire [`small_log2_bram_depth_in-1:0] bram_in_raddr;

//wire [7:0] compare_tree0;
//wire [7:0] compare_tree1;
//wire [7:0] compare_tree2;

//wire  [256-1:0] bram_sample_0;                
//wire  [256-1:0] bram_sample_1;                
//wire  [256-1:0] bram_sample_254;
//wire  [256-1:0] bram_sample_255;
  
initial begin
  mode <= 2'b00;
  max_exponent_ready <= 0;
//  num_of_line_per_node_minusone <= 11'd2047;
  $readmemb("D:/PKU/fpu/fpu.srcs/sim_1/imports/multiplier/stim_bram_ctrl.txt",memory);
  i = 0;
  @(posedge clk)interface_in = 0;
  #40;
  repeat(256)begin
       begin
        @(posedge clk)begin
        interface_in = memory[i];
        input_vld = 1;
        end
       end
       #10 i=i+1;
  end
     @(posedge clk) input_vld = 0;
repeat (6) begin
    #(`bram_in_width*20)
    repeat(256)begin
       begin
        @(posedge clk)begin
        interface_in = memory[i];
        input_vld = 1;
        end
       end
       #10 i=i+1;
  end
  @(posedge clk) input_vld = 0;
end
  #100 max_exponent_ready <= 1;
  #110 max_exponent_ready <= 0;
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
  


    mul_tree_top dut (
        .clk(clk),
        .rst(rst),
        .interface_in(interface_in),
        .input_vld(input_vld),
        .input_ready(input_ready),
        .mode(mode),
        .interface_out(wire_o),
        .output_vld(output_vld),

        .max_exponent_ready(max_exponent_ready),
        .max_exponent(max_exponent),
        .max_exponent_vld(max_exponent_vld)
        
        //debug
//        ,
//    .state(state),
//    .bram_in_wdata(bram_in_wdata),
//    .bram_in_we(bram_in_we),
//    .bram_in_re(bram_in_re),
//    .se_bram_read_data(se_bram_read_data),
//    .bram_read_data(bram_read_data),
//    .mul_in(mul_in),
//    .mul_stb(mul_stb),
//    .fi_read(fi_read),
//    .cnt_output(),
//    .bram_in_waddr(bram_in_waddr),
//    .bram_in_raddr(bram_in_raddr),
//    .compare_tree0(compare_tree0),
//    .compare_tree1(compare_tree1),
//    .compare_tree2(compare_tree2)
    
//    ,
//    .bram_sample_0(bram_sample_0),                
//    .bram_sample_1(bram_sample_1),                
//    .bram_sample_254(bram_sample_254),
//    .bram_sample_255(bram_sample_255)
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