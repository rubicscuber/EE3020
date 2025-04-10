GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) Types_package.vhd
	@$(GHDL) -a $(FLAGS) NumberChecker.vhd
	@$(GHDL) -a $(FLAGS) NumberCheckerTB.vhd
	@$(GHDL) -a $(FLAGS) WinPattern.vhd
	@$(GHDL) -a $(FLAGS) LosePattern.vhd
	@$(GHDL) -a $(FLAGS) RandomNumbers.vhd
	@$(GHDL) -a $(FLAGS) RandCounter.vhd
	@$(GHDL) -a $(FLAGS) BarLedDriver_Basys3.vhd
	@$(GHDL) -a $(FLAGS) BCD.vhd
	@$(GHDL) -a $(FLAGS) MemoryGame.vhd
	@$(GHDL) -a $(FLAGS) MemoryGameTB.vhd


	@$(GHDL) -e $(FLAGS) MemoryGameTB
#	@$(GHDL) -e $(FLAGS) NumberCheckerTB

#	@$(GHDL) -r $(FLAGS) NumberCheckerTB --wave=NumberCheckerWAVE.ghw --stop-time=1us
#	@$(GHDL) -r $(FLAGS) PatternTB --wave=PatternWAVE.ghw --stop-time=1us
	@$(GHDL) -r $(FLAGS) MemoryGameTB --wave=MAIN_WAVE.ghw --stop-time=10us

