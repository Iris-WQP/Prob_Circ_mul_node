`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/12 00:38:01
// Design Name: 
// Module Name: mul_3_stage
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
module mul_3_stage_pipe_bf16(
        input [31:0] input_mul,          //inputa[63:32] inputb[31:0]
        input input_mul_stb,  
        output reg s_input_mul_ack,        
        input clk,
        input rst,
        output reg [15:0] z,
        output s_output_z_stb      //output z valid
        );
  
  reg       [7:0] a_m, b_m, z_m; //BF16, 7bits for mantissa, 1bits for covering 1
  reg       [9:0] a_e, b_e, z_e; //BF16, 8bits for exponent, 1bits for covering carry
  reg       z_s, a_s, b_s;
  reg       guard;
  wire      sticky;
  reg       [6:0] sticky_judge;
  reg       z_finish;
  assign sticky = (sticky_judge != 0);
  
  wire      stage1_valid;
  reg       stage2_valid;
  reg       stage3_valid;       
  assign stage1_valid = input_mul_stb;
  assign s_output_z_stb = stage3_valid; 

     
   always @(posedge clk)
/*----------------------------- stage1: load and unpack --------------------------------*/
        begin
          s_input_mul_ack <= 1;
          z_finish <= 0;
          if (input_mul_stb) begin
              a_m <= {1'b1,input_mul[(6+16):16]};
              b_m <= {1'b1,input_mul[6:0]};  //�ں���special case���β��ǰ��1
              a_e <= input_mul[(14+16):(7+16)] - 127;
              b_e <= input_mul[14:7] - 127;
              a_s <= input_mul[15+16];
              b_s <= input_mul[15];
              s_input_mul_ack <= 0;
        end
/*----------------------------- stage2:special case and multiplication --------------------------------*/
        //if a is NaN or b is NaN return NaN 
        if ((a_e == 128 && a_m[6:0] != 0) || (b_e == 128 && b_m[6:0] != 0)) begin
          z_s <= 1;
          z_e <= 255;
          z_m[6] <= 1;
          z_m[5:0] <= 0;
          z_finish <= 1;
        //if a is inf return inf
        end else if (a_e == 128) begin
          z_s <= a_s ^ b_s;
          z_e <= 255;
          z_m[6:0] <= 0;
          z_finish <= 1;
          //if b is zero return NaN
          if (($signed(b_e) == -127) && (b_m[6:0] == 0)) begin
            z_s <= 1;
            z_e <= 255;
            z_m[6] <= 1;
            z_m[5:0] <= 0;
          end
          z_finish <= 1;
        //if b is inf return inf
        end else if (b_e == 128) begin
          z_s <= a_s ^ b_s;
          z_e <= 255;
          z_m[6:0] <= 0;
          //if a is zero return NaN
          if (($signed(a_e) == -127) && (a_m[6:0] == 0)) begin
            z_s <= 1;
            z_e <= 255;
            z_m[6] <= 1;
            z_m[5:0] <= 0;
          end
          z_finish <= 1;
        //if a is zero or subnormal return zero   
        end else if (($signed(a_e) == -127)) begin
          z_s <= a_s ^ b_s;
          z_e <= 0;
          z_m[6:0] <= 0;
          z_finish <= 1;
        //if b is zero or subnormal return zero   
        end else if (($signed(b_e) == -127) ) begin
          z_s <= a_s ^ b_s;
          z_e <= 0;
          z_m[6:0] <= 0;
          z_finish <= 1;
        //normalized number
        end else begin
          z_s <= a_s ^ b_s;
          z_e <= a_e + b_e + 1;         
          {z_m,guard,sticky_judge} <= a_m * b_m;
        end

/*----------------------------- stage3:round and pack --------------------------------*/
      z [15] <= z_s;
      
      if(z_finish==0)begin   //�������������
        if ($signed(z_e) < -126) begin //subnormal
          z <= 16'd0;
        end else if (z_m[7] == 0) begin //�������ֲ���1
          if (guard && (sticky | z_m[0])) begin //round
          z[6:0] <= (z_m << 1) + 1;
              if (z_m == 8'h8f) begin
                z[14:7] <= z_e + 1 + 127;
              end else begin
                z[14:7] <= z_e + 127;
              end
          end else begin
          z[6:0] <= z_m << 1;
          z[14:7] <= z_e + 127;
          end
        end else begin //����������1�����������
          if (guard && (sticky | z_m[0])) begin //round
          z[6:0] <= z_m + 1;     
             if (z_m == 8'hff) begin 
                //���z_mԽ�磬z_m+1��ȫ�㣬z_e+1����
                z[14:7] <= z_e + 1 + 127; 
             end else begin
                z[14:7] <= z_e + 127; 
             end           
          end else begin
          z[6:0] <= z_m;  
          z[14:7] <= z_e + 127; 
          end
        end
      end
      
      else begin //�������������
         z[6:0]  <= z_m[6:0];
         z[14:7] <= z_e;
      end
/*-------------------- valid �źſ��� ---------------------*/
     if (rst == 1) begin
      s_input_mul_ack <= 1'b0;
      stage2_valid <= 1'b0;
      stage3_valid <= 1'b0;
     end else begin
        stage2_valid <= stage1_valid;
        stage3_valid <= stage2_valid;
     end
end
      






//�������ڣ������ź�������Ҫ�������ڣ������ź��赲�����ݴ���

endmodule
