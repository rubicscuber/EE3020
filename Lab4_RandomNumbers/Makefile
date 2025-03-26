GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) RandomNumbers.vhd
	@$(GHDL) -a $(FLAGS) RandCounter.vhd
	@$(GHDL) -a $(FLAGS) RandomNumbersTB.vhd
	@$(GHDL) -a $(FLAGS) BCD.vhd
	@$(GHDL) -a $(FLAGS) SevenSegmentDriver.vhd
	@$(GHDL) -a $(FLAGS) BarLedDriver.vhd
	@$(GHDL) -a $(FLAGS) RandomNumbers_Basys3.vhd
	@$(GHDL) -a $(FLAGS) RandomNumbers_Basys3TB.vhd

#	@$(GHDL) -e $(FLAGS) RandomNumbersTB
	@$(GHDL) -e $(FLAGS) RandomNumbers_Basys3TB

	@$(GHDL) -r $(FLAGS) RandomNumbers_Basys3TB --wave=RNGwave.ghw --stop-time=3us
#	@$(GHDL) -r $(FLAGS) RandomNumbersTB --wave=RNG_GENERATOR_Wave.ghw --stop-time=3us

