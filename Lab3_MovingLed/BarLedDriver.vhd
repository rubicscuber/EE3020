library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------
--Title: Lab_3_MovingLed
--Name: Nathaniel Roberts
--Date: 
--Prof: Scott Tippens
--Desc: 
--      
--      
--      
------------------------------------------------------------

entity BarLedDriver is
    port (
        position : in std_logic_vector(3 downto 0);
        bar : out std_logic_vector(15 downto 0)
    );
end entity BarLedDriver;

architecture BarLedDriver_ARCH of BarLedDriver is
begin
    with position select
        bar <= "0000000000000001" when "0000",
               "0000000000000010" when "0001",
               "0000000000000100" when "0010",
               "0000000000001000" when "0011",
               "0000000000010000" when "0100",
               "0000000000100000" when "0101",
               "0000000001000000" when "0110",
               "0000000010000000" when "0111",
               "0000000100000000" when "1000",
               "0000001000000000" when "1001",
               "0000010000000000" when "1010",
               "0000100000000000" when "1011",
               "0001000000000000" when "1100",
               "0010000000000000" when "1101",
               "0100000000000000" when "1110",
               "1000000000000000" when "1111",
               (others => '0') when others;

end BarLedDriver_ARCH;
