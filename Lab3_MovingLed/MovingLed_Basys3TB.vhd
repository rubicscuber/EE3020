library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MovingLed_Basys3TB is
end entity MovingLed_Basys3TB;

architecture MovingLed_Basys3TB_ARCH of MovingLed_Basys3TB is
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

  signal inputs : std_logic_vector(3 downto 0);

  signal an  : std_logic_vector(3 downto 0);
  signal seg : std_logic_vector(6 downto 0);
  signal led : std_logic_vector(15 downto 0);

begin

  UUT : MovingLed_Basys3 port map(
    btnL => inputs(3),
    btnR => inputs(2),
    btnC => inputs(1),
    clk  => inputs(0),

    an => an,
    seg => seg,
    led => led
  );

  stimulus : process
  begin
    for k in 0 to 15 loop
      inputs <= std_logic_vector(to_unsigned(k, 4));
      wait for 1 ns;
      end loop;
  wait;
  end process;

end architecture MovingLed_Basys3TB_ARCH;
