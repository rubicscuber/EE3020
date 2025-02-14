library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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
      clk : in std_logic;

      led : out std_logic_vector(15 downto 0);
      an  : out std_logic_vector(3 downto 0);
      seg : out std_logic_vector(6 downto 0));
  end component;

  -----------------------------------------------
  --Create TB signals
  -----------------------------------------------
  signal inputBus : std_logic_vector(4 downto 0) := "00000";
  signal clk : std_logic := '0';

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
    clk => clk,

    led => led,
    an  => an,
    seg => seg);

  -----------------------------------------------
  --Assign inputBus to internal signals
  --for readablilty in the waveform viewer
  --pro tip dont do this, it leads to messy meta values
  -----------------------------------------------
  --sw <= inputBus(2 downto 0);
  --btnL <= inputBus(3);
  --btnR <= inputBus(4);


  --------------------clockgen process--------------------------
  clkGen : process
  begin
      wait for 5 ns;
      clk <= not clk;
  end process clkGen;

  -----------------------------------------------
  --Main stimulus process to make all possible values
  -----------------------------------------------
  stimulus: process
  begin
    --wait for 1 ms;
    test_loop : for i in 0 to 31 loop
      inputBus <= std_logic_vector(to_unsigned(i, 5));
      wait for 500 ns;
    end loop;
  wait;
  end process;
end behavioral ;
