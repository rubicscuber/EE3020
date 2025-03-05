library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MovingLed_Basys3TB is
end entity MovingLed_Basys3TB;

------------------------------------------------------------
--Title: Lab_3_MovingLed
--Name: Nathaniel Roberts, Mitch Walker
--Date: 3/5/25
--Prof: Scott Tippens
--Desc: Testbench for MovingLed wrapper file. 
------------------------------------------------------------

architecture MovingLed_Basys3TB_ARCH of MovingLed_Basys3TB is

    ------------------------------------------------------------
    -- Define ports of the UUT
    ------------------------------------------------------------
    component MovingLed_Basys3 is
        port(
            btnL : in std_logic;
            btnR : in std_logic;
            btnC : in std_logic;
            clk  : in std_logic;

            an : out std_logic_vector(3 downto 0);
            seg: out std_logic_vector(6 downto 0);
            led: out std_logic_vector(15 downto 0)
        );
    end component;

    ------------------------------------------------------------
    -- Create testbench signals
    ------------------------------------------------------------
    signal btnL : std_logic := '0';
    signal btnR : std_logic := '0';
    signal btnC : std_logic := '0';
    signal clock : std_logic := '1';

    signal an  : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector(6 downto 0);
    signal led : std_logic_vector(15 downto 0);

    constant ACTIVE : std_logic := '1';


begin

    ------------------------------------------------------------
    -- instantiate component in testbench
    ------------------------------------------------------------
    UUT : MovingLed_Basys3 port map(
        btnL => btnL,
        btnR => btnR,
        btnC => btnC,
        clk => clock,

        an => an,
        seg => seg,
        led => led
    );

    ------------------------------------------------------------
    -- generate clock signal
    ------------------------------------------------------------
    CLOCK_GEN : process
    begin
        clock <= not clock;
        wait for 1 ns;
    end process CLOCK_GEN;

    SYSTEM_RESET : process
    begin
        btnC <= ACTIVE;
        wait for 1 ns;
        btnC <= not ACTIVE;

        wait for 10200 ns;
        btnC <= ACTIVE;
        wait for 300 ns;
        btnC <= not ACTIVE;

    end process;

    ------------------------------------------------------------
    --main stimulus process to navigate the leds
    ------------------------------------------------------------
    STIMULUS : process
    begin

    moveLeft : for k in 0 to 31 loop --move left
        btnL <= not btnL;
        wait for 300 ns;
    end loop moveLeft;

    moveRight : for k in 0 to 31 loop --move right
        btnR <= not btnR;
        wait for 300 ns;
    end loop moveRight;

    moveLeftAgain : for k in 0 to 31 loop --move left
        btnL <= not btnL;
        wait for 300 ns;
    end loop moveLeftAgain;

    moveRightAgain : for k in 0 to 31 loop --move right
        btnR <= not btnR;
        wait for 300 ns;
    end loop moveRightAgain;

    wait;
    end process;

end architecture MovingLed_Basys3TB_ARCH;
