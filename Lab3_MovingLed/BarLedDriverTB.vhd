library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BarLedDriverTB is
end entity BarLedDriverTB;


architecture BarLedDriverTB_ARCH of BarLedDriverTB is
  component BarLedDriver is
    port (
      position : in std_logic_vector(3 downto 0);
      bar : out std_logic_vector(15 downto 0)
    );
  end component;

  signal position : std_logic_vector(3 downto 0) := "0000";
  signal bar : std_logic_vector(15 downto 0);

begin

  UUT : BarLedDriver port map(
    position => position,
    bar => bar);
  
  stimulus : process
  begin
    test_loop : for k in 0 to 15 loop
      position <= std_logic_vector(to_unsigned(k,4));
      wait for 1 ns;
    end loop test_loop;
  wait;
  end process;
  
end architecture BarLedDriverTB_ARCH;
