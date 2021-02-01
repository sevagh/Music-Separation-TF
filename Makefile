clean_data:
	-rm data-hpss/*.wav
	-rm data-vocal/*.wav

clean_results:
	-rm results-hpss/*/*.wav
	-rm results-vocal/*/*.wav

prep_data: clean_data
	./prepare_data.py --vocals --track-limit 2 ~/TRAINING-MUSIC/periphery-stems/Juggernaut_Omega/
	./prepare_data.py --track-limit 2 ~/TRAINING-MUSIC/periphery-stems/Juggernaut_Omega/

.PHONY: clean_data prep_data clean_results
