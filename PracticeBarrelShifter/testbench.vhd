library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture Behavioral of testbench is

--instantiate component
component BarrelShifter is
    port (
    dataIn    : in std_logic_vector(7 downto 0);
    direction : in std_logic;
    shiftBy   : in std_logic_vector(2 downto 0);

    dataOut   : out std_logic_vector(7 downto 0)
    );
end component;

--instantiate signals
signal dataIn     : std_logic_vector(7 downto 0);
signal direction  : std_logic;
signal shiftBy    : std_logic_vector(2 downto 0);
signal dataOut    : std_logic_vector(7 downto 0);

constant outer    : integer := 255;
constant inner    : integer := 7;

begin

  --component_pin => tb_signal,
	UUT : BarrelShifter port map(
  dataIn      => dataIn,
  direction   => direction,
  shiftBy     => shiftBy,
  dataOut     => dataOut
  );

  --stimulate all input signals
stimulus : process
begin
  direction <= '0';
  wait for 1 ns;
		outer_loop : for k in 0 to outer loop
      DataIn <= std_logic_vector(to_unsigned(k, 8)); --to_unsigned(integer, length)
      inner_loop : for j in 0 to inner loop
        shiftBy <= std_logic_vector(to_unsigned(j, 3));
        wait for 1 ns;
      end loop inner_loop;
		end loop outer_loop;

  direction <= '1';
  wait for 1 ns;
    outer_loop2 : for i in 0 to outer loop
      DataIn <= std_logic_vector(to_unsigned(i, 8));
        inner_loop2 : for l in 0 to inner loop
          shiftBy <= std_logic_vector(to_unsigned(l, 3));
          wait for 1 ns;
      end loop inner_loop2;
    end loop outer_loop2; wait;
end process;

end Behavioral;
