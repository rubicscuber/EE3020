GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) MovingLed.vhd MovingLedTB.vhd
	@$(GHDL) -a $(FLAGS) BarLedDriver.vhd BarLedDriverTB.vhd
	@$(GHDL) -a $(FLAGS) DigitSplitter.vhd DigitSplitterTB.vhd
	@$(GHDL) -a $(FLAGS) SevenSegmentDriver.vhd
	@$(GHDL) -a $(FLAGS) MovingLed_Basys3.vhd MovingLed_Basys3TB.vhd

	#@$(GHDL) -e $(FLAGS) MovingLedTB
	#@$(GHDL) -e $(FLAGS) BarLedDriverTB
	#@$(GHDL) -e $(FLAGS) DigitSplitterTB
	@$(GHDL) -e $(FLAGS) MovingLed_Basys3TB

	#@$(GHDL) -r $(FLAGS) MovingLedTB --wave=MovingLedWave.ghw --stop-time=4us
	#@$(GHDL) -r $(FLAGS) BarLedDriverTB --wave=BarLedDriverWave.ghw --stop-time=1us
	#@$(GHDL) -r $(FLAGS) DigitSplitterTB --wave=DigitSplitterWave.ghw --stop-time=1us
	@$(GHDL) -r $(FLAGS) MovingLed_Basys3TB --wave=MovingLed_Basys3Wave.ghw --stop-time=150us

