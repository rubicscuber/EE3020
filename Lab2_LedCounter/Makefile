GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) SevenSegment.vhd SevenSegmentTB.vhd
	@$(GHDL) -a $(FLAGS) BarLed.vhd BarLedTB.vhd
	@$(GHDL) -a $(FLAGS) SwitchLed_Basys3.vhd SwitchLed_Basys3TB.vhd

	@$(GHDL) -e $(FLAGS) SevenSegmentTB
	@$(GHDL) -e $(FLAGS) BarLedTB
	@$(GHDL) -e $(FLAGS) SwitchLed_Basys3TB

	@$(GHDL) -r $(FLAGS) SevenSegmentTB --wave=SevenSegmentWave.ghw --stop-time=1us
	@$(GHDL) -r $(FLAGS) BarLedTB --wave=BarLedWave.ghw --stop-time=1us
	@$(GHDL) -r $(FLAGS) SwitchLed_Basys3TB --wave=SwitchLedWrapperWave.ghw --stop-time=1us


