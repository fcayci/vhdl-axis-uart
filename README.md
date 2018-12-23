# vhdl-axis-uart

UART to AXI Stream interface written in VHDL. Receiver side is connected to the master interface and transmitter side is connected to the slave interface.
 
Install GHDL (to simulate) and GTKWave (to see the waveform), add them to the `PATH`, and run `make` and `make simulate` to see the waveforms.

## Files

```
+- makefile          : GHDL / GTKWave simulation
+- rtl/
| -- uart.vhd        : uart top module
| -- uart_rx.vhd     : receiver module
| -- uart_tx.vhd     : transmitter module
+- sim/
| -- tb_uart.vhd     : axi stream interfaces are connected together to test the loopback operation
| -- tb_uart_rx.vhd  : receiver module testbench
| -- tb_uart_tx.vhd  : transmitter module testbench
+- imp/
| -- arty-z7.xdc     : constraints example for Arty-Z7 / Pynq-Z1 boards
```

## Features

* AXI Stream interface with `tdata`, `tvalid` and `tready` signals
* Configurable baudrate (by using the `CLKFREQ` and `BAUDRATE` generics)
* Configurable data width (by using the `DATA_WIDTH` generic)
* Configurable stop width (by using the `STOP_WIDTH` generic)
* Transmission only supports stop bits 1 and 2. 1.5 is not supported
* Receive side will only wait 1 bit for stop bit independent of the configuration
* Received data will get overwritten with the incoming data even if it is not read by the master
* Parity is not implemented
