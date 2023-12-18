`define bram_in_width 256
`define big_interface 1     //(`bram_in_width==256)
//`define bram_in_width 128
//`define big_interface 0     //1(`bram_in_width==128)
`define DW 16     //BF16
`define Tin 8
`define Tout 4
`define bram_depth_in 1024  //512 512 256
`define log2_bram_depth_in 10
`define small_bram_depth_in 256
`define small_log2_bram_depth_in 8
`define bram_width_in `DW*`Tin //128