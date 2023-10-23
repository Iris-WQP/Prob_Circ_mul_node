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

module mul_chain_bf16(
        input clk,
        input rst,
        input [(6*32-1):0] mul_ins, 
        input mul_stb,
        input [1:0] mode,
        output [(6*16-1):0] outputs,
        output reg [5:0] final_output_stbs
    );
        //mode00 ---- two inputs
        //mode01 ---- three inputs
        //mode10 ---- four inputs
        //mode11 ---- six inputs      

  parameter 
            two_in     = 2'd0,
            three_in   = 2'd1, //put b
            four_in    = 2'd2, 
            six_in     = 2'd3;

wire [31:0] input_apply [5:0];
wire [5:0] output_stbs;


genvar n;
generate  //��������Device Under Test
    for(n=0;n<6;n=n+1)
    begin:dut
        mul_3_stage_pipe_bf16 u_mul_3_stage_pipe_bf16
(
        .input_mul(input_apply[n]),          //inputa[31:16] inputb[15:0]
        .input_mul_stb(mul_stb),  
        .s_input_mul_ack(),        //pipeline--always 1
        .clk(clk),
        .rst(rst),
        .z(outputs[(16*(n+1)-1):16*n]),
        .s_output_z_stb(output_stbs[n])      //output z valid
);
    end
endgenerate


assign input_apply[0] = mul_ins[31:0];
assign input_apply[1][15:0] = mul_ins[(1*32+16-1):1*32];
assign input_apply[1][31:16] = (mode==two_in)? mul_ins[(2*32-1):(32+16)]:outputs[15:0];
assign input_apply[2][15:0] = mul_ins[(2*32+16-1):2*32];
assign input_apply[2][31:16] = (~mode[1])? mul_ins[(3*32-1):(2*32+16)]:outputs[31:16];
assign input_apply[3][15:0] = mul_ins[(3*32+16-1):3*32];
assign input_apply[3][31:16] = (~mode[0])?mul_ins[(4*32-1):(3*32+16)]:outputs[47:32];
assign input_apply[4][15:0] = mul_ins[(4*32+16-1):4*32];
assign input_apply[4][31:16] = (~mode[1])?mul_ins[(5*32-1):(4*32+16)]:outputs[31:16];
assign input_apply[5][15:0] = mul_ins[(5*32+16-1):5*32];
assign input_apply[5][31:16] = (mode==two_in)?mul_ins[(6*32-1):(5*32+16)]:outputs[79:64];

always @(*)   begin     
    if (mode==two_in) final_output_stbs = (6'b111111)&output_stbs;
    else if (mode==three_in) final_output_stbs = (6'b101010)&output_stbs;
    else if (mode==four_in) final_output_stbs = (6'b100100)&output_stbs;
    else if (mode==six_in)  final_output_stbs = (6'b010000)&output_stbs;
end
          

    
endmodule
