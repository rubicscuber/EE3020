library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity RandomNumbers is
    port (
    generateButton in : std_logic;
    reset in : std_logic;
    clock in : std_logic;

    number0 out : std_logic_vector(3 downto 0);
    number1 out : std_logic_vector(3 downto 0);
    number2 out : std_logic_vector(3 downto 0);
    number3 out : std_logic_vector(3 downto 0);
    number4 out : std_logic_vector(3 downto 0);

    readyEN out : std_logic
    );
end entity RandomNumbers;


architecture RandomNumbers_ARCH of RandomNumbers is
    --signal feedbackBus : std_logic_vecotr(3 downto 0);

    signal reg0 : std_logic_vector(3 downto 0) := "1000";
    signal reg1 : std_logic_vector(3 downto 0) := "0100";
    signal reg2 : std_logic_vector(3 downto 0) := "0010";
    signal reg3 : std_logic_vector(3 downto 0) := "0001";
    signal reg4 : std_logic_vector(3 downto 0) := "0110";
    --signal inputShifter : std_logic_vecotr (1 downto 0);

begin

    SEND_NUMBER : process(clock, reset)
    begin
        readyEN = '0'; 
        if reset = '1' then
            number0 <= "0000";
            number1 <= "0000";
            number2 <= "0000";
            number3 <= "0000";
            number4 <= "0000";
            readyEN = '0';
        if rising_edge(clock) then
            if generateButton = '1' then
                number0 <= reg0;
                number1 <= reg1;
                number2 <= reg2;
                number3 <= reg3;
                number4 <= reg4;
                readyEN = '1';
                --NOTE: readyEN MUST be a single clock pulse wide 
             end if;
        end if;
    end process;

    
end architecture RandomNumbers_ARCH;
