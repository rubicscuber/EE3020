library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------------
--Title: MemoryGame
--Name: Nathaniel Roberts, Mitch Walker
--Date: 4/23/25
--Prof: Scott Tippens
--Desc: Wrapper file
--      
--      This Top wrapper uses 3 generate statements for the array of 16 switches
--      The first in the signal chain is a SynchronizerChain component to handle 
--      meta stability. The second component debounces the switches and the final 
--      component pulsees each switch.
--      
--      The same hardware signal chain exists for the start button.
--      
------------------------------------------------------------------------------------

entity MemoryGame_Basys3 is
    generic(
        NUM_OF_SWITCHES : integer := 16;
        CHAIN_SIZE : integer := 2;
        DELAY_COUNT : integer := 10_000_000 --10ms on a 100MHz clock = 1M
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
    	generic(
    		MAX_COUNT_SCALER : integer;
    		SCALE_AMOUNT     : integer;
    		MAX_TOGGLE_COUNT : integer;
    		BLINK_COUNT      : integer
        );
    	port(
    		switches    : in  std_logic_vector(15 downto 0);
    		start       : in  std_logic;
    		clock       : in  std_logic;
    		reset       : in  std_logic;
    		leds        : out std_logic_vector(15 downto 0);
    		outputScore : out std_logic_vector(7 downto 0);
    		blanks      : out std_logic_vector(3 downto 0)
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


    begin------------------------------------------------------------------------------begin

    ------------------------------------------------------------------------------------
    --component insantiations
    ------------------------------------------------------------------------------------

    MEMORY_GAME : component MemoryGame 
        generic map(
        	MAX_COUNT_SCALER => 90_000_000,
        	SCALE_AMOUNT     => 15_000_000,
        	MAX_TOGGLE_COUNT => 100_000_000,
        	BLINK_COUNT      => 25_000_000
        )
    port map(
        switches         => pulsedSwitches,

        start            => startButtonPulsed,

        clock            => clk,
        reset            => btnD,

        leds             => led,

        outputScore      => outputScore,

        blanks           => blanks
    );

    SEGMENT_DRIVER : component SevenSegmentDriver port map(
        reset     => btnD,
        clock     => clk,

        digit3    => outputScore(7 downto 4),
        digit2    => outputScore(3 downto 0),
        digit1    => "0000",
        digit0    => "0000",

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


    ------------------------------------------------------------------------------------
    -- The following 3 components synchronize, debounce and pulse the start button.
    ------------------------------------------------------------------------------------
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
