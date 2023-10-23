`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/23 17:48:44
// Design Name: 
// Module Name: top
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

module top #
(	
    parameter M_AXI_ID_WIDTH = 4,    //ID用来区分不同的请求
    parameter M_AXI_DATA_WIDTH = `Tin*`DW //8*16=128
)
(
    input clk,
    input rst_n,
   /////////////////Read Address
    output [M_AXI_ID_WIDTH-1 : 0]M_AXI_ARID, //主设备（Master）发起的读访问请求的ID（Identifier）
    output [32-1 : 0]M_AXI_ARADDR,
    output [7 : 0]M_AXI_ARLEN, //突发长度，暂定为1
    output [2 : 0]M_AXI_ARSIZE,//位宽;
    output [1 : 0]M_AXI_ARBURST,//=2'b01;
    output M_AXI_ARLOCK,//=1'b0;
    output [3 : 0]M_AXI_ARCACHE,//=4'b10;
    output [2 : 0]M_AXI_ARPROT,//=3'h0;
    output [3 : 0]M_AXI_ARQOS,//=4'h0;
    output M_AXI_ARVALID,
    input M_AXI_ARREADY,
    ///////////////Read Data
    input [M_AXI_ID_WIDTH-1 : 0]M_AXI_RID,
    input [M_AXI_DATA_WIDTH-1 : 0]M_AXI_RDATA,
    input [1 : 0]M_AXI_RRESP,//ignore
    input M_AXI_RLAST,
    input M_AXI_RVALID,
    output M_AXI_RREADY

    );

wire bram_in_we;
wire bram_in_re;
wire [`DW*`Tin-1:0] mul_in;
wire [`log2_bram_depth_in-1:0] bram_in_waddr;
wire [`bram_width_in-1:0] bram_in_wdata;

wire mul_stb;
wire [1:0] mode;

wire [`Tout*`DW-1:0] wire_o;
wire wire_o_stb;

    
BRAM #(
    .ADDR_WIDTH(`log2_bram_depth_in),//11
    .DATA_WIDTH(`bram_width_in),//128
    .DEPTH(`bram_depth_in)//2048
  ) dut_BRAM_IN (
    .clk(clk),
    .re(bram_in_re),       //read enable
    .rd_addr(mul_in),
    .rd_data(M_AXI_RDATA),
    .we(bram_in_we),       //write enable
    .wr_addr(bram_in_waddr),
    .wr_data(bram_in_wdata)
  );

  mul_tree_bf16 dut(
        .clk(clk),
        .rst(~rst_n),
        .mul_ins(mul_in),        
        .mul_stb(mul_stb),  
        .mode (mode),
        .outputs(wire_o),
        .final_output_stbs_1(wire_o_stb)      //output z valid
  );
  
  ctrl u_ctrl();
    
endmodule
