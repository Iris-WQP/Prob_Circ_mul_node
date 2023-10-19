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

module mul_tree(
        input clk,
        input rst,
        input [(4*64-1):0] mul_ins, 
        input mul_stb,
        input [1:0] mode,
        output reg [(4*32-1):0] outputs,
        output reg [3:0] final_output_stbs
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

wire [63:0] input_apply [6:0];
wire [6:0] org_output_stbs;
wire [31:0] org_outputs [6:0]; 


genvar n;
generate  //生成许多Device Under Test
    for(n=0;n<7;n=n+1)
    begin:dut
        mul_3_stage_pipe u_mul_3_stage_pipe
(
        .input_mul(input_apply[n]),          //inputa[63:32] inputb[31:0]
        .input_mul_stb(mul_stb),  
        .s_input_mul_ack(),        //pipeline模式下ack始终为1, 可删
        .clk(clk),
        .rst(rst),
        .z(org_outputs[n]),
        .s_output_z_stb(org_output_stbs[n])      //output z valid
);
    end
endgenerate


assign input_apply[0] = mul_ins[63:0];
assign input_apply[1][31:0] = mul_ins[(1*64+32-1):1*64];
assign input_apply[1][63:32] = (mode==three_in)? 32'b00111111100000000000000000000000:mul_ins[(2*64-1):(64+32)];
assign input_apply[2] = mul_ins[(3*64-1):2*64];
assign input_apply[3][31:0] = (mode==six_in)?32'b00111111100000000000000000000000:mul_ins[(3*64+32-1):3*64];
assign input_apply[3][63:32] = (mode[0])?32'b00111111100000000000000000000000:mul_ins[(4*64-1):(3*64+32)];
assign input_apply[4][31:0] = org_outputs[0];
assign input_apply[4][63:32] = org_outputs[1];
assign input_apply[5][31:0] = org_outputs[2];
assign input_apply[5][63:32] = org_outputs[3];
assign input_apply[6][31:0] = org_outputs[4];
assign input_apply[6][63:32] = org_outputs[5];

always @(*)   begin     
     if (mode==two_in)begin 
            final_output_stbs = org_output_stbs[3:0];
            outputs = {org_outputs[3], org_outputs[2], org_outputs[1], org_outputs[0]};
     end else if ((mode==three_in)|(mode==four_in)) begin
            final_output_stbs = {2'b00,org_output_stbs[5:4]};
            outputs = {64'd0, org_outputs[5], org_outputs[4]};
     end else if (mode==six_in) begin
            final_output_stbs = {3'b000,org_output_stbs[6]};
            outputs = {96'd0, org_outputs[6]};
     end
end
            
endmodule
