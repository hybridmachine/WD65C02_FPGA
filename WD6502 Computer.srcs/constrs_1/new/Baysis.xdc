# All ports 3.3volt
# set_property IOSTANDARD LVCMOS33 [get_ports BE]
# set_property IOSTANDARD LVCMOS33 [get_ports CLOCK]
# set_property IOSTANDARD LVCMOS33 [get_ports IRQB]
# Address ports on the right of the board (when VGA port to the top of board)
set_property PACKAGE_PIN A14 [get_ports {ADDRESS[0]}]
set_property PACKAGE_PIN A15 [get_ports {ADDRESS[1]}]
set_property PACKAGE_PIN A16 [get_ports {ADDRESS[2]}]
set_property PACKAGE_PIN A17 [get_ports {ADDRESS[3]}]
set_property PACKAGE_PIN B15 [get_ports {ADDRESS[4]}]
set_property PACKAGE_PIN C15 [get_ports {ADDRESS[5]}]
set_property PACKAGE_PIN B16 [get_ports {ADDRESS[6]}]
set_property PACKAGE_PIN C16 [get_ports {ADDRESS[7]}]
set_property PACKAGE_PIN K17 [get_ports {ADDRESS[8]}]
set_property PACKAGE_PIN L17 [get_ports {ADDRESS[9]}]
set_property PACKAGE_PIN M18 [get_ports {ADDRESS[10]}]
set_property PACKAGE_PIN M19 [get_ports {ADDRESS[11]}]
set_property PACKAGE_PIN N17 [get_ports {ADDRESS[12]}]
set_property PACKAGE_PIN P17 [get_ports {ADDRESS[13]}]
set_property PACKAGE_PIN P18 [get_ports {ADDRESS[14]}]
set_property PACKAGE_PIN R18 [get_ports {ADDRESS[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ADDRESS[15]}]
# Data port on top left of Basys board
set_property PACKAGE_PIN G3 [get_ports {DATA[0]}]
set_property PACKAGE_PIN G2 [get_ports {DATA[1]}]
set_property PACKAGE_PIN H2 [get_ports {DATA[2]}]
set_property PACKAGE_PIN J2 [get_ports {DATA[3]}]
set_property PACKAGE_PIN K2 [get_ports {DATA[4]}]
set_property PACKAGE_PIN L2 [get_ports {DATA[5]}]
set_property PACKAGE_PIN H1 [get_ports {DATA[6]}]
set_property PACKAGE_PIN J1 [get_ports {DATA[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[7]}]

# FPGA 100mhz clock
# set_property PACKAGE_PIN W5 [get_ports CLOCK]

# CPU clock
# set_property PACKAGE_PIN N1 [get_ports PHI2]
# set_property PACKAGE_PIN N2 [get_ports RWB]
# set_property PACKAGE_PIN M1 [get_ports SYNC]
# set_property PACKAGE_PIN M2 [get_ports RDY]
# set_property PACKAGE_PIN M3 [get_ports RESB]
# set_property PACKAGE_PIN L3 [get_ports BE]

# set_property IOSTANDARD LVCMOS33 [get_ports PHI2]
# set_property IOSTANDARD LVCMOS33 [get_ports RWB]
# set_property IOSTANDARD LVCMOS33 [get_ports RDY]
# set_property IOSTANDARD LVCMOS33 [get_ports RESB]
# set_property IOSTANDARD LVCMOS33 [get_ports PHI2]
# set_property IOSTANDARD LVCMOS33 [get_ports RWB]
# set_property IOSTANDARD LVCMOS33 [get_ports RDY]
# set_property IOSTANDARD LVCMOS33 [get_ports BE]

set_property PACKAGE_PIN U16 [get_ports {PIO_LED_OUT[0]}]
set_property PACKAGE_PIN E19 [get_ports {PIO_LED_OUT[1]}]
set_property PACKAGE_PIN U19 [get_ports {PIO_LED_OUT[2]}]
set_property PACKAGE_PIN V19 [get_ports {PIO_LED_OUT[3]}]
set_property PACKAGE_PIN W18 [get_ports {PIO_LED_OUT[4]}]
set_property PACKAGE_PIN U15 [get_ports {PIO_LED_OUT[5]}]
set_property PACKAGE_PIN U14 [get_ports {PIO_LED_OUT[6]}]
set_property PACKAGE_PIN V14 [get_ports {PIO_LED_OUT[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PIO_LED_OUT[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PIO_LED_OUT[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PIO_LED_OUT[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PIO_LED_OUT[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PIO_LED_OUT[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PIO_LED_OUT[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PIO_LED_OUT[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PIO_LED_OUT[7]}]

