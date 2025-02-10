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
-- Additional Comments:
-- Based on the activeAnode signal in, drive the 7seg display a 
-- 0 on the dataIn corresponds to no and a 1 corresponds to yes
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity RefereeDisplayDriver is
    Port (dataIn  : in STD_LOGIC;
          activeAnode  : in std_logic_vector(3 downto 0);
          i_an0 : out std_logic;
          i_an1 : out std_logic;
          i_an2 : out std_logic;
          i_an3 : out std_logic;

          i_seg0: out std_logic;
          i_seg1: out std_logic;
          i_seg2: out std_logic;
          i_seg3: out std_logic;
          i_seg4: out std_logic;
          i_seg5: out std_logic;
          i_seg6: out std_logic);
end RefereeDisplayDriver;

architecture RefereeDisplayDriver_ARCH of RefereeDisplayDriver is

  signal sevenSegVector : std_logic_vector (6 downto 0);
  
begin
  i_an0 <= activeAnode(0);
  i_an1 <= activeAnode(1);
  i_an2 <= activeAnode(2);
  i_an3 <= activeAnode(3);

  i_seg0 <= sevenSegVector(0);
  i_seg1 <= sevenSegVector(1);
  i_seg2 <= sevenSegVector(2);
  i_seg3 <= sevenSegVector(3);
  i_seg4 <= sevenSegVector(4);
  i_seg5 <= sevenSegVector(5);
  i_seg6 <= sevenSegVector(6);

  --lowercase no
  sevenSegVector <= "1111111" when (activeAnode = "0111") and (dataIn = '0') else --lowercase no
                    "1111111" when (activeAnode = "1011") and (dataIn = '0') else
                    "0101011" when (activeAnode = "1101") and (dataIn = '0') else --n
                    "0100011" when (activeAnode = "1110") and (dataIn = '0') else
                    "1111111" when (activeAnode = "0111") and (dataIn = '1') else --lowercase yes
                    "0010001" when (activeAnode = "1011") and (dataIn = '1') else
                    "0000110" when (activeAnode = "1101") and (dataIn = '1') else
                    "0010010" when (activeAnode = "1110") and (dataIn = '1') else
                    "1111111";
end RefereeDisplayDriver_ARCH;
