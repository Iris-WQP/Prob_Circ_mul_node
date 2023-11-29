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
    parameter M_AXI_DATA_WIDTH = 256 
)
(
    input clk,
    input rst_n,
   /////////////////Read Address
    output [M_AXI_ID_WIDTH-1 : 0]M_AXI_ARID, //主设备（Master）发起的读访问请求的ID（Identifier）
    output [32-1 : 0]M_AXI_ARADDR,
    output [7 : 0]M_AXI_ARLEN, 
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
    output M_AXI_RREADY,


    //AW channel
    output [M_AXI_ID_WIDTH-1 : 0]M_AXI_AWID,//write addr
    output [32-1 : 0]M_AXI_AWADDR,
    output [7 : 0]M_AXI_AWLEN,
    output [2 : 0]M_AXI_AWSIZE,//=clogb2((M_AXI_DATA_WIDTH/8)-1);
    output [1 : 0]M_AXI_AWBURST,//=2'b01;
    output  M_AXI_AWLOCK,//1'b0;
    output [3 : 0]M_AXI_AWCACHE,//=4'b10
    output [2 : 0]M_AXI_AWPROT,//=3'h0;
    output [3 : 0]M_AXI_AWQOS,//=4'h0;
    output M_AXI_AWVALID,
    input M_AXI_AWREADY,
    output [M_AXI_DATA_WIDTH-1 : 0]M_AXI_WDATA,
    output [M_AXI_DATA_WIDTH/8-1 : 0]M_AXI_WSTRB,
    output M_AXI_WLAST,
    output M_AXI_WVALID,
    input M_AXI_WREADY,
    input [M_AXI_ID_WIDTH-1 : 0]M_AXI_BID,//ignore
    input [1 : 0] M_AXI_BRESP,//ignore
    input M_AXI_BVALID,//Bvalid and Bread means a a write response.
    output M_AXI_BREADY//Bvalid and Bread means a a write response.
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

wire sync_async_rst_n;
sync_async_reset u_sync_async_reset
(
    .clk(clk),
    .rst_n(rst_n),
    .sync_async_rst_n(sync_async_rst_n)
);
    
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

module sync_async_reset
(
    input clk,
    input rst_n,
    output sync_async_rst_n
);
reg rst_s1_n;
reg rst_s2_n;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rst_s1_n <= 1'b0;
        rst_s2_n <= 1'b0;
    end
    else begin
        rst_s1_n <= 1'b1;
        rst_s2_n <= rst_s1_n;
    end
end

endmodule