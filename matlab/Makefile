current_dir:=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

all: help

help:
	@printf "targets:\n"
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

vocal-clean: vocal-data-clean
vocal-clean: vocal-results-clean

hpss-clean: hpss-data-clean
hpss-clean: hpss-results-clean

vocal-data-clean:
	-rm $(current_dir)/data/data-vocal/*.wav

hpss-data-clean:
	-rm $(current_dir)/data/data-hpss/*.wav

vocal-results-clean:
	-rm $(current_dir)/evaluation/results-vocal/*.wav

hpss-results-clean:
	-rm $(current_dir)/evaluation/results-hpss/*.wav

vocal-small-data:
	$(current_dir)/data/prepare_data.py --vocals --track-limit 2 --segment-limit 12 --segment-offset 8 --segment-size 10 ~/TRAINING-MUSIC/periphery-stems/Juggernaut_Alpha/

hpss-small-data:
	$(current_dir)/data/prepare_data.py --track-limit 2 --segment-limit 8 --segment-offset 4 --segment-size 10 ~/TRAINING-MUSIC/periphery-stems/Juggernaut_Alpha/

vocal-big-data:
	$(current_dir)/data/prepare_data.py --vocals --track-limit 20 --segment-limit 9 --segment-offset 3 --segment-size 30 ~/TRAINING-MUSIC/periphery-stems/*

hpss-big-data:
	$(current_dir)/data/prepare_data.py --track-limit 20 --segment-limit 9 --segment-offset 3 --segment-size 30 ~/TRAINING-MUSIC/periphery-stems/*

.PHONY:
	vocal-clean vocal-data-clean vocal-results-clean hpss-clean hpss-data-clean hpss-results-clean hpss-small-data vocal-small-data hpss-big-data vocal-big-data
