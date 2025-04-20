library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
--Title: RandomNumbers.vhd
--Name: Nathaniel Roberts, Mitch Walker
--Date: 3/26/25
--Prof: Scott Tippens

-- Description: Random Number Generator
--    This component utilizes 5 counters incrementing at different rates to
--    generate 5 psuedo-random numbers
--
--    Each RandCounter has a sub counter. Once the sub counter reaches its 
--    max value (set externally through maxSubCount) the randNum counter is 
--    incremented
--
--    Once generateEN recieves a pulse, SET_RAND_NUM sets the output signals 
--    to their corresponding randNum counter value. SET_RAND_NUM them sends 
--    a pulsed signal through readyEN to signify that new random numbers 
--    have been set
--    Dependencies: RandCounter.vhd
----------------------------------------------------------------------------------

entity RandomNumbers is
    port (
        generateEN  : in std_logic;
        clock       : in std_logic;
        reset       : in std_logic;
        
        readyEN     : out std_logic;
        number0     : out std_logic_vector(3 downto 0);
        number1     : out std_logic_vector(3 downto 0);
        number2     : out std_logic_vector(3 downto 0);
        number3     : out std_logic_vector(3 downto 0);
        number4     : out std_logic_vector(3 downto 0)
    );
end RandomNumbers;

architecture RandomNumbers_ARCH of RandomNumbers is
    ---------------------------------------------------------------------------------
    -- Constants
    ---------------------------------------------------------------------------------
    constant ACTIVE                 : std_logic := '1'; -- Active value
    constant COUNTER_MAX_VALUE      : integer   := 15;  -- Max value for 'random' counters
    constant maxSubCount_Length     : integer   := 3;   -- Length of the subCount signal within RandCounter component

    constant MAX_SUB_COUNT_0 : integer   := 3;   -- Max value for sub counter 1
    constant MAX_SUB_COUNT_1 : integer   := 1;   -- Max value for sub counter 2
    constant MAX_SUB_COUNT_2 : integer   := 2;   -- Max value for sub counter 3
    constant MAX_SUB_COUNT_3 : integer   := 5;   -- Max value for sub counter 4
    constant MAX_SUB_COUNT_4 : integer   := 4;   -- Max value for sub counter 5

    ----------------------------------------------------------------------------------
    -- Components 
    ----------------------------------------------------------------------------------
    component RandCounter is
        port (
            maxSubCount : in std_logic_vector(2 downto 0);
            clock       : in std_logic;
            reset       : in std_logic;
      
            randNum     : out std_logic_vector(3 downto 0)
        );
    end component;

    ----------------------------------------------------------------------------------
    -- Signals 
    ----------------------------------------------------------------------------------
    signal randNum0 : std_logic_vector(3 downto 0);
    signal randNum1 : std_logic_vector(3 downto 0);
    signal randNum2 : std_logic_vector(3 downto 0);
    signal randNum3 : std_logic_vector(3 downto 0);
    signal randNum4 : std_logic_vector(3 downto 0);
    
    
begin

    ---------------------------------------------------------------------------------
    -- Component Instatiations
    ---------------------------------------------------------------------------------
    -- Used to generate pseudo-random value for randNum0
    RAND_COUNTER_0 : RandCounter port map (
      maxSubCount   => std_logic_vector(to_unsigned(MAX_SUB_COUNT_0, maxSubCount_Length)),
      clock         => clock,
      reset         => reset,
      randNum       => randNum0
    );

    RAND_COUNTER_1 : RandCounter port map (
      maxSubCount   => std_logic_vector(to_unsigned(MAX_SUB_COUNT_1, maxSubCount_Length)),
      clock         => clock,
      reset         => reset,
      randNum       => randNum1
    );

    RAND_COUNTER_2 : RandCounter port map (
      maxSubCount   => std_logic_vector(to_unsigned(MAX_SUB_COUNT_2, maxSubCount_Length)),
      clock         => clock,
      reset         => reset,
      randNum       => randNum2
    );

    RAND_COUNTER_3 : RandCounter port map (
      maxSubCount   => std_logic_vector(to_unsigned(MAX_SUB_COUNT_3, maxSubCount_Length)),
      clock         => clock,
      reset         => reset,
      randNum       => randNum3
    );

    RAND_COUNTER_4 : RandCounter port map (
      maxSubCount   => std_logic_vector(to_unsigned(MAX_SUB_COUNT_4, maxSubCount_Length)),
      clock         => clock,
      reset         => reset,
      randNum => randNum4
    );

    ---------------------------------------------------------------------------------
    -- Checks for generateEN signal
    -- Sets the output numbers to the current values of their respective counters
    -- Outputs a pule through readyEN
    ---------------------------------------------------------------------------------
    SET_RAND_NUM : process(clock, reset) 
        variable newNumSet : std_logic := not ACTIVE;
    begin        
        if reset = ACTIVE then
            readyEN     <= not ACTIVE;
            newNumSet   := not ACTIVE;

            number0     <= "0000";
            number1     <= "0000";
            number2     <= "0000";
            number3     <= "0000";
            number4     <= "0000";
        elsif rising_edge(clock) then
            if generateEN = ACTIVE then
                number0     <= randNum0;
                number1     <= randNum1;
                number2     <= randNum2;
                number3     <= randNum3;
                number4     <= randNum4;
                newNumSet   := ACTIVE;
            end if;

            if newNumSet = ACTIVE then
                readyEN     <= ACTIVE;
                newNumSet   := not ACTIVE;
            else
                readyEN     <= not ACTIVE;
            end if;
        end if;
    end process;

end RandomNumbers_ARCH;
