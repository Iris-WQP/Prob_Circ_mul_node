module test_bench();
reg clk;
reg rst;
  
  wire   [31:0] wire_39069600;
  wire   wire_39069600_stb;
  wire   wire_39069600_ack;
  wire   [31:0] wire_39795024;
  wire   wire_39795024_stb;
  wire   wire_39795024_ack;
  wire   [31:0] wire_39795168;
  wire   wire_39795168_stb;
  wire   wire_39795168_ack;
  wire  [3:0] state;
  file_reader_a file_reader_a_39796104(
    .clk(clk),
    .rst(rst),
    .output_z(wire_39069600),
    .output_z_stb(wire_39069600_stb),
    .output_z_ack(wire_39069600_ack));
  file_reader_b file_reader_b_39759816(
    .clk(clk),
    .rst(rst),
    .output_z(wire_39795024),
    .output_z_stb(wire_39795024_stb),
    .output_z_ack(wire_39795024_ack));
  file_writer file_writer_39028208(
    .clk(clk),
    .rst(rst),
    .input_a(wire_39795168),
    .input_a_stb(wire_39795168_stb),
    .input_a_ack(wire_39795168_ack));
  multiplier multiplier_39759952(
    .clk(clk),
    .rst(rst),
    .input_a(wire_39069600),
    .input_a_stb(wire_39069600_stb),
    .input_a_ack(wire_39069600_ack),
    .input_b(wire_39795024),
    .input_b_stb(wire_39795024_stb),
    .input_b_ack(wire_39795024_ack),
    .output_z(wire_39795168),
    .output_z_stb(wire_39795168_stb),
    .output_z_ack(wire_39795168_ack),
    .state(state));
    
  
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
    
    
endmodule
