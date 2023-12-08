`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/07 00:36:56
// Design Name: 
// Module Name: tb_bf16_adder
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


module tb_bf16_adder1( );
    reg [15:0] a;
    reg a_vld;
    reg [15:0] b;
    reg b_vld;
    wire [15:0] z;
    wire z_vld;
    
//    //debug
//    wire a_s, b_s, z_s;
//    wire [9:0] a_e, b_e;
//    wire [10:0] a_extend_m, b_extend_m;
//    wire [10:0] a_shift_m, b_shift_m;
//    wire a_e_bigger, b_e_bigger, a_m_bigger;
//    wire [7:0] e_diff;
//    wire [7:0] z_e_temp; //z_e before normalization
//    wire [7:0] z_e_tp; //z_e before round
//    wire [10:0] z_e;
//    wire [10:0] sum_fraction_tmp;
//    wire [11:0] sum_fraction;
//    wire [6:0] unrounded_fraction;
//    wire [6:0] rounded_fraction;
//    wire [3:0] lead_zero_cnt;
//    wire guard, round_bit, sticky;
    
    reg [63:0] memory[31:0];
    
    int f_in;
    int f_out;
    

    // Instantiate the Device Under Test (DUT)
    bf16_adder1 dut (
        .a(a),
        .a_vld(a_vld),
        .b(b),
        .b_vld(b_vld),
        .z(z),
        .z_vld(z_vld)
//        //debug
//        ,
//        .a_s(a_s),
//        .b_s(b_s),
//        .z_s(z_s),
//        .a_e(a_e),
//        .b_e(b_e),
//        .a_extend_m(a_extend_m),
//        .b_extend_m(b_extend_m),
//        .a_shift_m(a_shift_m),
//        .b_shift_m(b_shift_m),
//        .a_e_bigger(a_e_bigger),
//        .b_e_bigger(b_e_bigger),
//        .a_m_bigger(a_m_bigger),
//        .e_diff(e_diff),
//        .z_e_temp(z_e_temp),
//        .z_e_tp(z_e_tp),
//        .z_e(z_e),
//        .sum_fraction_tmp(sum_fraction_tmp),
//        .sum_fraction(sum_fraction),
//        .unrounded_fraction(unrounded_fraction),
//        .rounded_fraction(rounded_fraction),
//        .lead_zero_cnt(lead_zero_cnt),
//        .guard(guard),
//        .round_bit(round_bit),
//        .sticky(sticky)
    );

    int i;
    initial begin
        // Initialize inputs
        a = 16'h0;
        a_vld = 0;
        b = 16'h0;
        b_vld = 0;
        $readmemb("D:/PKU/fpu/fpu.srcs/sim_1/imports/multiplier/stim_bi.txt",memory);
        i = 0;
        
        // Apply test vectors
        #10 a_vld = 1; b_vld = 1;
      repeat(32)begin
        begin
         a = memory[i][15:0];
         b = memory[i][31:16];
        end
        #10 i=i+1;
      end
      a = 16'h1b74; b = 16'h1a64;
      #10 a = 16'h623c; b = 16'h623c;
      #10 a_vld = 0; b_vld = 0;
    end

    initial begin
        // Monitor the output
        $monitor("At time %d, z = %h, z_vld = %b", $time, z, z_vld);
    end
    
initial begin
    f_in = $fopen("D:/PKU/fpu/fpu.srcs/soft_test/adder_stim_inputs.txt","w");
    #5;
    repeat(34)begin
        #10;
        $fdisplay(f_in, "%h", {a,b});
    end
    $fclose(f_in);
end

initial begin
    f_out = $fopen("D:/PKU/fpu/fpu.srcs/soft_test/adder_stim_outputs.txt","w");
    #5;
    repeat(34)begin
        #10;
        $fdisplay(f_out,"%h", z);
    end
    $fclose(f_out);
end


endmodule
