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


module tb_bf16_adder( );
    reg [15:0] a;
    reg a_vld;
    reg [15:0] b;
    reg b_vld;
    wire [15:0] z;
    wire z_vld;

    // Instantiate the Device Under Test (DUT)
    bf16_adder1 dut (
        .a(a),
        .a_vld(a_vld),
        .b(b),
        .b_vld(b_vld),
        .z(z),
        .z_vld(z_vld)
    );

    initial begin
        // Initialize inputs
        a = 16'h0;
        a_vld = 0;
        b = 16'h0;
        b_vld = 0;

        // Apply test vectors
        #10 a = 16'h1234; a_vld = 1;
        #10 b = 16'h5678; b_vld = 1;
        #10 a = 16'h9abc; a_vld = 1;
        #10 b = 16'hdef0; b_vld = 1;
        #10 a_vld = 0; b_vld = 0;
    end

    initial begin
        // Monitor the output
        $monitor("At time %d, z = %h, z_vld = %b", $time, z, z_vld);
    end

endmodule
