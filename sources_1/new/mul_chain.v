`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/12 17:36:40
// Design Name: 
// Module Name: mul_tree
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

module mul_chain(
        input clk,
        input rst,
        input [(6*64-1):0] mul_ins, 
        input mul_stb,
        input [1:0] mode,
        output [(6*32-1):0] outputs,
        output reg [5:0] final_output_stbs
    );
        //两输入情况下带宽最大，六输入时有一个乘法器浪费，可能成为瓶颈
        //mode00 ---- two inputs
        //mode01 ---- three inputs
        //mode10 ---- four inputs
        //mode11 ---- six inputs      

  parameter 
            two_in     = 2'd0,
            three_in   = 2'd1, //put b
            four_in    = 2'd2, 
            six_in     = 2'd3;

wire [63:0] input_apply [5:0];
wire [5:0] output_stbs;


genvar n;
generate  //生成许多Device Under Test
    for(n=0;n<6;n=n+1)
    begin:dut
        mul_3_stage_pipe u_mul_3_stage_pipe
(
        .input_mul(input_apply[n]),          //inputa[63:32] inputb[31:0]
        .input_mul_stb(mul_stb),  
        .s_input_mul_ack(),        //pipeline模式下ack始终为1, 可删
        .clk(clk),
        .rst(rst),
        .z(outputs[(32*(n+1)-1):32*n]),
        .s_output_z_stb(output_stbs[n])      //output z valid
);
    end
endgenerate


assign input_apply[0] = mul_ins[63:0];
assign input_apply[1][31:0] = mul_ins[(1*64+32-1):1*64];
assign input_apply[1][63:32] = (mode==two_in)? mul_ins[(2*64-1):(64+32)]:outputs[31:0];
assign input_apply[2][31:0] = mul_ins[(2*64+32-1):2*64];
assign input_apply[2][63:32] = (~mode[1])? mul_ins[(3*64-1):(2*64+32)]:outputs[63:32];
assign input_apply[3][31:0] = mul_ins[(3*64+32-1):3*64];
assign input_apply[3][63:32] = (~mode[0])?mul_ins[(4*64-1):(3*64+32)]:outputs[95:64];
assign input_apply[4][31:0] = mul_ins[(4*64+32-1):4*64];
assign input_apply[4][63:32] = (~mode[1])?mul_ins[(5*64-1):(4*64+32)]:outputs[127:96];
assign input_apply[5][31:0] = mul_ins[(5*64+32-1):5*64];
assign input_apply[5][63:32] = (mode==two_in)?mul_ins[(6*64-1):(5*64+32)]:outputs[159:128];

always @(*)   begin     
     if (mode==two_in) final_output_stbs = (6'b111111)&output_stbs;
     else if (mode==three_in) final_output_stbs = (6'b101010)&output_stbs;
     else if (mode==four_in) final_output_stbs = (6'b100100)&output_stbs;
     else if (mode==six_in)  final_output_stbs = (6'b010000)&output_stbs;
end
            

    
endmodule
