library IEEE;
use IEEE.std_logic_1164.all;

------------------------------------------------------------
--Title: Lab_1_Referee
--Name:  Nathaniel Roberts
--Date:  1/29/25
--Prof:  Scott Tippens
--Desc:  Each std_logic port input represents a referee's decision on a field call.
--       The the head referee is the tie breaker.
------------------------------------------------------------

entity Lab1_Referee is
  port (
    ref0 : in std_logic;
    ref1 : in std_logic;
    ref2 : in std_logic;
    headref : in std_logic;
    decision : out std_logic);
end entity Lab1_Referee;

------------------------------------------------------------
architecture Lab1_Referee_ARCH of Lab1_Referee is

    signal     sel : std_logic_vector(3 downto 0);
    Constant   YES : std_logic := '1';
    Constant   NO  : std_logic := '0';

begin

    sel(0) <= ref0; --load the referees into a bus for easy syntax
    sel(1) <= ref1;
    sel(2) <= ref2;
    sel(3) <= headref;
 
    with sel select
    decision <= NO  when "0000", --head ref voting no
                NO  when "0001",
                NO  when "0010",
                NO  when "0011",
                NO  when "0100",
                NO  when "0101",
                NO  when "0110",
                YES when "0111",
                ----------------
                NO  when "1000", --head ref voting yes
                YES when "1001",
                YES when "1010",
                YES when "1011",
                YES when "1100",
                YES when "1101",
                YES when "1110",
                YES when "1111",
                NO  when others; 

end architecture Lab1_Referee_ARCH;
