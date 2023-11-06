`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/12 20:38:07
// Design Name: 
// Module Name: tb_chain
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
module tb_tree();
  wire [(4*`DW-1):0] wire_o;
  wire [3:0] wire_o_stb;
  reg  [1:0] mode;
  reg  clk;
  reg  rst;
  reg   mul_stb;
  reg [(64*6-1):0] memory[15:0];
  reg [(32*4-1):0] mul_in;
  int i;
  int f_in;
  int f_out;
  

initial begin
    f_in = $fopen("D:/PKU/fpu/fpu.srcs/soft_test/stim_inputs.txt","w");
    #50;
    repeat(16)begin
        #10;
        $fdisplay(f_in, "%h", mul_in);
    end
    $fclose(f_in);
end
  
initial begin
    f_out = $fopen("D:/PKU/fpu/fpu.srcs/soft_test/stim_outputs_mode0.txt","w");
    #70;
    repeat(16)begin
        #10;
        $fdisplay(f_out,"%h", wire_o);
    end
    $fclose(f_out);
end

  
initial begin
  $readmemb("D:/PKU/fpu/fpu.srcs/sim_1/imports/multiplier/stim_chain.txt",memory);
  i = 0;
  mul_stb = 0;
  #45;
  repeat(16)begin
       begin
        mul_in = memory[i][(32*4-1):0];
        mul_stb = 1;
       end
       #10 i=i+1;
  end
end
  
  initial
  begin
    rst <= 1'b1;
    
    #50 rst <= 1'b0;
  end

  
  initial
  begin
    #1000000 $finish;
  end


  initial
  begin
    clk <= 1'b0;
    while (1) begin
      #5 clk <= ~clk;
    end
  end




  mul_tree_bf16 dut(
        .clk(clk),
        .rst(rst),
        .mul_ins(mul_in),        
        .mul_stb(mul_stb),  
        .mode (mode),
        .outputs(wire_o),
        .final_output_stbs_1(wire_o_stb)      //output z valid
  );
    
  
  initial
  begin
    rst <= 1'b1;
    mode <= 2'b00;
    #50 rst <= 1'b0;
  end

  
  initial
  begin
    #1000000 $finish;
  end

  
  initial
  begin
    clk <= 1'b0;
    while (1) begin
      #5 clk <= ~clk;
    end
  end
    
    
endmodule
