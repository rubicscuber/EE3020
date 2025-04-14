library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Types_package.all;

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
    signal nextGameState : GameStates_t;

    --display state signals
    signal currentDisplayState : DisplayStates_t;
    signal nextDisplayState : DisplayStates_t;

    --this is subtracted from the toggling counter, making in toggle faster
    signal countScaler : integer range 0 to 90_000_000; 

    --the ammount added to count countScaler after each win
    constant SCALE_AMOUNT : integer := 15_000_000;
    
    --the absolute max rate that the numbers can flash
    constant MAX_TOGGLE_COUNT : integer := 100_000_000; --10;

    signal score : integer range 0 to 15;

    signal winPatternIsBusy : std_logic;
    signal losePatternIsBusy : std_logic;
    signal inputControl : std_logic;
    
    signal outputNumber : std_logic_vector(3 downto 0);
    signal startControl : std_logic;
    
    signal scoreVector : std_logic_vector(3 downto 0);

begin
    startControl <= start and inputControl and (not winPatternIsBusy) and (not losePatternIsBusy);
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

    CHECK_NUMBERS : component NumberChecker port map(
        switches    => switches,

        number0     => number0,
        number1     => number1,
        number2     => number2,
        number3     => number3,
        number4     => number4,

        readMode    => readMode,
        gameState   => currentGameState,

        clock       => clock,
        reset       => reset,

        nextRoundEN => nextRoundEN,
        gameOverEN  => gameOverEN,
        gameWinEN   => gameWinEN
    );
    
    WIN_PATTERN_DRIVER : component WinPattern
        generic map(
            BLINK_COUNT => (100000000/4)-1 --1
        )
        port map(
            winPatternEN     => gameWinEN,
            reset            => reset,
            clock            => clock,
            leds             => leds,
            winPatternIsBusy => winPatternIsBusy
    );
    
    LOSE_PATTERN_DRRIVER : LosePattern
        generic map(
            BLINK_COUNT => (100000000/4)-1 --1
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
    

    TPS_TOGGLER : process(clock, reset)
        variable counter : integer range 0 to MAX_TOGGLE_COUNT; 
    begin
        if reset = '1' then
            counter := 0;
            tpsToggle <= '0';
        elsif rising_edge(clock) then
            if tpsModeControl = '1' then
                counter := counter + 1;
                if counter >= (MAX_TOGGLE_COUNT - countScaler) then
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
    DISPLAY_STATE_REG : process(clock, reset)
    begin
        if reset = '1' then
            currentDisplayState <= IDLE;
        elsif rising_edge(clock) then
            currentDisplayState <= nextDisplayState;
        end if;
    end process;


    ------------------------------------------------------------------------------------
    -- State machine responsible for driving the main number output
    ------------------------------------------------------------------------------------
    DISPLAY_STATE_MACHINE : process (currentDisplayState, readyEN, tpsToggle, tpsToggleShift,
                            nextRoundEN, currentGameState)
    begin
        case (currentDisplayState) Is
            ------------------------------------------BLANK
            when IDLE =>
                tpsModeControl <= '0';     --turn off counter and reset it
                blanks <= "0011";          --deactivate segments
                ledMode <= '0';            --deactivate leds
                readMode <= '1';
                if readyEN = '1' or nextRoundEN = '1' then      
                    nextDisplayState <= NUM1;
                else 
                    nextDisplayState <= IDLE;
                end if;

            ------------------------------------------NUM1
            when NUM1 =>
                tpsModeControl <= '1';
                readMode <= '0';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= (others => '0'); --activate segments
                    outputNumber <= number0;
                    nextDisplayState <= NUM1;
                elsif tpsToggle = '1' then
                    if currentGameState = ROUND1 then
                        nextDisplayState <= IDLE;
                    else
                        nextDisplayState <= NUM2;
                    end if;
                end if;

            -------------------------------------------ROUND2
            when NUM2 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= (others => '0'); --activate segments
                    outputNumber <= number1;
                    nextDisplayState <= NUM2;
                elsif tpsToggle = '1' then     
                    ledMode <= '0';            --deactivate leds
                    blanks <= "0011";          --deactivate segments
                end if;
                if (tpsToggle = '1') and (tpsToggleShift = '0') then
                    if currentGameState = ROUND2 then
                        nextDisplayState <= IDLE;
                    else
                        nextDisplayState <= NUM3;
                    end if;
                end if;

            -------------------------------------------ROUND3
            when NUM3 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= (others => '0'); --activate segments
                    outputNumber <= number2;
                    nextDisplayState <= NUM3;
                elsif tpsToggle = '1' then     
                    ledMode <= '0';            --deactivate leds
                    blanks <= "0011";          --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    if currentGameState = ROUND3 then
                        nextDisplayState <= IDLE;
                    else
                        nextDisplayState <= NUM4;
                    end if;
                end if;

            -------------------------------------------ROUND4
            when NUM4 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= (others => '0'); --activate segments
                    outputNumber <= number3;
                    nextDisplayState <= NUM4;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= "0011";          --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    if currentGameState = ROUND4 then
                        nextDisplayState <= IDLE;
                    else
                        nextDisplayState <= NUM5;
                    end if;
                end if;

            -------------------------------------------ROUND5
            when NUM5 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= (others => '0'); --activate segments
                    outputNumber <= number4;
                    nextDisplayState <= NUM5;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= "0011";          --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextDisplayState <= IDLE;
                end if;
        end case;
    end process;

    ------------------------------------------------------------------------------------
    -- Game state register
    ------------------------------------------------------------------------------------
    GAME_STATE_REG : process(clock, reset)
    begin
        if reset = '1' then
            currentGameState <= WAIT_FOR_START;
        elsif rising_edge(clock) then
            currentGameState <= nextGameState;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- Game state machine
    ------------------------------------------------------------------------------------
    GAME_STATE_MACHINE : process (currentGameState, readyEN, nextRoundEN, gameOverEN, gameWinEN)
    begin
        case(currentGameState) is
            when WAIT_FOR_START =>
                inputControl <= '1';
                if readyEN = '1' then
                    nextGameState <= ROUND1;
                end if;
            when ROUND1 =>
                inputControl <= '0';
                if nextRoundEN = '1' then
                    nextGameState <= ROUND2;
                elsif gameOverEN = '1' then
                    nextGameState <= GAME_LOSE;
                end if;
            when ROUND2 =>
                if nextRoundEN = '1' then
                    nextGameState <= ROUND3;
                elsif gameOverEN = '1' then
                    nextGameState <= GAME_LOSE;
                end if;
            when ROUND3 =>
                if nextRoundEN = '1' then
                    nextGameState <= ROUND4;
                elsif gameOverEN = '1' then
                    nextGameState <= GAME_LOSE;
                end if;
            when ROUND4 =>
                if nextRoundEN = '1' then
                    nextGameState <= ROUND5;
                elsif gameOverEN = '1' then
                    nextGameState <= GAME_LOSE;
                end if;
            when ROUND5 =>
                if gameWinEN = '1' then
                    nextGameState <= GAME_WIN;
                elsif gameOverEN = '1' then
                    nextGameState <= GAME_LOSE;
                end if;
            when GAME_WIN =>
                countScaler <= countScaler + SCALE_AMOUNT;
                score <= score + 1;
                nextGameState <= WAIT_FOR_START;
            when GAME_LOSE =>
                score <= 0;
                countScaler <= 0;
                nextGameState <= WAIT_FOR_START;
        end case;
    end process;
end architecture MemoryGame_ARCH;
