library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types_package.all;
------------------------------------------------------------------------------------
--Title: 
--Name: Nathaniel Roberts, Mitch Walker
--Date: 
--Prof: Scott Tippens
--Desc: Number checker Testbench
------------------------------------------------------------------------------------

entity NumberCheckerTB is
end entity NumberCheckerTB;

architecture Behavioral of NumberCheckerTB is 
    ------------------------------------------------------------------------------------
    --Component definition
    ------------------------------------------------------------------------------------
    component NumberChecker
        port(
            switches    : in  std_logic_vector(15 downto 0);
            number0     : in  std_logic_vector(3 downto 0);
            number1     : in  std_logic_vector(3 downto 0);
            number2     : in  std_logic_vector(3 downto 0);
            number3     : in  std_logic_vector(3 downto 0);
            number4     : in  std_logic_vector(3 downto 0);
            readMode    : in  std_logic;
            gameState   : in  GameStates_t;
            clock       : in  std_logic;
            reset       : in  std_logic;
            nextRoundEN : out std_logic;
            gameOverEN  : out std_logic;
            gameWinEN   : out std_logic
        );
    end component NumberChecker;

    ------------------------------------------------------------------------------------
    --Signals 
    ------------------------------------------------------------------------------------
    signal switches    :   std_logic_vector(15 downto 0) := "0000000000000000";
    signal number0     :   std_logic_vector(3 downto 0);
    signal number1     :   std_logic_vector(3 downto 0);
    signal number2     :   std_logic_vector(3 downto 0);
    signal number3     :   std_logic_vector(3 downto 0);
    signal number4     :   std_logic_vector(3 downto 0);
    signal readMode    :   std_logic := '1';
    signal gameState   :   GameStates_t := ROUND5;
    signal clock       :   std_logic := '1';

    signal reset       :   std_logic;
    signal nextRoundEN :   std_logic;
    signal gameOverEN  :   std_logic;
    signal gameWinEN   :   std_logic;

begin

    number0 <= std_logic_vector(to_unsigned(5, 4));
    number1 <= std_logic_vector(to_unsigned(5, 4));
    number2 <= std_logic_vector(to_unsigned(12, 4));
    number3 <= std_logic_vector(to_unsigned(14, 4));
    number4 <= std_logic_vector(to_unsigned(5, 4));
    ------------------------------------------------------------------------------------
    -- Component instantiation into UUT
    ------------------------------------------------------------------------------------
    UUT : component NumberChecker
        port map(
            switches    => switches,
            number0     => number0,
            number1     => number1,
            number2     => number2,
            number3     => number3,
            number4     => number4,
            readMode    => readMode,
            gameState   => gameState,
            clock       => clock,
            reset       => reset,
            nextRoundEN => nextRoundEN,
            gameOverEN  => gameOverEN,
            gameWinEN   => gameWinEN
        );

    ------------------------------------------------------------------------------------
    --Clock creating process
    ------------------------------------------------------------------------------------
    CLOCK_GEN : process 
    begin
        clock <= not clock;
        wait for 10 ps;
    end process;

    ------------------------------------------------------------------------------------
    --Reset generating process
    ------------------------------------------------------------------------------------
    RESET_GEN : process
    begin
        reset <= '0';
        wait for 1 ps;
        reset <= '1';
        wait for 1 ps;
        reset <= '0';
        wait;
    end process;

    ------------------------------------------------------------------------------------
    --Main stimulus process
    ------------------------------------------------------------------------------------
    STIMULUS : process
    begin
        wait until rising_edge(clock);
        wait until rising_edge(clock);

        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';
        wait until rising_edge(clock);

        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';
        wait until rising_edge(clock);

        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';
        wait until rising_edge(clock);

        switches(14) <= '1';
        wait until rising_edge(clock);
        switches(14) <= '0';
        wait until rising_edge(clock);

        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';
        wait until rising_edge(clock);




        wait for 100 ps;
        wait;
    end process;

end architecture Behavioral ;
