`timescale 1ns / 1ps
//combinational logic
module bf16_adder1(     
        input [15:0] a, 
        input a_vld,
        
        input [15:0] b,
        input b_vld,
        
        output reg [15:0] z,
        output z_vld
    );
    
    assign z_vld = a_vld & b_vld;

    wire a_s, b_s, z_s;
    wire [9:0] a_e, b_e;
    wire [10:0] a_extend_m, b_extend_m;
    wire [10:0] a_shift_m, b_shift_m;
    wire a_e_bigger, b_e_bigger, a_m_bigger;
    wire [7:0] e_diff;
    wire [7:0] z_e_temp; //z_e before normalization
    reg [7:0] z_e_tp; //z_e before round
    reg [10:0] z_e;
    wire [11:0] sum_fraction_tmp;
    wire [11:0] sum_fraction;
    reg [7:0] unrounded_fraction;
    reg [7:0] rounded_fraction;
    wire [3:0] lead_zero_cnt;
    reg guard, round_bit, sticky;


/*--------------------- step0: handle subnormal case for mantissa ---------------------------*/
    assign a_s = a[15];
    assign b_s = b[15];
    assign a_e = a[14:7];
    assign b_e = b[14:7];
    assign a_extend_m = (a_e == 8'd0) ? {1'b0, a[6:0], 3'd0} : {1'b1, a[6:0], 3'd0};
    assign b_extend_m = (b_e == 8'd0) ? {1'b0, b[6:0], 3'd0} : {1'b1, b[6:0], 3'd0};
    assign a_m_bigger = (a_extend_m > b_extend_m);

/*------------------ step1: compare exponent, shift mantissa ------------------*/
//handle exponent
    assign a_e_bigger = (a_e > b_e);
    assign b_e_bigger = (a_e < b_e); //in case of equal
    assign z_e_temp = (a_e_bigger) ? a_e : b_e;
    assign e_diff = (a_e_bigger) ? (a_e - b_e) : (b_e - a_e);

//shift the mantissa of the smaller number
    assign a_shift_m = (a_e_bigger) ? a_extend_m : (a_extend_m >> e_diff);
    assign b_shift_m = (b_e_bigger) ? b_extend_m : (b_extend_m >> e_diff);
    
/*-------------- step2: add mantissa, handle carry and lead zero ------------------*/
    assign z_s = a_e_bigger ? a_s
                    : b_e_bigger ? b_s
                    : a_m_bigger ? a_s
                    : b_s;
    assign sum_fraction_tmp = (a_s == b_s) ? (a_shift_m + b_shift_m) 
                      : a_m_bigger ? (a_shift_m - b_shift_m)
                      : (b_shift_m - a_shift_m);
    assign lead_zero_cnt = (sum_fraction_tmp[10] == 1) ? 0
                    : (sum_fraction_tmp[9] == 1) ? 1
                    : (sum_fraction_tmp[8] == 1) ? 2
                    : (sum_fraction_tmp[7] == 1) ? 3
                    : (sum_fraction_tmp[6] == 1) ? 4
                    : (sum_fraction_tmp[5] == 1) ? 5
                    : (sum_fraction_tmp[4] == 1) ? 6
                    : (sum_fraction_tmp[3] == 1) ? 7
                    : (sum_fraction_tmp[2] == 1) ? 8
                    : (sum_fraction_tmp[1] == 1) ? 9
                    : (sum_fraction_tmp[0] == 1) ? 10
                    : 11;
    assign sum_fraction = sum_fraction_tmp << lead_zero_cnt;

always @(*) begin
    if(sum_fraction[11])begin
        unrounded_fraction = sum_fraction[10:4];
        guard = sum_fraction[3];
        round_bit = sum_fraction[2];
        sticky = sum_fraction[1] | sum_fraction[0];
        z_e_tp = z_e_temp - lead_zero_cnt + 1;
    end else begin
        unrounded_fraction = sum_fraction[9:3];
        guard = sum_fraction[2];
        round_bit = sum_fraction[1];
        sticky = sum_fraction[0];
        z_e_tp = z_e_temp - lead_zero_cnt;
    end

    //round
    if (guard && (round_bit | sticky | unrounded_fraction[0])) begin
      rounded_fraction <= unrounded_fraction + 1;
      if (unrounded_fraction == 24'hffffff) begin
        z_e <=z_e_tp + 1;
      end else begin
        z_e <= z_e_tp;
      end
    end
  end

/*------------------ step3: handle special cases ------------------*/
// //judge NaN and inf
//     assign if_nan = (a_e == 128 && a_extend_m[6:0] != 0) || (b_e == 128 && b_extend_m[6:0] != 0)
//     assign if_inf = (a_e == 128 && a_extend_m[6:0] == 0) || (b_e == 128 && b_extend_m[6:0] == 0)

always @(*) begin
    //if a is NaN or b is NaN return NaN 
    if ((a_e == 128 && a_extend_m[6:0] != 0) || (b_e == 128 && b_extend_m[6:0] != 0)) begin
        z[15] = 1;
        z[14:7] = 255;
        z[6] = 1;
        z[5:0] = 0;
    //if a is inf 
    end else if (a_e == 128) begin
        z[15] = a_s;
        z[14:7] = 255;
        //if a is inf and signs don't match return nan
        if ((b_e == 128) && (a_s != b_s)) begin
            z[6] = 1;
            z[5:0] = 0;
        //if a is inf and signs match return inf
        end else begin
            z[6:0] = 0;
        end
    //if b is inf
    end else if (b_e == 128) begin
        z[15] = b_s;
        z[14:7] = 255;
        z[6:0] = 0;
    // //both zero
    // end else if ((($signed(a_e) == -127) && (a_m == 0)) && (($signed(b_e) == -127) && (b_m == 0))) begin
    //     z[15] = a_s & b_s;
    //     z[14:0] = b[14:0];
    // //if b is zero return a
    // end else if (($signed(b_e) == -127) && (b_m == 0)) begin
    //     z = a;
    // //if a is zero return b
    // end else if (($signed(a_e) == -127) && (a_m == 0)) begin
    //     z = b;
    end else begin
        z[15] = z_s;
        //if overflow occurs, return inf
        if (z_e > 254) begin
          z[6 : 0] = 0;
          z[14 : 7] = 255;
        end else begin
          z[6 : 0] = rounded_fraction[6:0];
          z[14 : 7] = z_e[7:0];
        end
    end
end


endmodule
