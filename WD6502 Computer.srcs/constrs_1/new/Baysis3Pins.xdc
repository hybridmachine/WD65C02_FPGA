set_property PACKAGE_PIN W5 [get_ports CLOCK]
set_property PACKAGE_PIN N1 [get_ports PHI2]

set_property PACKAGE_PIN W7 [get_ports {PIO_7SEG_SEGMENTS[0]}]
set_property PACKAGE_PIN W6 [get_ports {PIO_7SEG_SEGMENTS[1]}]
set_property PACKAGE_PIN U8 [get_ports {PIO_7SEG_SEGMENTS[2]}]
set_property PACKAGE_PIN V8 [get_ports {PIO_7SEG_SEGMENTS[3]}]
set_property PACKAGE_PIN U5 [get_ports {PIO_7SEG_SEGMENTS[4]}]
set_property PACKAGE_PIN V5 [get_ports {PIO_7SEG_SEGMENTS[5]}]
set_property PACKAGE_PIN U7 [get_ports {PIO_7SEG_SEGMENTS[6]}]
set_property PACKAGE_PIN V7 [get_ports {PIO_7SEG_SEGMENTS[7]}]

set_property PACKAGE_PIN U16 [get_ports {LED_OUT[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED_OUT[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED_OUT[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED_OUT[3]}]
set_property PACKAGE_PIN W18 [get_ports {LED_OUT[4]}]
set_property PACKAGE_PIN U15 [get_ports {LED_OUT[5]}]
set_property PACKAGE_PIN U14 [get_ports {LED_OUT[6]}]
set_property PACKAGE_PIN V14 [get_ports {LED_OUT[7]}]

set_property PACKAGE_PIN A14 [get_ports {ADDRESS_IN[0]}]
set_property PACKAGE_PIN A15 [get_ports {ADDRESS_IN[1]}]
set_property PACKAGE_PIN A16 [get_ports {ADDRESS_IN[2]}]
set_property PACKAGE_PIN A17 [get_ports {ADDRESS_IN[3]}]
set_property PACKAGE_PIN B15 [get_ports {ADDRESS_IN[4]}]
set_property PACKAGE_PIN C15 [get_ports {ADDRESS_IN[5]}]
set_property PACKAGE_PIN B16 [get_ports {ADDRESS_IN[6]}]
set_property PACKAGE_PIN C16 [get_ports {ADDRESS_IN[7]}]
set_property PACKAGE_PIN K17 [get_ports {ADDRESS_IN[8]}]
set_property PACKAGE_PIN L17 [get_ports {ADDRESS_IN[9]}]
set_property PACKAGE_PIN M18 [get_ports {ADDRESS_IN[10]}]
set_property PACKAGE_PIN M19 [get_ports {ADDRESS_IN[11]}]
set_property PACKAGE_PIN N17 [get_ports {ADDRESS_IN[12]}]
set_property PACKAGE_PIN P17 [get_ports {ADDRESS_IN[13]}]
set_property PACKAGE_PIN P18 [get_ports {ADDRESS_IN[14]}]
set_property PACKAGE_PIN R18 [get_ports {ADDRESS_IN[15]}]

set_property PACKAGE_PIN G3 [get_ports {DATA[0]}]
set_property PACKAGE_PIN G2 [get_ports {DATA[1]}]
set_property PACKAGE_PIN H2 [get_ports {DATA[2]}]
set_property PACKAGE_PIN J2 [get_ports {DATA[3]}]
set_property PACKAGE_PIN K2 [get_ports {DATA[4]}]
set_property PACKAGE_PIN L2 [get_ports {DATA[5]}]
set_property PACKAGE_PIN H1 [get_ports {DATA[6]}]
set_property PACKAGE_PIN J1 [get_ports {DATA[7]}]

set_property PACKAGE_PIN N2 [get_ports RESB]
set_property PACKAGE_PIN M1 [get_ports SYNC]
set_property PACKAGE_PIN M2 [get_ports RWB]
set_property PACKAGE_PIN M3 [get_ports RDY]
set_property PACKAGE_PIN L3 [get_ports IRQB]
set_property PACKAGE_PIN J3 [get_ports PIO_I2C_DATA_STREAMER_SCL]
set_property PACKAGE_PIN K3 [get_ports PIO_I2C_DATA_STREAMER_SDA]
set_property PACKAGE_PIN U18 [get_ports Reset]
set_property PACKAGE_PIN R2 [get_ports SingleStep]

set_property PACKAGE_PIN U2 [get_ports {PIO_7SEG_COMMON[0]}]
set_property PACKAGE_PIN U4 [get_ports {PIO_7SEG_COMMON[1]}]
set_property PACKAGE_PIN V4 [get_ports {PIO_7SEG_COMMON[2]}]
set_property PACKAGE_PIN W4 [get_ports {PIO_7SEG_COMMON[3]}]

set_property PACKAGE_PIN W19 [get_ports {I_SWITCHES[0]}] # BTN Left
set_property PACKAGE_PIN T17 [get_ports {I_SWITCHES[1]}] # BTN Right
set_property PACKAGE_PIN T18 [get_ports {I_SWITCHES[2]}] # BTN Up
set_property PACKAGE_PIN U17 [get_ports {I_SWITCHES[3]}] # BTN Down
set_property PACKAGE_PIN U18 [get_ports {I_SWITCHES[4]}] # BTN Center

# All ports 3.3volt
# FPGA 100mhz clock
set_property IOSTANDARD LVCMOS33 [get_ports CLOCK]

# Address ports on the right of the board (when VGA port to the top of board)
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS_IN[*]}]

# Data port on top left of Basys board
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[*]}]
set_property PULLTYPE PULLDOWN [get_ports {DATA[*]}]

# 65C02 clock
set_property IOSTANDARD LVCMOS33 [get_ports PHI2]

# 65C02 Control Pins
# BE is tied manually to high for now, not used in design at this time
# set_property PACKAGE_PIN L1 [get_ports BE]
# set_property IOSTANDARD LVCMOS33 [get_ports BE]
set_property IOSTANDARD LVCMOS33 [get_ports RESB]

set_property IOSTANDARD LVCMOS33 [get_ports SYNC]

set_property IOSTANDARD LVCMOS33 [get_ports RWB]

set_property IOSTANDARD LVCMOS33 [get_ports RDY]

# Processor interrupt controls
set_property IOSTANDARD LVCMOS33 [get_ports IRQB]

set_property IOSTANDARD LVCMOS33 [get_ports PIO_I2C_DATA_STREAMER_SDA]
set_property PULLTYPE PULLUP [get_ports PIO_I2C_DATA_STREAMER_SDA]

set_property IOSTANDARD LVCMOS33 [get_ports PIO_I2C_DATA_STREAMER_SCL]

# Set to center directional button on board
set_property IOSTANDARD LVCMOS33 [get_ports Reset]

# Connected to SW15 (Bottom left of board when VGA port is facing top)
set_property IOSTANDARD LVCMOS33 [get_ports SingleStep]

# Status LEDs on FPGA board
set_property IOSTANDARD LVCMOS33 [get_ports {LED_OUT[*]}]

# 7 segment display common anodes
set_property IOSTANDARD LVCMOS33 [get_ports {PIO_7SEG_COMMON[*]}]

# 7 segment display segment cathondes
# CA - Top
set_property IOSTANDARD LVCMOS33 [get_ports {PIO_7SEG_SEGMENTS[*]}]

