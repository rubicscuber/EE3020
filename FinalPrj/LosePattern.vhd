library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------
--Title: LosePattern.vhd
--Name: Nathaniel Roberts, Mitch Walker
--Date: 
--Prof: Scott Tippens
--Desc: Lose Pattern generator
--      And overly complex desin in code to essentially display a draining health bar.
--       
--      Each pattern that is ouput to the leds is represented by a custom state.
--      
--      The state machine of this file switches through all 16 patterns at the rate of 
--      once every 1/4 second
------------------------------------------------------------------------------------

entity LosePattern is
    generic(BLINK_COUNT : natural); 
    port(
        
        losePatternEN : in std_logic; 

        reset: in std_logic;
        clock: in std_logic;

        leds: out std_logic_vector(15 downto 0);

        losePatternIsBusy : out std_logic
    );
end LosePattern;

architecture LosePattern_ARCH of LosePattern is

    type States_t is (BLANK, 
                      PATTERN0,
                      PATTERN1,
                      PATTERN2,
                      PATTERN3,
                      PATTERN4,
                      PATTERN5,
                      PATTERN6,
                      PATTERN7,
                      PATTERN8,
                      PATTERN9,
                      PATTERN10,
                      PATTERN11,
                      PATTERN12,
                      PATTERN13,
                      PATTERN14,
                      PATTERN15);
    signal currentState: States_t;
    signal nextState: States_t;

    constant ACTIVE: std_logic := '1';

    constant HIGH_Z_LEDS : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";
    constant PATTERN0_LEDS : std_logic_vector(15 downto 0)  := "1111111111111111";
    constant PATTERN1_LEDS : std_logic_vector(15 downto 0)  := "1111111111111110";
    constant PATTERN2_LEDS : std_logic_vector(15 downto 0)  := "1111111111111100";
    constant PATTERN3_LEDS : std_logic_vector(15 downto 0)  := "1111111111111000";
    constant PATTERN4_LEDS : std_logic_vector(15 downto 0)  := "1111111111110000";
    constant PATTERN5_LEDS : std_logic_vector(15 downto 0)  := "1111111111100000";
    constant PATTERN6_LEDS : std_logic_vector(15 downto 0)  := "1111111111000000";
    constant PATTERN7_LEDS : std_logic_vector(15 downto 0)  := "1111111110000000";
    constant PATTERN8_LEDS : std_logic_vector(15 downto 0)  := "1111111100000000";
    constant PATTERN9_LEDS : std_logic_vector(15 downto 0)  := "1111111000000000";
    constant PATTERN10_LEDS : std_logic_vector(15 downto 0) := "1111110000000000";
    constant PATTERN11_LEDS : std_logic_vector(15 downto 0) := "1111100000000000";
    constant PATTERN12_LEDS : std_logic_vector(15 downto 0) := "1111000000000000";
    constant PATTERN13_LEDS : std_logic_vector(15 downto 0) := "1110000000000000";
    constant PATTERN14_LEDS : std_logic_vector(15 downto 0) := "1100000000000000";
    constant PATTERN15_LEDS : std_logic_vector(15 downto 0) := "1000000000000000";

    signal stateMachineControl: std_logic;

begin



    ------------------------------------------------------------------------------------
    -- The state machine register that keeps track of when to switch to the next state.
    ------------------------------------------------------------------------------------
    STATE_REGISTER: process(reset, clock)
        begin
            if reset = ACTIVE then
                currentState <= BLANK;
            elsif rising_edge(clock) then
                currentState <= nextState;
            end if;
    end process;

    ------------------------------------------------------------------------------------
    -- The overly complex and long winded state machine that selects different signals
    -- to reach the output. If this module is done, then the ouput is high-Z. While
    -- this module runs, output a busy signal to tell the rest of the design it busy.
    ------------------------------------------------------------------------------------
    WIN_PATTERN_SM: process(currentState, stateMachineControl, losePatternEN)
    begin
        case CurrentState is
    -------------------------------------------------------------------------------BLANK
            when BLANK => 
                leds <= HIGH_Z_LEDS;
                losePatternIsBusy <= not ACTIVE;
                if (losePatternEN = ACTIVE) then
                    nextState <= PATTERN0;
                else
                    nextState <= BLANK;
                end if;
    ----------------------------------------------------------------------------PATTERN0

            when PATTERN0 =>
                leds <= PATTERN0_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = not ACTIVE) then
                    nextState <= PATTERN1;
                else
                    nextState <= PATTERN0;
                end if;
    -----------------------------------------------------------------------------PATTERN1

            when PATTERN1 =>
                leds <= PATTERN1_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = ACTIVE) then
                    nextState <= PATTERN2;
                else
                    nextState <= PATTERN1;
                end if;
    -----------------------------------------------------------------------------PATTERN2

            when PATTERN2 =>
                leds <= PATTERN2_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = not ACTIVE) then
                    nextState <= PATTERN3;
                else
                    nextState <= PATTERN2;
                end if;
    -----------------------------------------------------------------------------PATTERN3

            when PATTERN3 =>
                leds <= PATTERN3_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = ACTIVE) then
                    nextState <= PATTERN4;
                else
                    nextState <= PATTERN3;
                end if;
    -----------------------------------------------------------------------------PATTERN4

            when PATTERN4 =>
                leds <= PATTERN4_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = not ACTIVE) then
                    nextState <= PATTERN5;
                else
                    nextState <= PATTERN4;
                end if;
    -----------------------------------------------------------------------------PATTERN5

            when PATTERN5 =>
                leds <= PATTERN5_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = ACTIVE) then
                    nextState <= PATTERN6;
                else
                    nextState <= PATTERN5;
                end if;
    -----------------------------------------------------------------------------PATTERN6

            when PATTERN6 =>
                leds <= PATTERN6_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = not ACTIVE) then
                    nextState <= PATTERN7;
                else
                    nextState <= PATTERN6;
                end if;
    -----------------------------------------------------------------------------PATTERN7

            when PATTERN7 =>
                leds <= PATTERN7_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = ACTIVE) then
                    nextState <= PATTERN8;
                else
                    nextState <= PATTERN7;
                end if;
    -----------------------------------------------------------------------------PATTERN8

            when PATTERN8 =>
                leds <= PATTERN8_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = not ACTIVE) then
                    nextState <= PATTERN9;
                else
                    nextState <= PATTERN8;
                end if;
    -----------------------------------------------------------------------------PATTERN9

            when PATTERN9 =>
                leds <= PATTERN9_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = ACTIVE) then
                    nextState <= PATTERN10;
                else
                    nextState <= PATTERN9;
                end if;
    -----------------------------------------------------------------------------PATTERN10

            when PATTERN10 =>
                leds <= PATTERN10_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = not ACTIVE) then
                    nextState <= PATTERN11;
                else
                    nextState <= PATTERN10;
                end if;
    -----------------------------------------------------------------------------PATTERN11

            when PATTERN11 =>
                leds <= PATTERN11_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = ACTIVE) then
                    nextState <= PATTERN12;
                else
                    nextState <= PATTERN11;
                end if;
    -----------------------------------------------------------------------------PATTERN12

            when PATTERN12 =>
                leds <= PATTERN12_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = not ACTIVE) then
                    nextState <= PATTERN13;
                else
                    nextState <= PATTERN12;
                end if;
    -----------------------------------------------------------------------------PATTERN13

            when PATTERN13 =>
                leds <= PATTERN13_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = ACTIVE) then
                    nextState <= PATTERN14;
                else
                    nextState <= PATTERN13;
                end if;
    -----------------------------------------------------------------------------PATTERN14

            when PATTERN14 =>
                leds <= PATTERN14_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = not ACTIVE) then
                    nextState <= PATTERN15;
                else
                    nextState <= PATTERN14;
                end if;
    -----------------------------------------------------------------------------PATTERN15

            when PATTERN15 =>
                leds <= PATTERN15_LEDS;
                losePatternIsBusy <= ACTIVE;
                if (stateMachineControl = ACTIVE) then
                    nextState <= BLANK;
                else
                    nextState <= PATTERN15;
                end if;
        end case;
    end process;

    DISPLAY_RATE: process(reset, clock)
        variable count: integer range 0 to BLINK_COUNT;
    begin
        if (reset = ACTIVE) then
            count := 0;
            stateMachineControl <=  not ACTIVE;
        elsif (rising_edge(clock)) then
            if (count >= BLINK_COUNT) then
                count := 0;
                stateMachineControl <= not stateMachineControl;
            else
                count := count + 1;
            end if;
        end if;
    end process DISPLAY_RATE;

end LosePattern_ARCH;

