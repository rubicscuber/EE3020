library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ShiftRegister is
    port (
        left :in std_logic;
        right : in std_logic;

        clock : in std_logic;
        reset : in std_logic;

        position: out std_logic_vector(3 downto 0);
        ledBarOut: out std_logic_vector(15 downto 0)
    );
end entity ShiftRegister;


architecture ShiftRegister_ARCH of ShiftRegister is

    constant DEFAULT_LED_BAR : std_logic_vector(15 downto 0) := "0000000000000001";
    signal ledBar : std_logic_vector(15 downto 0);
    signal moveEnable : std_logic;
    signal moveLeft : std_logic;
    signal moveRight : std_logic;

    signal reg0 : std_logic;
    signal reg1 : std_logic;

begin
    MOVE_ENABLE : process(clock, reset)
    begin
        if(reset = '1') then
            moveEnable <= '0';
        elsif(rising_edge(clock)) then
            moveEnable <= '0';
            moveLeft <= '0';
            moveRight <= '0';
            if (left = '1') and (right = '0') then
                moveEnable <= '1';
                moveLeft <= '1';
            end if;
            if (left = '0') and (right = '1') then
                moveEnable <= '1';
                moveRight <= '1';
            end if;
        end if;
    end process;

    RISING_EDGE_DETECTION : process (clock, reset)
    begin
        reg0 <= moveEnable;
        reg1 <= reg0;
    end process;

    SHIFT : process(clock, reset)
        varaible positionVar : integer range 0 to 15;
    begin
        if(reset = '1') then
            moveEnable <= '0';
        elsif(rising_edge(clock)) then
            if(reg0 = '1') and (reg1 = '0') then
                if(moveLeft = '1') and (positionVar < 15) then
                    ledBar <= ledBar(14 downto 0) & '0';
                    positionVar := positionVar + 1;
                end if;
                if(moveLeft = '1') and (positionVar > 0) then
                    ledBar <= '0' & ledBar(15 downto 1);
                    positionVar := positionVar - 1;
                end if;
            end if;
        end if;
        position <= std_logic_vector(to_unsigned(positionVar, 4));
    end process;
    
    ledBarOut <= ledBar;

end architecture ShiftRegister_ARCH;
