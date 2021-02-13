current_dir:=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

all: help

help:
	@printf "targets:\n"
	@printf "\tclean\n"
	@printf "\tvocal-data-clean\n"
	@printf "\tvocal-results-clean\n"
	@printf "\tvocal-clean\n"
	@printf "\tvocal-small-data\n"
	@printf "\tvocal-big-data\n"
	@printf "\thpss-data-clean\n"
	@printf "\thpss-results-clean\n"
	@printf "\thpss-clean\n"
	@printf "\thpss-small-data\n"
	@printf "\thpss-big-data\n"

clean: vocal-clean
clean: hpss-clean

fmt:
	black data/prepare_data.py algorithms/umx.py evaluation/heatmap.py

vocal-clean: vocal-data-clean
vocal-clean: vocal-results-clean

hpss-clean: hpss-data-clean
hpss-clean: hpss-results-clean

vocal-data-clean:
	-rm -rf $(current_dir)/data/data-vocal

hpss-data-clean:
	-rm -rf $(current_dir)/data/data-hpss

vocal-results-clean:
	-rm -rf $(current_dir)/evaluation/results-vocal

hpss-results-clean:
	-rm -rf $(current_dir)/evaluation/results-hpss

vocal-small-data-periphery:
	$(current_dir)/data/prepare_data.py --vocals --track-limit 2 --segment-limit 12 --segment-offset 8 --segment-size 10 ~/TRAINING-MUSIC/periphery-stems/Juggernaut_Alpha/

hpss-small-data-periphery:
	$(current_dir)/data/prepare_data.py --track-limit 2 --segment-limit 8 --segment-offset 4 --segment-size 10 ~/TRAINING-MUSIC/periphery-stems/Juggernaut_Alpha/

vocal-big-data-periphery:
	$(current_dir)/data/prepare_data.py --vocals --track-limit 20 --segment-limit 9 --segment-offset 3 --segment-size 30 ~/TRAINING-MUSIC/periphery-stems/*

hpss-big-data-periphery:
	$(current_dir)/data/prepare_data.py --track-limit 20 --segment-limit 9 --segment-offset 3 --segment-size 30 ~/TRAINING-MUSIC/periphery-stems/*

vocal-musdb-small:
	$(current_dir)/data/prepare_data.py --vocals --track-limit 5 --segment-limit 5 --segment-offset 3 --segment-size 15 ~/TRAINING-MUSIC/MUSDB18-HQ/test/

vocal-musdb-big:
	$(current_dir)/data/prepare_data.py --vocals --track-limit 20 --segment-limit 12 --segment-offset 2 --segment-size 15 ~/TRAINING-MUSIC/MUSDB18-HQ/test/

.PHONY:
	vocal-clean vocal-data-clean vocal-results-clean hpss-clean hpss-data-clean hpss-results-clean hpss-small-data vocal-small-data hpss-big-data vocal-big-data
