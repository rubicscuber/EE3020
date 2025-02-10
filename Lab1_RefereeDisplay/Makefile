GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) testbench.vhd TOP.vhd Election.vhd RefereeDisplayDriver.vhd DigitSelector.vhd

	@$(GHDL) -e $(FLAGS) testbench

	@$(GHDL) -r $(FLAGS) testbench --wave=TOPwave.ghw --stop-time=66ms

