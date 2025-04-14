library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Types_package.all;


------------------------------------------------------------------------------------
--Title: 
--Name: Nathaniel Roberts, Mitch Walker
--Date: 
--Prof: Scott Tippens
--Desc: Wrapper file
------------------------------------------------------------------------------------


entity MemoryGame_Basys3 is
    generic(
        NUM_OF_SWITCHES : positive := 16;
        CHAIN_SIZE : positive := 2;
        DELAY_COUNT : positive := 10_000_000 --10ms on a 100MHz clock = 1M
        );
    port(
        sw : in std_logic_vector(NUM_OF_SWITCHES-1 downto 0);
        btnC : in std_logic; --start/restart button
        btnD : in std_logic; --reset/blanks the screens
        clk : in std_logic;

        led : out std_logic_vector(15 downto 0);
        an  : out std_logic_vector(3 downto 0);
        seg : out std_logic_vector(6 downto 0)
    );
end entity;


architecture MemoryGame_Basys3_ARCH of MemoryGame_Basys3 is


    ------------------------------------------------------------------------------------
    --component definitions
    ------------------------------------------------------------------------------------
    component MemoryGame
        port(
            switches         : in  std_logic_vector(15 downto 0);

            start            : in  std_logic;

            clock            : in  std_logic;
            reset            : in  std_logic;

            leds             : out std_logic_vector(15 downto 0);

            outputGameNumber : out std_logic_vector(7 downto 0);
            outputScore      : out std_logic_vector(7 downto 0);

            blanks           : out std_logic_vector(3 downto 0)
        );
    end component MemoryGame;

    component SevenSegmentDriver is
        port(
            reset: in std_logic;
            clock: in std_logic;

            digit3: in std_logic_vector(3 downto 0);    --leftmost digit
            digit2: in std_logic_vector(3 downto 0);    --2nd from left digit
            digit1: in std_logic_vector(3 downto 0);    --3rd from left digit
            digit0: in std_logic_vector(3 downto 0);    --rightmost digit

            blank3: in std_logic;    --leftmost digit
            blank2: in std_logic;    --2nd from left digit
            blank1: in std_logic;    --3rd from left digit
            blank0: in std_logic;    --rightmost digit

            sevenSegs: out std_logic_vector(6 downto 0);    --MSB=g, LSB=a
            anodes:    out std_logic_vector(3 downto 0)    --MSB=leftmost digit
        );
    end component;

    component SynchronizerChain is
        generic (CHAIN_SIZE: positive);
        port (
            reset:    in  std_logic;
            clock:    in  std_logic;
            asyncIn:  in  std_logic;
            syncOut:  out std_logic
        );
    end component;

    component Debouncer is
        generic( DELAY_COUNT : positive);
        port(
            bitIn : in std_logic;
            clock : in std_logic;
            reset : in std_logic;

            debouncedOut : out std_logic
        );
    end component;

    component LevelDetector is
        port (
            reset:     in  std_logic;
            clock:     in  std_logic;
            trigger:   in  std_logic;
            pulseOut:  out std_logic
        );
    end component;

    -------------------------------------------------------------------------------
    -- synchronized 16 bit wide vector of switches
    -- vector is fed to a debouncer then finally a pulse controller
    -------------------------------------------------------------------------------
    signal synchedSwitches : std_logic_vector(NUM_OF_SWITCHES-1 downto 0);
    signal debouncedSwitches : std_logic_vector(NUM_OF_SWITCHES-1 downto 0);
    signal pulsedSwitches : std_logic_vector(NUM_OF_SWITCHES-1 downto 0);

    -------------------------------------------------------------------------------
    -- synchronised start button signal path
    -------------------------------------------------------------------------------
    signal startButtonSync : std_logic;
    signal startButtonDebounced : std_logic;
    signal startButtonPulsed : std_logic;

    -------------------------------------------------------------------------------
    --signals for SevenSegmentDriver component
    -------------------------------------------------------------------------------
    signal blanks : std_logic_vector(3 downto 0);
    signal outputScore : std_logic_vector(7 downto 0);
    signal outputGameNumber : std_logic_vector(7 downto 0);
    

    begin------------------------------------------------------------------------------begin

    MEMORY_GAME : component MemoryGame
        port map(
            switches         => pulsedSwitches,

            start            => startButtonPulsed,

            clock            => clk,
            reset            => btnD,

            leds             => led,

            outputGameNumber => outputGameNumber,
            outputScore      => outputScore,
            
            blanks           => blanks
        );
    
    ------------------------------------------------------------------------------------
    --component insantiations
    ------------------------------------------------------------------------------------
    SEGMENT_DRIVER : component SevenSegmentDriver port map(
        reset     => btnD,
        clock     => clk,

        digit3    => outputScore(7 downto 4),
        digit2    => outputScore(3 downto 0),
        digit1    => outputGameNumber(7 downto 4),
        digit0    => outputGameNumber(3 downto 0),

        blank3    => blanks(3),
        blank2    => blanks(2),
        blank1    => blanks(1),
        blank0    => blanks(0),


        sevenSegs => seg,
        anodes    => an
    );

    ------------------------------------------------------------------------------------
    -- generate chain of 2 flip-flops for each vector switch element
    ------------------------------------------------------------------------------------
    SYNC : for i in 0 to NUM_OF_SWITCHES-1 generate
        SYNC_X : component SynchronizerChain
            generic map(
                CHAIN_SIZE => CHAIN_SIZE
            )
            port map(
                reset   => btnD,
                clock   => clk,
                asyncIn => sw(i),
                syncOut => synchedSwitches(i) --all switches now clock synced
            );
    end generate;

    ------------------------------------------------------------------------------------
    -- generate debounce control for each vector switch element
    ------------------------------------------------------------------------------------
    DEBOUNCE : for i in 0 to NUM_OF_SWITCHES-1 generate
        DEBOUNCE_X : component Debouncer
            generic map(
                DELAY_COUNT => DELAY_COUNT
            )
            port map(
                bitIn        => synchedSwitches(i),
                clock        => clk,
                reset        => btnD,
                debouncedOut => debouncedSwitches(i) --all switches now debounced
            );
    end generate;

    ------------------------------------------------------------------------------------
    -- make each switch pulse, once per activation, reset once the switch is down
    ------------------------------------------------------------------------------------
    PULSE : for i in 0 to NUM_OF_SWITCHES-1 generate
        PULSE_X : component LevelDetector
            port map(
                reset    => btnD,
                clock    => clk,
                trigger  => debouncedSwitches(i),
                pulseOut => pulsedSwitches(i) --all switches now pulse controlled
            );
    end generate;        


    START_BUTTON_SYNC : SynchronizerChain
        generic map(
            CHAIN_SIZE => CHAIN_SIZE
        )
        port map(
            reset   => btnD,
            clock   => clk,
            asyncIn => btnC,
            syncOut => startButtonSync --start button is now synced
    );

    START_BUTTON_DEBOUNCE : component Debouncer
        generic map(
            DELAY_COUNT => DELAY_COUNT
        )
        port map(
            bitIn        => startButtonSync,
            clock        => clk,
            reset        => btnD,
            debouncedOut => startButtonDebounced --start button is now debounced
    );

    START_BUTTON_PULSE : LevelDetector 
        port map(
            reset    => btnD,
            clock    => clk,
            trigger  => startButtonDebounced,
            pulseOut => startButtonPulsed --start button is now pulsed
    );
    
end MemoryGame_Basys3_ARCH;
