#!/usr/bin/env bash

for f in data/*.wav;
do ffmpeg -i $f -f segment -segment_time 30 -c copy data_chunked/%02d$(basename $f)
done
