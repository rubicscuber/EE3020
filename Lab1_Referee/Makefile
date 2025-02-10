GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) Lab1_Referee.vhd Lab1_Referee_TB.vhd

	@$(GHDL) -e $(FLAGS) Lab1_Referee_TB
	
	@$(GHDL) -r $(FLAGS) Lab1_Referee_TB --wave=RefereeWaveForm.ghw --stop-time=1us
	
