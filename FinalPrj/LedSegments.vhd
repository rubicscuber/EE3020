library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------
--Title: LedSegments.vhd
--Name: Nathaniel Roberts, Mitch Walker
--Date: 4/25/25
--Prof: Scott Tippens
--Desc: Bar Led Driver file
--      This file simply chooses which led on the Basys3 board will recieve the active
--      level. The inupt is a 4 bit binary number and output is 16 bit wide vector.
--      matching the position of each of the 16 leds on the Basys3 board.
------------------------------------------------------------------------------------


entity LedSegments is
    port(
        binary4Bit : in std_logic_vector(3 downto 0);
        outputMode : in std_logic;

        leds : out std_logic_vector(15 downto 0)
    );
end entity LedSegments;

architecture LedSegments_ARCH of LedSegments is

begin

    DRIVE_LEDS : process(binary4Bit, outputMode)
    begin
        if outputMode = '0' then
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

end architecture LedSegments_ARCH;
