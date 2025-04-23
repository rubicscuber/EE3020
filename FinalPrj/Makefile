GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) LosePattern.vhd
	@$(GHDL) -a $(FLAGS) RandomNumbers.vhd
	@$(GHDL) -a $(FLAGS) RandCounter.vhd
	@$(GHDL) -a $(FLAGS) LedSegments.vhd
	@$(GHDL) -a $(FLAGS) BCD.vhd
	@$(GHDL) -a $(FLAGS) SevenSegmentDriver.vhd
	@$(GHDL) -a $(FLAGS) SyncChain.vhd
	@$(GHDL) -a $(FLAGS) LevelDetector.vhd
	@$(GHDL) -a $(FLAGS) Debouncer.vhd

	@$(GHDL) -a $(FLAGS) WinPattern.vhd
	@$(GHDL) -a $(FLAGS) PatternTB.vhd

	@$(GHDL) -a $(FLAGS) NumberChecker.vhd
	@$(GHDL) -a $(FLAGS) NumberCheckerTB.vhd

	@$(GHDL) -a $(FLAGS) MemoryGame.vhd
	@$(GHDL) -a $(FLAGS) MemoryGameTB.vhd

	@$(GHDL) -a $(FLAGS) MemoryGame_Basys3.vhd
	@$(GHDL) -a $(FLAGS) WrapperTB.vhd

#	@$(GHDL) -e $(FLAGS) NumberCheckerTB
#	@$(GHDL) -e $(FLAGS) PatternTB
	@$(GHDL) -e $(FLAGS) MemoryGameTB
#	@$(GHDL) -e $(FLAGS) WrapperTB

#	@$(GHDL) -r $(FLAGS) NumberCheckerTB --wave=NumberCheckerWAVE.ghw --stop-time=1us
#	@$(GHDL) -r $(FLAGS) PatternTB --wave=PatternWAVE.ghw --stop-time=1us
	@$(GHDL) -r $(FLAGS) MemoryGameTB --wave=DesignWAVE.ghw --stop-time=55us
#	@$(GHDL) -r $(FLAGS) WrapperTB --wave=WrapperWave.ghw --stop-time=15ms

