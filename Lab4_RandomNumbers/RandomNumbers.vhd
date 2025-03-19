library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity RandomNumbers is
    port (
    generateEN : in std_logic;
    reset : in std_logic;
    clock : in std_logic;

    number0 : out std_logic_vector(3 downto 0);
    number1 : out std_logic_vector(3 downto 0);
    number2 : out std_logic_vector(3 downto 0);
    number3 : out std_logic_vector(3 downto 0);
    number4 : out std_logic_vector(3 downto 0);

    readyEN : out std_logic
    );
end entity RandomNumbers;


architecture RandomNumbers_ARCH of RandomNumbers is

    constant reg0 : std_logic_vector(3 downto 0) := "1000";
    constant reg1 : std_logic_vector(3 downto 0) := "0100";
    constant reg2 : std_logic_vector(3 downto 0) := "0010";
    constant reg3 : std_logic_vector(3 downto 0) := "0001";
    constant reg4 : std_logic_vector(3 downto 0) := "0110";

begin

    --Dummy process to send 5 numbers to output for testing wrapper
    SEND_NUMBER : process(clock, reset)
    begin
        if reset = '1' then
            number0 <= "0000";
            number1 <= "0000";
            number2 <= "0000";
            number3 <= "0000";
            number4 <= "0000";
            readyEN <= '0';
        elsif rising_edge(clock) then
            if generateEN = '1' then 
                number0 <= reg0;     
                number1 <= reg1;
                number2 <= reg2;
                number3 <= reg3;
                number4 <= reg4;
                readyEN <= '1';
            end if;
            if generateEN = '0' then
                readyEN <= '0';
            end if;
        end if;
    end process;

end architecture RandomNumbers_ARCH;
