library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RandomNumbersTB is
end RandomNumbersTB;

architecture Behavioral of RandomNumbersTB is

    ------------------------------------------
    --Component definition
    ------------------------------------------

    ------------------------------------------
    --signals to connect to components
    ------------------------------------------
 
begin

    ------------------------------------------
    --instantiatine components within design
    --component_pin => tb_signal,
    ------------------------------------------
    UUT : My_design.vhd port map(
    );

    ------------------------------------------
    --clockgen process
    ------------------------------------------
    CLOCK_GEN : process
    begin
        wait for 1 ns; --100MHz clock = 5ns to toggle
        clk <= not clk;
    end process clkGen;

    ------------------------------------------
    --input stimulus
    ------------------------------------------
    stimulus : process
    begin

    end process;

end Behavioral;
