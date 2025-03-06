GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) RandomNumbers.vhd

	@$(GHDL) -e $(FLAGS) RandomNumbersTB

	@$(GHDL) -r $(FLAGS) RandomNumbersTB --wave=RandomNumbersWave.ghw --stop-time=1us

