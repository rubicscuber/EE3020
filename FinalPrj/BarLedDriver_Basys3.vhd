library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------
--Title: Lab_4_RandomNumbers
--Name: Nathaniel Roberts, Mitch Walker
--Date: 3/26/25
--Prof: Scott Tippens
--Desc: Bar Led Driver file
--      This file simply chooses which led on the Basys3 board will recieve the active
--      level. The inupt is a 4 bit binary number and output is 16 bit wide vector.
--      matching the position of each of the 16 leds on the Basys3 board.
------------------------------------------------------------------------------------


entity BarLedDriver_Basys3 is
    port(
        binary4Bit : in std_logic_vector(3 downto 0);
        outputEN : in std_logic;

        leds : out std_logic_vector(15 downto 0)
    );
end entity BarLedDriver_Basys3;

architecture BarLedDriver_ARCH of BarLedDriver_Basys3 is

begin

    DRIVE_LEDS : process(binary4Bit, outputEN)
    begin
        if outputEN = '0' then
            leds <= (others => 'Z');
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
