# vhdl-axis-uart

UART to AXI Stream interface written in VHDL.

source files are in the [rtl](rtl/) directory

```
uart_rx.vhd : receiver module
uart_tx.vhd : transmitter module
uart.vhd    : glue logic
```

testbench files are in the [sim](sim/) directory

```
tb_uart_rx.vhd       : receiver module testbench
tb_uart_tx.vhd       : transmitter module testbench
tb_uart_rt_lb.vhd    : rx and tx ports are connected together
                       to test loopback operation
tb_uart_axis_lb.vhd  : axi master ans slave ports are connected together
                       to test loopback operation
```

[impl](impl/) folder contains an example constraints file for Arty-Z7 board.

`makefile` is given for GHDL simulation support. Install GHDL (to simulate) and optionally GTKWave (to see the waveform), add them to the `PATH`, and run `make` and `make simulate`.

## Properties

- AXI Stream interface with `tdata`, `tvalid` and `tready` signals
- Configurable baudrate (by using the `CLKFREQ` and `BAUDRATE` generics)
- Configurable data width (by using the `DATA_WIDTH` generic)
- Configurable stop width (by using the `STOP_WIDTH` generic)
- Received data will get overwritten with the incoming data even if it is not read by the master (no tready)
- Parity logic is added, but not implementation tested
- Stop only supports integers (1, 2)
