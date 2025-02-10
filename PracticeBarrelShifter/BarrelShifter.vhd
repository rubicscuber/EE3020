library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BarrelShifter is
  port (
  dataIn    : in std_logic_vector(7 downto 0);
  direction : in std_logic;
  shiftBy   : in std_logic_vector(2 downto 0);

  dataOut   : out std_logic_vector(7 downto 0)
  );
end entity BarrelShifter;

architecture BarrelShifter_arc of BarrelShifter is
  
begin
  
  with direction select --dataflow model
    dataOut <= dataIn sll to_integer(unsigned(shiftBy)) when '1',
               dataIn srl to_integer(unsigned(shiftBy)) when '0',
               "00000000" when others;

  
  
end architecture BarrelShifter_arc ;
