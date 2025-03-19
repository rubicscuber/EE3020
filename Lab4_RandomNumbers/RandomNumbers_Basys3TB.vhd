library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RandomNumbers_Basys3TB is
end entity;

architecture Behavioral of RandomNumbers_Basys3TB is

    component RandomNumbers_Basys3 is
        port(
            btnC : in std_logic; --generateEN
            btnD : in std_logic; --reset
            clk : in std_logic;
            
            led : out std_logic_vector(15 downto 0);
            an  : out std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;   

    signal btnC : std_logic := '0';
    signal btnD : std_logic;
    signal clk  : std_logic := '0';

    signal led : std_logic_vector(15 downto 0);
    signal an  : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector(6 downto 0);

begin

    UUT : RandomNumbers_Basys3 port map(
        btnC   => btnC,
        btnD   => btnD,
        clk    => clk,

        led => led,
        an  => an,
        seg => seg
    );

    CLOCK_GEN : process 
    begin
        clk <= not clk;
        wait for 2380 ps;
    end process;

    RESET_GEN : process
    begin
        btnD <= '0';
        wait for 10 ns;
        btnD <= '1';
        wait for 10 ns;
        btnD <= '0';
        wait;
    end process;

    STIMULUS : process
    begin
        btnC <= '0';
        wait for 50 ns;
        btnC <= '1';
        wait for 100 ns;

        btnC <= '0';
        wait for 500 ns;

        btnC <= '1';
        wait for 20 ns;
        btnC <= '0';
        wait for 2 us;

        wait;
    end process;

end architecture Behavioral ;

