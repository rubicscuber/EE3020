library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity RandomNumbers is
    port (
    generateButton in : std_logic;
    resetButton in : std_logic;
    clock in : std_logic;

    number0 out : std_logic_vector(3 downto 0);
    number1 out : std_logic_vector(3 downto 0);
    number2 out : std_logic_vector(3 downto 0);
    number3 out : std_logic_vector(3 downto 0);
    number4 out : std_logic_vector(3 downto 0)
    );
end entity RandomNumbers;


architecture RandomNumbers_ARCH of RandomNumbers is
    signal feedbackBus : std_logic_vecotr(3 downto 0);

    signal reg0 : std_logic_vector(3 downto 0);
    signal reg1 : std_logic_vector(3 downto 0);
    signal reg2 : std_logic_vector(3 downto 0);
    signal reg3 : std_logic_vector(3 downto 0);
    signal reg4 : std_logic_vector(3 downto 0);
begin
    feedbackBus <= not 
    
    
end architecture RandomNumbers_ARCH;
