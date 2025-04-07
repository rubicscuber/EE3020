GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) Types_package.vhd
	@$(GHDL) -a $(FLAGS) NumberChecker.vhd
	@$(GHDL) -a $(FLAGS) NumberCheckerTB.vhd
	@$(GHDL) -a $(FLAGS) WinPattern.vhd
	@$(GHDL) -a $(FLAGS) PatternTB.vhd

	@$(GHDL) -e $(FLAGS) NumberCheckerTB
	@$(GHDL) -e $(FLAGS) PatternTB

#	@$(GHDL) -r $(FLAGS) NumberCheckerTB --wave=NumberCheckerWAVE.ghw --stop-time=1us
	@$(GHDL) -r $(FLAGS) PatternTB --wave=PatternWAVE.ghw --stop-time=1us

