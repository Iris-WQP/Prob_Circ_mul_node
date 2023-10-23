module BRAM_Testbench;
  // �������
  parameter ADDR_WIDTH = 11;
  parameter DATA_WIDTH = 192;
  parameter DEPTH = 2048;

  // �����ź�
  reg clk;
  reg re;
  reg [ADDR_WIDTH-1:0] rd_addr;
  wire [DATA_WIDTH-1:0] rd_data;
  reg we;
  reg [ADDR_WIDTH-1:0] wr_addr;
  reg [DATA_WIDTH-1:0] wr_data;

  // ʵ��������ģ��
  BRAM #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
  ) dut (
    .clk(clk),
    .re(re),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .we(we),
    .wr_addr(wr_addr),
    .wr_data(wr_data)
  );

  // ʱ������
  always #5 clk = ~clk;

  // ��ʼ���ź�
  initial
  begin
    clk = 0;
    re = 0;
    rd_addr = 0;
    we = 0;
    wr_addr = 0;
    wr_data = 0;
    #10;

    // ���ж�д����
    // д������
    we = 1;
    wr_addr = 0;
    wr_data = $random;
    #10;
    we = 0;

    // ��ȡ����
    re = 1;
    rd_addr = 0;
    #5;
    re = 0;

    #100;
    $finish;
  end



endmodule