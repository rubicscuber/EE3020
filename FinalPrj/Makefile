GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) Types_package.vhd
	@$(GHDL) -a $(FLAGS) NumberChecker.vhd
	@$(GHDL) -a $(FLAGS) NumberCheckerTB.vhd

	@$(GHDL) -e $(FLAGS) NumberCheckerTB

	@$(GHDL) -r $(FLAGS) NumberCheckerTB --wave=NumberCheckerWAVE.ghw --stop-time=1us

