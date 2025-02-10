----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/29/2025 01:36:58 PM
-- Design Name: 
-- Module Name: DisplayModule - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The Digit Selector references the system clock
-- and creates a toggling signal, internally this signal is what drives a 
-- 4 bit output, it is intended that this 4 bit output will sroll thrugh
-- each common annode of the 7seg and that is handled by the display driver Module.
-- each bit is on for 4ms at a time for a frequency of 250Hz meaning the whole display is
-- refreshed once every 16ms or 62.6Hz 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity DigitSelector is
    Port (
           clk_in  : in STD_LOGIC;
           annodeList  : out std_logic_vector(3 downto 0));
end DigitSelector;

architecture DigitSelector_ARCH of DigitSelector is

--number of clock cycles to get to 250Hz, 4ms period
-- desired count = 100Mhz/250Hz * 0.5
CONSTANT C_CNT_250HZ : integer := 400000; 

--counters
signal r_cnt_250hz : integer range 0 to C_CNT_250HZ; --slows down system clock
signal d_cnt : integer range 0 to 3; --counter for activating the annode bus

--clock signal to be used in refreshing the led display
signal toggle : std_logic;

begin

proc_250hz: process(clk_in) is
begin
    if rising_edge(clk_in) then
      if r_cnt_250hz = C_CNT_250HZ - 1 then
        toggle <= not toggle;
        r_cnt_250hz <= 0;
      else
        r_cnt_250hz <= r_cnt_250hz + 1;
      end if;
    end if;
end process;

proc_selectDigit: process(toggle) is 
begin
  if rising_edge(toggle) then
    if d_cnt = 0 then
      annodeList <= "0111";
      d_cnt <= d_cnt + 1;
    elsif d_cnt = 1 then
      annodeList <= "1011";
      d_cnt <= d_cnt + 1;
    elsif d_cnt = 2 then
      annodeList <= "1101";
      d_cnt <= d_cnt + 1;
    elsif d_cnt = 3 then
      annodeList <= "1110";
      d_cnt <= 0; 
    else
      annodeList <= "1111";
    end if;
  end if;
end process;

end DigitSelector_ARCH;
