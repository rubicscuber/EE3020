library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Types_package.all; --TODO: remove types_package, only states needed are in the DISPLAY_STATE_MACHINE process

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
        start : in std_logic;
        
        clock : in std_logic;
        reset : in std_logic;

        leds : out std_logic_vector(15 downto 0);

        outputGameNumber : out std_logic_vector(7 downto 0);
        outputScore : out std_logic_vector(7 downto 0);

        blanks : out std_logic_vector(3 downto 0)
    );
end entity MemoryGame;


architecture MemoryGame_ARCH of MemoryGame is

    --this is subtracted from the toggling counter, making in toggle faster
    signal countScaler : integer range 0 to 90_000_000; 

    --the ammount added to count countScaler after each win
    constant SCALE_AMOUNT : integer := 15_000_000;
    
    --the absolute max rate that the numbers can flash
    constant MAX_TOGGLE_COUNT : integer := 100_000_000;

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

    component WinPattern
        generic(BLINK_COUNT : natural);
        port(
            winPatternEN     : in  std_logic;
            reset            : in  std_logic;
            clock            : in  std_logic;
            leds             : out std_logic_vector(15 downto 0);
            winPatternIsBusy : out std_logic
        );
    end component WinPattern;

    component LosePattern
        generic(BLINK_COUNT : natural);
        port(
            losePatternEN     : in  std_logic;
            reset             : in  std_logic;
            clock             : in  std_logic;
            leds              : out std_logic_vector(15 downto 0);
            losePatternIsBusy : out std_logic
        );
    end component LosePattern;

    component BarLedDriver_Basys3
        port(
            binary4Bit : in  std_logic_vector(3 downto 0);
            outputEN   : in  std_logic;
            leds       : out std_logic_vector(15 downto 0)
        );
    end component BarLedDriver_Basys3;

    component BCD
        port(
            binary4Bit  : in  std_logic_vector(3 downto 0);
            decimalOnes : out std_logic_vector(3 downto 0);
            decimalTens : out std_logic_vector(3 downto 0)
        );
    end component BCD;

    --general signals for design
    signal tpsToggle : std_logic;
    signal tpsModeControl : std_logic;
    signal tpsToggleShift : std_logic;

    --signals for RNG_GENERATOR
    signal readyEN : std_logic;
    signal number0 : std_logic_vector(3 downto 0);
    signal number1 : std_logic_vector(3 downto 0);
    signal number2 : std_logic_vector(3 downto 0);
    signal number3 : std_logic_vector(3 downto 0);
    signal number4 : std_logic_vector(3 downto 0);


    --signals for number checker
    signal readMode : std_logic;
    signal nextRoundEN : std_logic;
    signal gameOverEN : std_logic;
    signal gameWinEN : std_logic;
    signal ledMode : std_logic;

    --game state signals
    signal currentGameState : GameStates_t;

    --display state signals
    signal currentDisplayState : DisplayStates_t;
    signal nextDisplayState : DisplayStates_t;

    signal score : integer range 0 to 15;

    signal winPatternIsBusy : std_logic;
    signal losePatternIsBusy : std_logic;

    signal outputNumber : std_logic_vector(3 downto 0);
    signal startControl : std_logic;

    signal scoreVector : std_logic_vector(3 downto 0);

    signal SMTimer : integer;

    signal loseMode : std_logic;
    signal winMode : std_logic;

    signal dummySignal : std_logic;

begin
    startControl <= (start and readMode and (not losePatternIsBusy)) or nextRoundEN;
    RNG_GENERATOR : component RandomNumbers port map(
        generateEN => startControl,

        clock      => clock,
        reset      => reset,

        readyEN    => readyEN,

        number0    => number0,
        number1    => number1,
        number2    => number2,
        number3    => number3,
        number4    => number4
    );

    currentGameState <= ROUND5;

    CHECK_NUMBERS : component NumberChecker port map(
        switches    => switches,

        number0     => number0,
        number1     => number1,
        number2     => number2,
        number3     => number3,
        number4     => number4,

        readMode    => readMode,
        gameState   => currentGameState, --TODO: change this port and change NumberChecker functionality

        clock       => clock,
        reset       => reset,

        nextRoundEN => dummySignal,
        gameOverEN  => gameOverEN,
        gameWinEN   => gameWinEN
    );
    
    WIN_PATTERN_DRIVER : component WinPattern
        generic map(
            BLINK_COUNT => 25_000_000 - 1 --quarter second sequence
        )
        port map(
            winPatternEN     => winMode,
            reset            => reset,
            clock            => clock,
            leds             => leds,
            winPatternIsBusy => winPatternIsBusy
    );
    
    LOSE_PATTERN_DRRIVER : LosePattern
        generic map(
            BLINK_COUNT => 25_000_000 - 1 --quarter second sequence
        )
        port map(
            losePatternEN     => gameOverEN,
            reset             => reset,
            clock             => clock,
            leds              => leds,
            losePatternIsBusy => losePatternIsBusy
    );

    GAME_LED_DRIVER : BarLedDriver_Basys3 port map(
        binary4Bit => outputNumber,
        outputEN   => ledMode,
        leds       => leds
    );

    scoreVector <= std_logic_vector(to_unsigned(score, 4));
    SCORE_NUMBER_BCD : BCD port map(
        binary4Bit  => scoreVector,
        decimalOnes => outputScore(3 downto 0),
        decimalTens => outputScore(7 downto 4)
    );

    GAME_NUMBER_BCD : BCD port map(
            binary4Bit  => outputNumber,
            decimalOnes => outputGameNumber(3 downto 0),
            decimalTens => outputGameNumber(7 downto 4)
    );

    ------------------------------------------------------------------------------------
    -- Process that increments score and speed with each win
    ------------------------------------------------------------------------------------
    GAME_DRIVER : process (clock, reset)
    begin
        if reset = '1' then
            score <= 0;
            countScaler <= 0;
            loseMode <= '0';
        elsif rising_edge(clock) then
            if gameWinEN  = '1' then
                score <= score + 1;
                if countScaler <= 90_000_000 then
                    countScaler <= countScaler + SCALE_AMOUNT;
                end if;
            end if;
            if gameOverEN = '1' then
                countScaler <= 0;
                loseMode <= '1';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- timer that handles blinking the final score until reset happens
    ------------------------------------------------------------------------------------
    LOSE_MODE_TIMER : process(clock, reset)
        variable counter : integer range 0 to MAX_TOGGLE_COUNT - 1;
        variable toggle : std_logic;
    begin
        if reset = '1' then
            counter := 0;
            toggle := '0';
        elsif rising_edge(clock) then
            if loseMode = '1' then
                counter := counter + 1;
                if (counter >= (MAX_TOGGLE_COUNT - 1)) then
                    toggle := not toggle;
                    counter := 0;
                end if;
                if toggle = '1' then
                    blanks <= "0011";
                elsif toggle = '0' then
                    blanks <= "1111";
                end if;

            elsif loseMode = '0' then
                counter := 0;
                blanks <= "0011";
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- timer that handles automatic start and level controlled win pattern
    ------------------------------------------------------------------------------------
    WIN_MODE_TIMER : process(clock, reset)
        variable counter : integer range 0 to (2 * MAX_TOGGLE_COUNT) - 1;
        variable latch : std_logic;
    begin
        if reset = '1' then
            counter := 0;
            latch := '0';
            nextRoundEN <= '0';
        elsif rising_edge(clock) then
            nextRoundEN <= '0';
            if gameWinEN = '1' then
                latch := '1';
            end if;

            if latch = '1' then
                winMode <= '1';
                counter := counter + 1;
                if (counter >= ((2 * MAX_TOGGLE_COUNT) - 1)) then
                    latch := '0';
                    counter := 0;
                    nextRoundEN <= '1';
                end if;
            else
                counter := 0;
                winMode <= '0';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- timer that handles the state machine to display the values of RNG_GENERATOR
    ------------------------------------------------------------------------------------
    DISPLAY_SM_TIMER : process(clock,reset)
        variable counter : integer range 0 to MAX_TOGGLE_COUNT - 1;
        variable countMode : std_logic;
    begin
        if reset = '1' then
            SMTimer <= 0;
            counter := 0;
            countMode := '0';
        elsif rising_edge(clock) then
            if readyEN = '1' then
                countMode := '1'; --latch in and start counting
            end if;

            if countMode = '1' then
                counter := counter + 1;
                if (counter >= (MAX_TOGGLE_COUNT - countScaler - 1)) then
                    SMTimer <= SMTimer + 1;
                    counter := 0;
                end if;
            elsif countMode = '0' then
                SMTimer <= 0;
                counter := 0;
            end if;

            if SMTimer = 10 then
                SMTimer <= 0;
                countMode := '0';
                counter := 0;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- State machine responsible for driving the main number output
    ------------------------------------------------------------------------------------
    DISPLAY_SM : process(SMTimer, number0, number1, number2, number3, number4, loseMode) is
    begin
        case (SMTimer) is
            ------------------------------------------------------------------BLANK
            when 0 =>
                readMode <= '1';                --allow the start button to be pressed
                ledMode <= '0';                 --deactivate leds
--                blanks <= "0011";               --deactivate segments

            ------------------------------------------------------------------NUM1
            when 1 =>
                readMode <= '0';
                ledMode <= '1';                 --activate leds
--                blanks <= (others => '0');      --activate segments
                outputNumber <= number0;

            ------------------------------------------------------------------BLANK
            when 2 =>
                readMode <= '0';
                ledMode <= '0';                 --deactivate leds
--                blanks <= "0011";               --deactivate segments

            ------------------------------------------------------------------NUM2
            when 3 =>
                readMode <= '0';
                ledMode <= '1';                 --activate leds
--                blanks <= (others => '0');      --activate segments
                outputNumber <= number1;

            ------------------------------------------------------------------BLANK
            when 4 =>
                readMode <= '0';
                ledMode <= '0';                 --deactivate leds
--                blanks <= "0011";               --deactivate segments

            ------------------------------------------------------------------NUM3
            when 5 =>
                readMode <= '0';
                ledMode <= '1';                 --activate leds
--                blanks <= (others => '0');      --activate segments
                outputNumber <= number2;

            ------------------------------------------------------------------BLANK
            when 6 =>
                readMode <= '0';
                ledMode <= '0';                 --deactivate leds
--                blanks <= "0011";               --deactivate segments

            ------------------------------------------------------------------NUM4
            when 7 =>
                readMode <= '0';
                ledMode <= '1';                 --activate leds
--                blanks <= (others => '0');      --activate segments
                outputNumber <= number3;

            ------------------------------------------------------------------BLANK
            when 8 =>
                readMode <= '0';
                ledMode <= '0';                 --deactivate leds
--                blanks <= "0011";               --deactivate segments

            ------------------------------------------------------------------NUM5
            when 9 =>
                readMode <= '0';
                ledMode <= '1';                 --activate leds
--                blanks <= (others => '0');      --activate segments
                outputNumber <= number4;

            ------------------------------------------------------------------DEFAULT
            when others =>
                readMode <= '0';
                ledMode <= '0';
--                blanks <= (others => '1');

            end case;
    end process;

end architecture MemoryGame_ARCH;
