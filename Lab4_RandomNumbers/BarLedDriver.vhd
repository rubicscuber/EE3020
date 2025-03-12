library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BarLedDriver is
    port(
        binary4Bit : in std_logic_vector(3 downto 0);
        outputEN : in std_logic;

        leds : out std_logic_vector(15 downto 0)
    );
end entity BarLedDriver;

architecture BarLedDriver_ARCH of BarLedDriver is
    
begin

    DRIVE_LEDS : process(binary4Bit, outputEN)
    begin
        if outputEN = '0' then
            leds <= (others => '0');
        else
            for i in 0 to 15 loop
                if to_integer(unsigned(binary4BIt)) = i then
                    leds(i) <= '1';
                else
                    leds(i) <= '0';
                end if;
            end loop;
        end if;
    end process;
    
end architecture BarLedDriver_ARCH;
