current_dir:=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

all: help

help:
	@printf "targets:\n"
	@printf "\tclean\n"
	@printf "\tvocal-data-clean\n"
	@printf "\tvocal-results-clean\n"
	@printf "\tvocal-clean\n"
	@printf "\thpss-data-clean\n"
	@printf "\thpss-results-clean\n"
	@printf "\thpss-clean\n"
	@printf "\tvocal-musdb-short\n"
	@printf "\tvocal-musdb-long\n"
	@printf "\thpss-musdb-short\n"
	@printf "\thpss-musdb-long\n"

clean: vocal-clean
clean: hpss-clean

fmt:
	black data/*.py algorithms/*.py evaluation/*.py

lint:
	pyflakes data/*.py algorithms/*.py evaluation/*.py

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

hpss-musdb: # 5 min of songs
	$(current_dir)/data/prepare_data.py --track-limit 5 --segment-limit 6 --segment-offset 2 --segment-size 15 ~/TRAINING-MUSIC/MUSDB18-HQ/test/

vocal-musdb: # 5 min of songs
	$(current_dir)/data/prepare_data.py --vocals --track-limit 5 --segment-limit 6 --segment-offset 2 --segment-size 15 ~/TRAINING-MUSIC/MUSDB18-HQ/test/

.PHONY:
	vocal-clean vocal-data-clean vocal-results-clean hpss-clean hpss-data-clean hpss-results-clean clean hpss-musdb-short hpss-musdb vocal-musdb
