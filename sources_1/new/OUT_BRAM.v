`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wuqiuping
// 
// Create Date: 2023/09/26 11:32:25
// Design Name: 
// Module Name: BRAM
// Project Name: Probability Circuits
// Target Devices: Zedboard
// Tool Versions: 2018.3
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
module OUT_BRAM #    //only one bram install all data
             (   parameter ADDR_WIDTH = `log2_bram_depth_in,//11
                 parameter IN_DATA_WIDTH = 256,
                 parameter OUT_DATA_WIDTH = 128,
                 parameter      DEPTH = `bram_depth_in)//2048
             (
                input clk,
                //read port
                input re,
                input [ADDR_WIDTH-1:0] rd_addr,
                output reg [OUT_DATA_WIDTH-1:0] rd_data,
                //write port
                input we,     //wr_req_vld
                input [ADDR_WIDTH-1:0] wr_addr,
                input [IN_DATA_WIDTH-1:0] wr_data
                );

    (*ram_style="block"*)reg [OUT_DATA_WIDTH-1:0] bram [0:DEPTH-1];
    //read
    always@(posedge clk)
    begin
        if(re)
            rd_data <= bram[rd_addr];
        else
            rd_data <= 0;
    end
    //write
    always @(posedge clk)
    begin
        if(we)
            bram[wr_addr]<=wr_data[127:0];
            bram[wr_addr+1] <= wr_data[255:128];
    end
endmodule

