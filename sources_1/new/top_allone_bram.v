`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/21 15:26:51
// Design Name: 
// Module Name: top_allone_bram
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

module top_allone_bram_ctrl(
     input clk,
     input rst,
     input [255:0] interface_in,
     input input_vld,
     output reg input_ready,
     input [1:0] mode,
     output [127:0] interface_out,
     output output_vld,
     output reg [1:0] state,
     output reg stop
    );
    

parameter data_in = 2'd0,
             calculate = 2'd1,
             data_out = 2'd2,
             stop_work = 2'd3;
    
wire bram_in_we;
wire bram_in_re;
wire [255:0]bram_read_data;
wire [127:0] mul_in;
wire mul_stb;
reg fi_read;
reg [`log2_bram_depth_in-1:0] bram_in_waddr;
reg [`log2_bram_depth_in-1:0] bram_in_raddr;
assign bram_in_we = input_vld&input_ready&(state==data_in);
assign bram_in_re = (fi_read&&(state==calculate));
assign mul_in = fi_read? bram_read_data[127:0]:bram_read_data[255:128];
//wire [`bram_width_in-1:0] bram_in_wdata;



always@(posedge clk)begin
    if(rst)begin
        bram_in_waddr <= 'b0;
        bram_in_raddr <= 'b0;
        state <= data_in;
        input_ready <= 1'b1;
        fi_read <= 1'b1;
    end
    else if(input_vld&input_ready&(state==data_in)) begin 
        if (bram_in_waddr==`bram_depth_in-1) begin
            bram_in_waddr <= 'b0;
            state <= calculate;
            input_ready <= 1'b0;
        end
        else begin
            bram_in_waddr <= bram_in_waddr+1'b1;
        end
    end
    else if(state==calculate)begin
        fi_read <= ~fi_read;
        if(fi_read)begin
            if(bram_in_raddr == `bram_depth_in-1) begin
                bram_in_raddr <= 1'b0;
                state <= data_in;
            end
            else begin
                bram_in_raddr <= bram_in_raddr+1'b1;
            end
        end
    end
end

reg [10:0] cnt_output;
always@(posedge clk)begin
    if(rst) begin
         cnt_output<=0;
         stop <= 0;
    end
    else begin
        if (output_vld==1)begin
            cnt_output <= cnt_output+1;
        end
        if( (cnt_output==2048) && (mode==2'd3) ) stop <= 1;
        else if( (cnt_output==2048) && ((mode==2'd2)||(mode==2'd1)) ) stop <= 1;
        else if( (cnt_output==512) && (mode==2'd0) ) stop <= 1;
    end
end
   
BRAM #(
    .ADDR_WIDTH(`log2_bram_depth_in),
    .DATA_WIDTH (256),
    .DEPTH (`bram_depth_in)
  ) dut_BRAM_IN (
    .clk(clk),
    .re(bram_in_re),       //read enable
    .rd_addr(bram_in_raddr),
    .rd_data(bram_read_data),
    .rd_data_vld(mul_stb),
    .we(bram_in_we),       //write enable
    .wr_addr(bram_in_waddr),
    .wr_data(interface_in)
  );

mul_tree_bf16 dut(
        .clk(clk),
        .rst(rst),
        .mul_ins(mul_in),        
        .mul_stb(mul_stb),  
        .mode (mode),
        .outputs(interface_out),
        .final_output_stbs_1(output_vld)      //output z valid
);
    
endmodule  

//OUT_BRAM #(
//    .ADDR_WIDTH(`log2_bram_depth_in),//11
//    .IN_DATA_WIDTH (256),
//    .OUT_DATA_WIDTH (128),
//    .DEPTH (`bram_depth_in)//2048
//  ) dut_BRAM_OUT (
//    .clk(clk),
//    .re(bram_in_re),       //read enable
//    .rd_addr(mul_in),
//    .rd_data(interface_in),
//    .we(bram_in_we),       //write enable
//    .wr_addr(bram_in_waddr),
//    .wr_data(interface_in)
//  );




