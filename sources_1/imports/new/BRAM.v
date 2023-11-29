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
module BRAM #    //only one bram install all data
             (   parameter ADDR_WIDTH = `log2_bram_depth_in,
                 parameter DATA_WIDTH = 256,
                 parameter      DEPTH = `bram_depth_in)
             (
                input clk,
                //read port
                input re,
                input [ADDR_WIDTH-1:0] rd_addr,
                output reg [DATA_WIDTH-1:0] rd_data,
                output reg rd_data_vld,
                //write port
                input we,     //wr_req_vld
                input [ADDR_WIDTH-1:0] wr_addr,
                input [DATA_WIDTH-1:0] wr_data
                
//                //debug
//                ,output  [DATA_WIDTH-1:0] bram_sample_0,                
//                output  [DATA_WIDTH-1:0] bram_sample_1,                
//                output  [DATA_WIDTH-1:0] bram_sample_254,
//                output  [DATA_WIDTH-1:0] bram_sample_255
                );


    (*ram_style="block"*)reg [DATA_WIDTH-1:0] bram [0:DEPTH-1];
//    assign bram_sample_0 = bram[0];
//    assign bram_sample_1 = bram[1];
//    assign bram_sample_254 = bram[254];
//    assign bram_sample_255 = bram[255];
    
    
    
    //read
    always@(posedge clk)
    begin
        if(re)begin
            rd_data <= bram[rd_addr];
            rd_data_vld <= 1;
        end
        else begin
            rd_data <= 0;
            rd_data_vld <= 0;
        end
    end
    //write
    always @(posedge clk)
    begin
        if(we)begin
            bram[wr_addr]<=wr_data;
        end
    end
endmodule

