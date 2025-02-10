library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity testbench is
end testbench;

architecture Behavioral of testbench is

  ---------------------Component declerations---------------------
  component TOP is
    port(
    sw0 : in std_logic;
    sw1 : in std_logic;
    sw2 : in std_logic;
    sw3 : in std_logic;
    
    clk : in std_logic;

    an0 : out std_logic;
    an1 : out std_logic;
    an2 : out std_logic;
    an3 : out std_logic;

    seg0: out std_logic;
    seg1: out std_logic;
    seg2: out std_logic;
    seg3: out std_logic;
    seg4: out std_logic;
    seg5: out std_logic;
    seg6: out std_logic); 
  end component;
  
  ----------------------signals for components-------------------
  signal inputs : std_logic_vector(3 downto 0);

  signal   clk : std_logic := '0';

  signal   an0 :  std_logic;
  signal   an1 :  std_logic;
  signal   an2 :  std_logic;
  signal   an3 :  std_logic;

  signal   seg0:  std_logic;
  signal   seg1:  std_logic;
  signal   seg2:  std_logic;
  signal   seg3:  std_logic;
  signal   seg4:  std_logic;
  signal   seg5:  std_logic;
  signal   seg6:  std_logic;

begin
  ------------instantiatine components within design-------------
  ------------component_pin => tb_signal,
	UUT : TOP port map(
   sw0 => inputs(0),
   sw1 => inputs(1),
   sw2 => inputs(2),
   sw3 => inputs(3),

   clk => clk,

   an0 => an0,
   an1 => an1,
   an2 => an2,
   an3 => an3,

   seg0=> seg0,
   seg1=> seg1,
   seg2=> seg2,
   seg3=> seg3,
   seg4=> seg4,
   seg5=> seg5,
   seg6=> seg6);

  
  --------------------clockgen process--------------------------
  clkGen : process
  begin
      wait for 5 ns;
      clk <= not clk;
  end process clkGen;
------------------------input stimulus--------------------------
	stimulus : process
	begin
		test_loop : for k in 0 to 15 loop
      inputs <= std_logic_vector(to_unsigned(k, 4)); --to_unsigned(integer, length)
			wait for 4 ms;
		end loop test_loop;
	wait;
	end process;

end Behavioral;
