library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------
--Title: Lab_2_SwitchLed
--Name: Nathaniel Roberts
--Date: 2/12/25
--Prof: Scott Tippens
--Desc: Testbench for wrapper to stimulate all combinations 
--      of inputs using a for loop cast to std_logic_vector
------------------------------------------------------------

entity SwitchLed_Basys3TB is
end SwitchLed_Basys3TB;

architecture behavioral  of SwitchLed_Basys3TB is

    -----------------------------------------------
    --Instantiate component
    -----------------------------------------------
    component SwitchLed_Basys3 is
        port(
            sw   : in std_logic_vector(2 downto 0);
            btnL : in std_logic;
            btnR : in std_logic;

            led : out std_logic_vector(15 downto 0);
            an  : out std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    -----------------------------------------------
    --Create TB signals
    -----------------------------------------------
    signal inputBus : std_logic_vector(4 downto 0) := "00000";

    signal led : std_logic_vector(15 downto 0);
    signal an  : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector(6 downto 0);

begin

    -----------------------------------------------
    --Create component instance within design
    --component => signal,
    -----------------------------------------------
    UUT : SwitchLed_Basys3 port map(
        sw   => inputBus(2 downto 0),
        btnL => inputBus(3),
        btnR => inputBus(4),

        led => led,
        an  => an,
        seg => seg
    );

    -----------------------------------------------
    --Main stimulus process to make all possible values
    -----------------------------------------------
    SIGNAL_DRIVER: process
    begin
        wait for 1 ns;
        test_loop : for i in 0 to 31 loop
            inputBus <= std_logic_vector(to_unsigned(i, 5));
            wait for 1 ns;
        end loop;
    wait;
    end process;
end behavioral ;
