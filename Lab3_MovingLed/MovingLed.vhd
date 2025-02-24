library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------
--Title: Lab_3_MovingLed
--Name: Nathaniel Roberts
--Date: 
--Prof: Scott Tippens
--Desc: 
--      
--      
--      
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

    --shift register made from two seperate registers
    --reg0InputState is updated in DEBOUNCE
    --reg1InputState gets shifted with reg0InputState in SHIFT_REGISTERS
    --if reg0 = 1, and reg1 = 0, that means a button press was detected
    signal reg0InputState : std_logic := '0';
    signal reg1InputState : std_logic := '1';

    signal regPosition : unsigned (3 downto 0) := "0000";

    signal moveLeft : std_logic;
    signal moveRight : std_logic;

    --constant DELAY_COUNT : integer := 10; --uncomment for testing only
    constant DELAY_COUNT : integer := 1000000; --10ms delay on a 100MHz clock (0.01s) is 1M

begin

    inputState <= leftButton or rightButton; 
    position <= std_logic_vector(regPosition);

    DEBOUNCE : process(clock)
        variable counter : integer range 0 to DELAY_COUNT;
    begin
        if rising_edge(clock) then
            moveLeft <= '0';
            moveRight <= '0';
            if inputState /= reg0InputState and counter < DELAY_COUNT then
                counter := counter + 1;
            -- this executes if and only if the button has been held long enough
            elsif counter = DELAY_COUNT then
                reg0InputState <= inputState; 
                counter := 0;
                if (leftButton = '1') and (rightButton = '0') then
                    moveLeft <= '1';
                    moveRight <= '0';
                end if;
                if (leftButton = '0') and (rightButton = '1') then
                    moveLeft <= '0';
                    moveRight <= '1';
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
        if resetButton = '1' then
            regPosition <= (others => '0');
        elsif rising_edge(clock) then
            if (reg0InputState = '1') and (reg1InputState = '0') then 
                if (moveLeft = '1') and (regPosition < 15) then
                    regPosition <= regPosition + 1;
                end if;
                if (moveRight = '1') and (regPosition > 0) then 
                    regPosition <= regPosition - 1;
                end if;
            end if;
        end if;
    end process;

end architecture MovingLed_ARCH;

