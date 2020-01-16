library ieee;
use ieee.std_logic_1164.all;

entity toplevel is
    port(
        clk : in  std_ulogic;
        rst : in  std_ulogic;

        uart0_txd : out std_ulogic;
        uart0_rxd : in  std_ulogic;

        led_a : out std_ulogic;
        led_b : out std_ulogic;
        led_c : out std_ulogic
        );
end entity toplevel;

architecture behaviour of toplevel is
    signal led : std_ulogic := '0';
    signal counter : integer range 0 to 50000000;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
            if counter = 50000000 then
                led <= not led;
                counter <= 0;
            end if;
        end if;
    end process;

    led_a <= led;
    led_b <= not uart0_rxd;
    led_c <= '1';

    -- Wrap TX to RX
    uart0_txd <= uart0_rxd;
end architecture behaviour;
