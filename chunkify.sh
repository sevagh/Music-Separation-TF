#!/usr/bin/env bash

for f in data/*.wav;
do ffmpeg -i $f -f segment -segment_time 20 -c copy data_chunked/%09d$(basename $f)
done
