create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {input_mul[*]}]
set_input_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports {input_mul[*]}]
set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports input_mul_stb]
set_input_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports input_mul_stb]
set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports rst]
set_input_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports rst]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {state[*]}]
set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports {state[*]}]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {z[*]}]
set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports {z[*]}]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports s_input_mul_ack]
set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports s_input_mul_ack]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports s_output_z_stb]
set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports s_output_z_stb]
