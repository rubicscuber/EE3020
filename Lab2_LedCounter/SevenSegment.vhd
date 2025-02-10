library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SevenSegment is
  port (
    segNumLeds : in std_logic_vector(2 downto 0);
    cathodes : out std_logic_vector(6 downto 0)
  );
end entity SevenSegment;

architecture SevenSegment_ARCH of SevenSegment is
  signal count: integer;
begin
  count <= to_integer(unsigned(segNumLeds));
 
  cathodes <= "1000000" when count = 0 else
              "1111001" when count = 1 else
              "0100100" when count = 2 else
              "0110000" when count = 3 else
              "0011001" when count = 4 else
              "0010010" when count = 5 else
              "0000010" when count = 6 else
              "1111000" when count = 7;



end architecture SevenSegment_ARCH;
