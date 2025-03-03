GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) MovingLed.vhd MovingLedTB.vhd
	#@$(GHDL) -a $(FLAGS) MovingLedTB.vhd

	@$(GHDL) -a $(FLAGS) SevenSegmentDriver.vhd
	@$(GHDL) -a $(FLAGS) MovingLed_Basys3.vhd MovingLed_Basys3TB.vhd

	#@$(GHDL) -e $(FLAGS) MovingLedTB
	@$(GHDL) -e $(FLAGS) MovingLed_Basys3TB

	#@$(GHDL) -r $(FLAGS) MovingLedTB --wave=MovingLedWave.ghw --stop-time=40us
	@$(GHDL) -r $(FLAGS) MovingLed_Basys3TB --wave=MovingLed_Basys3Wave.ghw --stop-time=40us

