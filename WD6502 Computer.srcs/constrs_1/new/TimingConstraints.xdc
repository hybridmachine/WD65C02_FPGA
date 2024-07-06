create_clock -period 10.000 -name master_clock -waveform {0.000 5.000} [get_ports -filter { NAME =~  "*CLOCK*" && DIRECTION == "IN" }]
create_generated_clock -name design_with_logic_probe_i/WDC65C02_Interface/U0/PHI2 -source [get_ports CLOCK] -divide_by 50 [get_pins design_with_logic_probe_i/WDC65C02_Interface/U0/wdc65c02_CLOCK_reg/Q]

# set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
# set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
# connect_debug_port dbg_hub/clk [get_nets CLOCK_IBUF_BUFG]

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets CLOCK_IBUF_BUFG]
