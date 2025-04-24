library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------
--Title: BCD.vhd
--Name: Nathaniel Roberts, Mitch Walker
--Date: 4/25/25
--Prof: Scott Tippens
--Desc: Binary to BCD converter file.
--      This component simply converts a 4 bit binary number into two seperate
--      4 bit numbers to represent the Tens and ones place combinationally.
------------------------------------------------------------------------------------


entity BCD is
    port(
        binary4Bit : in std_logic_vector(3 downto 0);

        decimalOnes : out std_logic_vector(3 downto 0);
        decimalTens : out std_logic_vector(3 downto 0)
    );
end entity BCD;


architecture BCD_ARCH of BCD is
begin
    with binary4Bit select
        decimalOnes <= "0000" when "0000",
                       "0001" when "0001",
                       "0010" when "0010",
                       "0011" when "0011",
                       "0100" when "0100",
                       "0101" when "0101",
                       "0110" when "0110",
                       "0111" when "0111",
                       "1000" when "1000",
                       "1001" when "1001",
                       -------------------
                       "0000" when "1010",
                       "0001" when "1011",
                       "0010" when "1100",
                       "0011" when "1101",
                       "0100" when "1110",
                       "0101" when "1111",
                       (others => '0') when others;

    with binary4Bit select
        decimalTens <= "0000" when "0000",
                       "0000" when "0001",
                       "0000" when "0010",
                       "0000" when "0011",
                       "0000" when "0100",
                       "0000" when "0101",
                       "0000" when "0110",
                       "0000" when "0111",
                       "0000" when "1000",
                       "0000" when "1001",
                       -------------------
                       "0001" when "1010",
                       "0001" when "1011",
                       "0001" when "1100",
                       "0001" when "1101",
                       "0001" when "1110",
                       "0001" when "1111",
                       (others => '0') when others;
end architecture BCD_ARCH;

