library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SevenSegmentTB is
end SevenSegmentTB;


architecture Behavioral of SevenSegmentTB is

  ---------------------Component declerations---------------------
  component SevenSegment is
    port (
      numLeds : in std_logic_vector(2 downto 0);
      cathodes : out std_logic_vector(6 downto 0)
    );
  end component;

  ----------------------signals for components-------------------
  signal numLeds    : std_logic_vector(2 downto 0) := "000";
  signal cathodes   : std_logic_vector(6 downto 0);


begin
  ------------instantiatine components within design-------------
  --component_pin => tb_signal,
  UUT : SevenSegment port map(
    numLeds  => numLeds,
    cathodes => cathodes);

  --------------------clockgen process--------------------------
 -- clkGen : process
 -- begin
 --     wait for 5 ns;
 --     clk <= not clk;
 -- end process clkGen;
------------------------input stimulus--------------------------
	stimulus : process
	begin
      wait for 1 ns;
      test_loop : for k in 0 to 7 loop
        numLeds <= std_logic_vector(to_unsigned(k, 3)); --to_unsigned(integer, length)
        wait for 1 ns;
      end loop test_loop;
	wait;
	end process;

end Behavioral;
