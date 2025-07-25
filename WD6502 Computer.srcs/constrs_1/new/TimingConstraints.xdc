create_clock -period 10.000 -name master_clock -waveform {0.000 5.000} [get_ports -filter { NAME =~  "*CLOCK*" && DIRECTION == "IN" }]
create_generated_clock -name design_with_logic_probe_i/WDC65C02_Interface/U0/PHI2 -source [get_ports CLOCK] -divide_by 50 [get_pins design_with_logic_probe_i/WDC65C02_Interface/U0/wdc65c02_CLOCK_reg/Q]

set DFLT_INPUT_DELAY 2
set_input_delay -clock master_clock $DFLT_INPUT_DELAY [get_ports {ADDRESS_IN[*]}]
set_input_delay -clock master_clock $DFLT_INPUT_DELAY [get_ports {DATA[*]}]
set_input_delay -clock master_clock $DFLT_INPUT_DELAY [get_ports {I_SWITCHES[*]}]
set_input_delay -clock master_clock $DFLT_INPUT_DELAY [get_ports RWB]
set_input_delay -clock master_clock $DFLT_INPUT_DELAY [get_ports Reset]
set_input_delay -clock master_clock $DFLT_INPUT_DELAY [get_ports SYNCT]

set DFLT_OUTPUT_DELAY 2
set_output_delay -clock master_clock $DFLT_OUTPUT_DELAY [get_ports {PIO_7SEG_SEGMENTS[*]}]
set_output_delay -clock master_clock $DFLT_OUTPUT_DELAY [get_ports {PIO_7SEG_COMMON[*]}]
set_output_delay -clock master_clock $DFLT_OUTPUT_DELAY [get_ports {LED_OUT[*]}]
set_output_delay -clock master_clock $DFLT_OUTPUT_DELAY [get_ports {DATA[*]}]
set_output_delay -clock master_clock $DFLT_OUTPUT_DELAY [get_ports IRQB]
set_output_delay -clock master_clock $DFLT_OUTPUT_DELAY [get_ports PIO_I2C_DATA_STREAMER_SCL]
set_output_delay -clock master_clock $DFLT_OUTPUT_DELAY [get_ports PIO_I2C_DATA_STREAMER_SDA]
set_output_delay -clock master_clock $DFLT_OUTPUT_DELAY [get_ports RESB]
set_output_delay -clock master_clock $DFLT_OUTPUT_DELAY [get_ports PHI2]

# set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
# set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
# connect_debug_port dbg_hub/clk [get_nets CLOCK_IBUF_BUFG]

# set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
# set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
# connect_debug_port dbg_hub/clk [get_nets CLOCK_IBUF_BUFG]
