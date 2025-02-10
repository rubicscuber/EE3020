library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity TOP is
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
end TOP;


architecture TOP_ARCH of TOP is

  ---------------------Component declerations---------------------
  component Election is
    port (
      ref0 : in std_logic;
      ref1 : in std_logic;
      ref2 : in std_logic;
      ref3 : in std_logic;
    
      decision : out std_logic);
  end component;

  component DigitSelector is
    port (
      clk_in  : in STD_LOGIC;
      annodeList : out std_logic_vector(3 downto 0));
  end component;

  component RefereeDisplayDriver is
    port (
      dataIn  : in STD_LOGIC;
      activeAnode : in std_logic_vector(3 downto 0);
      i_an0 : out std_logic;
      i_an1 : out std_logic;
      i_an2 : out std_logic;
      i_an3 : out std_logic;

      i_seg0: out std_logic;
      i_seg1: out std_logic;
      i_seg2: out std_logic;
      i_seg3: out std_logic;
      i_seg4: out std_logic;
      i_seg5: out std_logic;
      i_seg6: out std_logic);
  end component;


  ----------------------signals for components-------------------
  signal s_ref0 : std_logic;
  signal s_ref1 : std_logic;
  signal s_ref2 : std_logic;
  signal s_ref3 : std_logic;

  signal s_decision : STD_LOGIC;

  signal s_clk : std_logic;
  signal s_annodeList : std_logic_vector(3 downto 0);

  signal s_an0 : std_logic;
  signal s_an1 : std_logic;
  signal s_an2 : std_logic;
  signal s_an3 : std_logic;

  signal s_seg0: std_logic;
  signal s_seg1: std_logic;
  signal s_seg2: std_logic;
  signal s_seg3: std_logic;
  signal s_seg4: std_logic;
  signal s_seg5: std_logic;
  signal s_seg6: std_logic;

begin
  ------------instantiatine components within design-------------
  --component_pin => internal TOP signal,
  ElectionComponent : Election port map(
    ref0 => s_ref0,
    ref1 => s_ref1,
    ref2 => s_ref2,
    ref3 => s_ref3,
    decision => s_decision);

	ClockAndDigit : DigitSelector port map(
	  clk_in => s_clk,
    annodeList => s_annodeList);

  Driver : RefereeDisplayDriver port map(
    dataIn      => s_decision,
    activeAnode => s_annodeList,
    i_an0   => s_an0,
    i_an1   => s_an1,
    i_an2   => s_an2,
    i_an3   => s_an3,

    i_seg0  => s_seg0,
    i_seg1  => s_seg1,
    i_seg2  => s_seg2,
    i_seg3  => s_seg3,
    i_seg4  => s_seg4,
    i_seg5  => s_seg5,
    i_seg6  => s_seg6);
--------------internal to external routes--------------
  s_ref0 <= sw0;
  s_ref1 <= sw1;
  s_ref2 <= sw2;
  s_ref3 <= sw3;

  s_clk <= clk;

  an0   <=  s_an0; 
  an1   <=  s_an1;
  an2   <=  s_an2;
  an3   <=  s_an3;

  seg0  <=  s_seg0;
  seg1  <=  s_seg1;
  seg2  <=  s_seg2;
  seg3  <=  s_seg3;
  seg4  <=  s_seg4;
  seg5  <=  s_seg5;
  seg6  <=  s_seg6;
end TOP_ARCH;
