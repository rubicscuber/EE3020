library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RandomNumbersTB is
end RandomNumbersTB;

architecture Behavioral of RandomNumbersTB is

    ------------------------------------------
    --Component definition
    ------------------------------------------
    component RandomNumbers is
        port (
        generateEN : in std_logic;
        reset : in std_logic;
        clock : in std_logic;

        number0 : out std_logic_vector(3 downto 0);
        number1 : out std_logic_vector(3 downto 0);
        number2 : out std_logic_vector(3 downto 0);
        number3 : out std_logic_vector(3 downto 0);
        number4 : out std_logic_vector(3 downto 0);

        readyEN : out std_logic
        );
    end component;
    ------------------------------------------
    --signals to connect to components
    ------------------------------------------
    signal generateEN : std_logic;
    signal reset : std_logic;
    signal clock : std_logic;
    
    signal number0 : std_logic_vector(3 downto 0);
    signal number1 : std_logic_vector(3 downto 0);
    signal number2 : std_logic_vector(3 downto 0);
    signal number3 : std_logic_vector(3 downto 0);
    signal number4 : std_logic_vector(3 downto 0);
     
    signal readyEN : std_logic;
    
    
begin

    ------------------------------------------
    --instantiatine components within design
    --component_pin => tb_signal,
    ------------------------------------------
    UUT : RandomNumbers port map(
        generateEN => generateEN,
        reset => reset,
        clock => clock,

        number0 => number0,
        number1 => number1,
        number2 => number2,
        number3 => number3,
        number4 => number4,

        readyEN => readyEN
    );

    ------------------------------------------
    --clockgen process
    ------------------------------------------
    CLOCK_GEN : process
    begin
        wait for 1 ns; --100MHz clock = 5ns to toggle
        clock <= not clock;
    end process; 

    ------------------------------------------
    --input stimulus
    ------------------------------------------
    stimulus : process
    begin

    end process;

end Behavioral;
