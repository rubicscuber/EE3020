GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) MovingLed.vhd MovingLedTB.vhd

	@$(GHDL) -e $(FLAGS) MovingLedTB

	@$(GHDL) -r $(FLAGS) MovingLedTB --wave=MovingLedWave.ghw --stop-time=4us

