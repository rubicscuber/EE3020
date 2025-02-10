GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) BarrelShifter.vhd testbench.vhd  

	@$(GHDL) -e $(FLAGS) testbench

	@$(GHDL) -r $(FLAGS) testbench --wave=BarrelShifterWave.ghw --stop-time=5us

