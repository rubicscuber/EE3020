library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MovingLedTB is
end MovingLedTB;

architecture Behavioral of MovingLedTB is

  ---------------------Component declerations---------------------


  ----------------------signals for components-------------------
 
begin
  ------------instantiatine components within design-------------
  --component_pin => tb_signal,
	ClockAndDigit : DigitSelector port map(
	clk => clk,
  currentDigit => s_currentDigit);

  Driver : RefereeDisplayDriver port map(

  dataIn      => dataIn,
  activeAnode => s_currentDigit,
  an0         => an0,
  an1         => an1,
  an2         => an2,
  an3         => an3,

  seg0        => seg0,
  seg1        => seg1,
  seg2        => seg2,
  seg3        => seg3,
  seg4        => seg4,
  seg5        => seg5,
  seg6        => seg6);


  --------------------clockgen process--------------------------
  clkGen : process
  begin
      wait for 5 ns;
      clk <= not clk;
  end process clkGen;
------------------------input stimulus--------------------------
	stimulus : process
	begin
    dataIn <= '0';
    wait for 18 ms;
    dataIn <= '1';
    wait for 16 ms;
		--test_loop : for k in 0 to  loop
    --  inputs <= std_logic_vector(to_unsigned(k, 4)); --to_unsigned(integer, length)
		--	wait for 1 ns;
		--end loop test_loop;
	wait;
	end process;

end Behavioral;
