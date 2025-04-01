library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types_package.all;

------------------------------------------------------------------------------------
--Title: 
--Name: Nathaniel Roberts, Mitch Walker
--Date: 
--Prof: Scott Tippens
--Desc: Memory Game design file
--      
--      
--      
------------------------------------------------------------------------------------


entity MemoryGame is
    port(
        switches : in std_logic_vector(15 downto 0);
        clock : in std_logic;
        reset : in std_logic

        --add more ports here


    );
end entity MemoryGame;


architecture MemoryGame_ARCH of MemoryGame is

    component RandomNumbers is
        port(
            generateEN : in  std_logic;
            clock      : in  std_logic;
            reset      : in  std_logic;

            readyEN    : out std_logic;

            number0    : out std_logic_vector(3 downto 0);
            number1    : out std_logic_vector(3 downto 0);
            number2    : out std_logic_vector(3 downto 0);
            number3    : out std_logic_vector(3 downto 0);
            number4    : out std_logic_vector(3 downto 0)
        );
    end component RandomNumbers;

    component NumberChecker is
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

    --general signals for design
    signal countScaler : integer;
    signal tpsToggle : std_logic;
    signal tpsModeControl : std_logic;
    signal tpsToggleShift : std_logic;
    signal currentState : GameStates_t;
    signal nextState : GameStates_t;
    signal blanks : std_logic_vector(3 downto 0);

    --signals for RNG_GENERATOR
    signal generateEN : std_logic;
    signal readyEN : std_logic;
    signal number0 : std_logic_vector(3 downto 0);
    signal number1 : std_logic_vector(3 downto 0);
    signal number2 : std_logic_vector(3 downto 0);
    signal number3 : std_logic_vector(3 downto 0);

    
    --signals for number checker
    signal readMode : std_logic;
    signal gameState : GameStates_t;
    signal number4 : std_logic_vector(3 downto 0);
    signal nextRoundEN : std_logic;
    signal gameOverEN : std_logic;
    signal gameWinEN : std_logic;

begin
    RNG_GENERATOR : component RandomNumbers port map(
        generateEN => generateEN,

        clock      => clock,
        reset      => reset,

        readyEN    => readyEN,

        number0    => number0,
        number1    => number1,
        number2    => number2,
        number3    => number3,
        number4    => number4
    );

    CHECK_NUMBERS : component NumberChecker
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
    

    TPS_TOGGLER : process(clock, reset)
        variable counter : integer; 
    begin
        if reset = '1' then
            counter := 0;
            tpsToggle <= '0';
        elsif rising_edge(clock) then
            if tpsModeControl = '1' then
                counter := counter + 1;
                if counter >= countScaler then
                    tpsToggle <= not tpsToggle;
                    counter := 0;
                end if;
            end if;
            if tpsModeControl = '0' then
                counter := 0;
                tpsToggle <= '0';
            end if;
        end if;
    end process;

    TPS_TOGGLE_SHIFTER : process(clock, reset)
    begin
        if reset = '1' then
            tpsToggleShift <= '0';
        elsif rising_edge(clock) then
            tpsToggleShift <= tpsToggle;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- The state register keeps the state machine synchronized with the clock.
    ------------------------------------------------------------------------------------
    GAME_STATE_REG : process(clock, reset)
    begin
        if reset = '1' then
            currentState <= WAIT_FOR_READY;
        elsif rising_edge(clock) then
            currentState <= nextState;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- Game state machine, unfinished and needs modification
    -- another state machine should handle the process of driving the displays 
    ------------------------------------------------------------------------------------
    GAME_STATE_MACHINE : process (currentState, readyEN, tpsToggle, tpsToggleShift)
    begin
        case (currentState) Is
            ------------------------------------------BLANK
            when WAIT_FOR_READY =>
                tpsModeControl <= '0';     --turn off counter and reset it
                blanks <= (others => '1'); --deactivate segments
                ledMode <= '0';            --deactivate leds

                if readyEN = '1' then      --readyEN kicks off the state machine
                    nextState <= ROUND1;
                else 
                    nextState <= WAIT_FOR_READY;
                end if;
            -------------------------------------------ROUND1
            when ROUND1 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number0Register;
                    nextState <= ROUND1;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= ROUND2;
                end if;
            -------------------------------------------ROUND2
            when ROUND2 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number1Register;
                    nextState <= ROUND2;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= ROUND3;
                end if;
            -------------------------------------------ROUND3
            when ROUND3 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number2Register;
                    nextState <= ROUND3;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= ROUND4;
                end if;
            -------------------------------------------ROUND4
            when ROUND4 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number3Register;
                    nextState <= ROUND4;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= ROUND5;
                end if;
            -------------------------------------------ROUND5
            when ROUND5 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number4Register;
                    nextState <= ROUND5;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= WAIT_FOR_READY;
                end if;
        end case;
    end process;

end architecture MemoryGame_ARCH;
