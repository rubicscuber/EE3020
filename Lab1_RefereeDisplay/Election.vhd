library IEEE;
use IEEE.std_logic_1164.all;

------------------------------------------------------------
--Title:    Lab_1_Referee
--Name:     Nathaniel Roberts
--Date:     1/29/25
--Prof:     Scott Tippens
--Desc:     Each switch state represents a referee's decision on a field call.
--          The 3rd switch is the head referee who is the tie breaker.
------------------------------------------------------------

entity Election is
  port (
   ref0 : in std_logic;
   ref1 : in std_logic;
   ref2 : in std_logic;
   ref3 : in std_logic; --head referee is switch 3

   decision : out std_logic
  );
end entity Election;

------------------------------------------------------------
architecture Election_ARCH of Election is

 signal     sel : std_logic_vector(3 downto 0);
 Constant   YES : std_logic := '1';
 Constant   NO  : std_logic := '0';

begin

 sel(0) <= ref0;
 sel(1) <= ref1;
 sel(2) <= ref2;
 sel(3) <= ref3;
 
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

end architecture Election_ARCH;
