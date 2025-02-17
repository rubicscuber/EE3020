library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------
--Title: Lab_2_SwitchLed
--Name: Nathaniel Roberts
--Date: 2/12/25
--Prof: Scott Tippens
--Desc: This module takes a binary value of switches and 
--      write that value into a SevenSegment bus
--      the top module handles the annodes
------------------------------------------------------------

entity SevenSegment is
    port (
        numLeds : in std_logic_vector(2 downto 0);
        cathodes : out std_logic_vector(6 downto 0)
    );
end entity SevenSegment;

architecture SevenSegment_ARCH of SevenSegment is

    signal count: integer;

begin

    count <= to_integer(unsigned(numLeds));

    cathodes <= "1000000" when count = 0 else
                "1111001" when count = 1 else
                "0100100" when count = 2 else
                "0110000" when count = 3 else
                "0011001" when count = 4 else
                "0010010" when count = 5 else
                "0000010" when count = 6 else
                "1111000" when count = 7 else
                (others => '0');

end architecture SevenSegment_ARCH;
