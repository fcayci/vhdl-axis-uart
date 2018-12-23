## vhdl-uart example pinout for Arty-Z20, Pynq-Z1 and Pynq-Z2 boards

## Clock signal 125 MHz
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

## uart ports through headers
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { rxd }]; #IO_L23N_T3_34 Sch=CK_IO12/ar[12]
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { txd }]; #IO_L23P_T3_34 Sch=CK_IO13/ar[13]