GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) SevenSegment.vhd SevenSegmentTB.vhd BarLed.vhd BarLedTB.vhd SwitchLed_Basys3.vhd
	@$(GHDL) -a $(FLAGS) SwitchLedTB.vhd

	@$(GHDL) -e $(FLAGS) SevenSegmentTB
	@$(GHDL) -e $(FLAGS) BarLedTB
	@$(GHDL) -e $(FLAGS) SwitchLedTB

	#@$(GHDL) -r $(FLAGS) SevenSegmentTB --wave=SevenSegmentWave.ghw --stop-time=1us
	#@$(GHDL) -r $(FLAGS) BarLedTB --wave=BarLedWave.ghw --stop-time=1us
	@$(GHDL) -r $(FLAGS) SwitchLedTB --wave=SwitchLedWrapperWave.ghw --stop-time=1us


