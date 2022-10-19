-- author: Furkan Cayci, 2018
-- description: uart transmit interface

library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
    generic (
        CLKFREQ    : integer := 125E6;
        BAUDRATE   : integer := 115200;
        DATA_WIDTH : integer := 8;
        PARITY     : string  := "NONE"; -- NONE, EVEN, ODD
        STOP_WIDTH : integer := 1
    );
    port (
        clk : in  std_logic;
        -- external interface signals
        txd : out std_logic;
        -- axi stream interface
        s_axis_tvalid : in  std_logic;
        s_axis_tdata  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        s_axis_tready : out std_logic
    );
end uart_tx;

architecture rtl of uart_tx is
    signal tready : std_logic := '0';
    constant M : integer := CLKFREQ / BAUDRATE;
begin

    s_axis_tready <= tready;

    main: process(clk) is
        type state_type is (st_idle, st_start, st_data, st_parity, st_stop);
        variable state : state_type := st_idle;
        variable txbuf : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        variable bitcount : integer range 0 to DATA_WIDTH-1 := 0;
        variable clkcount : integer range 0 to M-1 := 0;
        variable par : std_logic := '0';
    begin
        if rising_edge(clk) then
            txd <= '1';
            tready <= '0';

            case state is
                when st_idle =>
                    tready <= '1';
                    if s_axis_tvalid = '1' then
                        txbuf := s_axis_tdata;
                        state := st_start;
                    end if;

                when st_start =>
                    txd <= '0';
                    if clkcount = M-1 then
                        clkcount := 0;
                        state := st_data;
                    else
                        clkcount := clkcount + 1;
                    end if;

                when st_data =>
                    txd <= txbuf(bitcount);
                    if clkcount = M-1 then
                        clkcount := 0;

                        if bitcount = DATA_WIDTH-1 then
                            bitcount := 0;
                            if PARITY = "NONE" then
                                state := st_stop;
                            else
                                par := xor txbuf;
                                if PARITY = "ODD" then
                                    par := par xor '1';
                                else
                                    par := par xor '0';
                                end if;
                                state := st_parity;
                            end if;
                        else
                            bitcount := bitcount + 1;
                        end if;
                    else
                        clkcount := clkcount + 1;
                    end if;

                when st_parity =>
                    txd <= par;
                    if clkcount = M-1 then
                        clkcount := 0;
                        par := '0';
                        state := st_stop;
                    else
                        clkcount := clkcount + 1;
                    end if;

                when st_stop =>
                    txd <= '1';
                    if clkcount = M-1 then
                        clkcount := 0;
                        if bitcount = STOP_WIDTH-1 then
                            bitcount := 0;
                            state := st_idle;
                        else
                            bitcount := bitcount + 1;
                        end if;
                    else
                        clkcount := clkcount + 1;
                    end if;
            end case;
         end if;
    end process;

end rtl;
