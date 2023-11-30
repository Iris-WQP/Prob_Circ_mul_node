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

module mul_tree_bf16_26mode(
        input clk,
        input rst,
        input [(4*32-1):0] mul_ins, 
        input mul_stb,
        input [1:0] mode,
        output reg [(4*16-1):0] outputs,
        output reg [3:0] final_output_stbs_1
    );

        //mode00 ---- two inputs
        //mode01 ---- three inputs
        //mode10 ---- four inputs
        //mode11 ---- six/two inputs      

  parameter 
            two_in     = 2'd0,
            three_in   = 2'd1, //put b
            four_in    = 2'd2, 
            six_in     = 2'd3; //six_two_in
            
 reg [3:0] final_output_stbs;
wire [31:0] input_apply [6:0];
wire [6:0] org_output_stbs;
wire [15:0] org_outputs [6:0]; 

wire  mul_stbs [6:0];
reg mul_stbs_0_1_2_3;
reg mul_stbs_4_5;
reg mul_stbs_6;
//reg [15:0] mode_26_reg0;
//reg [15:0] mode_26_reg1;


assign mul_stbs[0] = mul_stbs_0_1_2_3;
assign mul_stbs[1] = mul_stbs_0_1_2_3;
assign mul_stbs[2] = mul_stbs_0_1_2_3;
assign mul_stbs[3] = mul_stbs_0_1_2_3;
assign mul_stbs[4] = mul_stbs_4_5;
assign mul_stbs[5] = mul_stbs_4_5;
assign mul_stbs[6] = mul_stbs_6;

always@(posedge clk)begin
    mul_stbs_0_1_2_3 <= mul_stb;
    mul_stbs_4_5 <= org_output_stbs[0];
    mul_stbs_6 <= org_output_stbs[4];
    final_output_stbs_1 <= final_output_stbs;
end



assign input_apply[0] = mul_ins[31:0];
assign input_apply[1][15:0] = mul_ins[(1*32+16-1):1*32];
assign input_apply[1][31:16] = (mode==three_in)? 16'b0011111110000000:mul_ins[(2*32-1):(32+16)];
assign input_apply[2] = mul_ins[(3*32-1):2*32];
//assign input_apply[3][15:0] = (mode==six_in)?16'b0011111110000000:mul_ins[(3*32+16-1):3*32];
assign input_apply[3][15:0] = mul_ins[(3*32+16-1):3*32];
assign input_apply[3][31:16] = (mode==three_in)?16'b0011111110000000:mul_ins[(4*32-1):(3*32+16)];
assign input_apply[4][15:0] = org_outputs[0];
assign input_apply[4][31:16] = org_outputs[1];
assign input_apply[5][15:0] = org_outputs[2];
//assign input_apply[5][31:16] = org_outputs[3];
assign input_apply[5][31:16] = (mode==three_in)?16'b0011111110000000:org_outputs[3];
assign input_apply[6][15:0] = org_outputs[4];
assign input_apply[6][31:16] = org_outputs[5];

always @(*)   begin     
     if (mode==two_in)begin 
         final_output_stbs = org_output_stbs[3:0];
         outputs = {org_outputs[3], org_outputs[2], org_outputs[1], org_outputs[0]};
     end else if ((mode==three_in)|(mode==four_in)) begin
         final_output_stbs = {2'b00,org_output_stbs[5:4]};
         outputs = {32'd0, org_outputs[5], org_outputs[4]};
     end else if (mode==six_in) begin
         final_output_stbs = {2'b00,org_output_stbs[3],org_output_stbs[6]};
         outputs = {32'd0, org_output_stbs[3],org_outputs[6]};
     end
end

genvar n;
generate  //Device Under Test
    for(n=0;n<7;n=n+1)
    begin:dut
        mul_3_stage_pipe_bf16 u_mul_3_stage_pipe_bf16
(
        .input_mul(input_apply[n]),          //inputa[31:16] inputb[15:0]
        .input_mul_stb(mul_stbs[n]),  
        .s_input_mul_ack(),        //pipeline--ack==1
        .clk(clk),
        .rst(rst),
        .z(org_outputs[n]),
        .s_output_z_stb(org_output_stbs[n])      //output z valid
);
    end
endgenerate
         
endmodule
