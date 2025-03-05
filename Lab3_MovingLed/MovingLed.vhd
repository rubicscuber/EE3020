library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------
--Title: Lab_3_MovingLed
--Name: Nathaniel Roberts, Mitch Walker
--Date: 3/4/25
--Prof: Scott Tippens
--Desc: Traverse the Led around using a counter
--      the counter's output would be decoded into the 
--      16 bit wide led bus for visual output. A rising
--      edge is detected using a single shift register
--      that is debounced.
------------------------------------------------------------

entity MovingLed is
    port (
        leftButton  : in std_logic;
        rightButton : in std_logic;
        resetButton : in std_logic;
        clock : in std_logic;

        position : out std_logic_vector(3 downto 0)
    );
end MovingLed;

architecture MovingLed_ARCH of MovingLed is

    signal inputState : std_logic;

    --reg0InputState is updated in DEBOUNCE
    --reg0 and reg1 are evaluated in UP_DOWN_COUNTER
    signal reg0InputState : std_logic := '0';
    signal reg1InputState : std_logic := '1';

    signal regPosition : unsigned (3 downto 0);

    signal moveLeft : std_logic;
    signal moveRight : std_logic;

    constant ACTIVE : std_logic := '1';

    constant DELAY_COUNT : integer := 10; --uncomment for testing only
    --constant DELAY_COUNT : integer := 1000000; --10ms delay on a 100MHz clock (0.01s) is 1M

begin

    inputState <= leftButton or rightButton; 
    position <= std_logic_vector(regPosition);

    DEBOUNCE : process(clock)
        variable counter : integer range 0 to DELAY_COUNT;
    begin
        if rising_edge(clock) then
            moveLeft <= not ACTIVE;
            moveRight <= not ACTIVE;
            if inputState /= reg0InputState and counter < DELAY_COUNT then
                counter := counter + 1;

            -- this happens if and only if the button has been held long enough
            elsif counter = DELAY_COUNT then

                --shift into the first register then reset counter
                reg0InputState <= inputState; 
                counter := 0;

                --set the move registers
                if (leftButton = ACTIVE) and (rightButton = not ACTIVE) then
                    moveLeft <= ACTIVE;
                end if;

                if (leftButton = not ACTIVE) and (rightButton = ACTIVE) then
                    moveRight <= ACTIVE;
                end if;

            else
                counter := 0;
            end if;
        end if;
    end process;

    SHIFT_REGISTERS : process(clock)
    begin
        if rising_edge(clock) then
            reg1InputState <= reg0InputState;
        end if;
    end process;

    UP_DOWN_COUNTER : process(clock, resetButton)
    begin
        if resetButton = ACTIVE then
            regPosition <= (others => '0');
        elsif rising_edge(clock) then

            --reg0 and reg1 effectively detect a rising edge once
            if (reg0InputState = ACTIVE) and (reg1InputState = not ACTIVE) then 

                if (moveLeft = ACTIVE) and (regPosition < 15) then
                    regPosition <= regPosition + 1;
                end if;

                if (moveRight = ACTIVE) and (regPosition > 0) then 
                    regPosition <= regPosition - 1;
                end if;

            end if;
        end if;
    end process;

end architecture MovingLed_ARCH;

