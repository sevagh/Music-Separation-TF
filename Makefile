clean_data:
	-rm data-hpss/*.wav
	-rm data-vocal/*.wav

clean_results:
	-rm results/id/*.wav
	-rm results/id-cqt/*.wav
	-rm results/id-wstft/*.wav

prep_data: clean_data
	./prepare_data.py --vocals --track-limit 1 --segment-limit 4 ~/TRAINING-MUSIC/periphery-stems/Juggernaut_Alpha/
	./prepare_data.py --track-limit 1 --segment-limit 4 ~/TRAINING-MUSIC/periphery-stems/Juggernaut_Alpha/

.PHONY: clean_data prep_data clean_results
