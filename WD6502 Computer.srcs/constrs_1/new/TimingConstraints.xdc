create_clock -period 10.000 -name master_clock -waveform {0.000 5.000} [get_ports -filter { NAME =~  "*CLOCK*" && DIRECTION == "IN" }]
create_generated_clock -name design_with_logic_probe_i/WDC65C02_Interface/U0/PHI2 -source [get_ports CLOCK] -divide_by 50 [get_pins design_with_logic_probe_i/WDC65C02_Interface/U0/wdc65c02_CLOCK_reg/Q]

set DFLT_INPUT_DELAY -10.0
set CPU_65C02_CLOCK {design_with_logic_probe_i/WDC65C02_Interface/U0/PHI2}

set_input_delay -clock $CPU_65C02_CLOCK $DFLT_INPUT_DELAY [all_inputs]

set DFLT_OUTPUT_DELAY 1.0
set_output_delay -clock $CPU_65C02_CLOCK $DFLT_OUTPUT_DELAY [get_ports {PIO_7SEG_SEGMENTS[*]}]
set_output_delay -clock $CPU_65C02_CLOCK $DFLT_OUTPUT_DELAY [get_ports {PIO_7SEG_COMMON[*]}]
set_output_delay -clock $CPU_65C02_CLOCK $DFLT_OUTPUT_DELAY [get_ports {LED_OUT[*]}]
set_output_delay -clock $CPU_65C02_CLOCK $DFLT_OUTPUT_DELAY [get_ports {DATA[*]}]
set_output_delay -clock $CPU_65C02_CLOCK $DFLT_OUTPUT_DELAY [get_ports IRQB]
set_output_delay -clock $CPU_65C02_CLOCK $DFLT_OUTPUT_DELAY [get_ports PIO_I2C_DATA_STREAMER_SCL]
set_output_delay -clock $CPU_65C02_CLOCK $DFLT_OUTPUT_DELAY [get_ports PIO_I2C_DATA_STREAMER_SDA]
set_output_delay -clock $CPU_65C02_CLOCK $DFLT_OUTPUT_DELAY [get_ports RESB]

set_false_path -from [get_clocks master_clock] \  
       -to [get_clocks $CPU_65C02_CLOCK] 

set_false_path -from [get_clocks $CPU_65C02_CLOCK] \  
       -to [get_clocks master_clock] 
# set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
# set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
# connect_debug_port dbg_hub/clk [get_nets CLOCK_IBUF_BUFG]

# set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
# set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
# connect_debug_port dbg_hub/clk [get_nets CLOCK_IBUF_BUFG]
