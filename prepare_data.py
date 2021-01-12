#!/usr/bin/env python3

import sys
import argparse
import os
import numpy
import subprocess
from essentia.standard import MonoLoader
import soundfile


def parse_args():
    parser = argparse.ArgumentParser(
        prog="prepare_data",
        description="Prepare training datasets for HPSS from periphery instrument stems",
    )
    parser.add_argument(
        "--sample-rate",
        type=int,
        default=44100,
        help="sample rate (default: 44100 Hz)",
    )
    parser.add_argument(
        "dest_dir", type=str, default="./data", help="dest to place wav files"
    )
    parser.add_argument(
        "stem_dirs", nargs="+", help="directories containing periphery instrument stems"
    )
    parser.add_argument(
        "--vocals", action="store_true", help="include vocals in the mix"
    )
    parser.add_argument(
        "--track-limit", type=int, default=-1, help="limit to n tracks"
    )
    parser.add_argument(
        "--segment-limit", type=int, default=sys.maxsize, help="limit to n segments per track"
    )
    parser.add_argument(
        "--segment-size", type=float, default=30.0, help="segment size in seconds"
    )
    return parser.parse_args()


def main():
    args = parse_args()
    data_dir = os.path.abspath(args.dest_dir)

    seq = 0
    for sd in args.stem_dirs:
        for song in os.scandir(sd):
            for dir_name, _, file_list in os.walk(song):
                instruments = [
                    os.path.join(dir_name, f) for f in file_list if f.endswith(".wav")
                ]
                if instruments:
                    print("Found directory containing wav files: %d" % seq)
                    print(os.path.basename(dir_name).replace(" ", "_"))
                    loaded_wavs = [None] * len(instruments)
                    drum_track_index = -1
                    vocal_track_index = -1
                    for i, instrument in enumerate(instruments):
                        if "drum" in instrument.lower():
                            drum_track_index = i
                        elif "vocal" in instrument.lower():
                            vocal_track_index = i

                        # automatically resamples for us
                        loaded_wavs[i] = MonoLoader(
                            filename=instrument, sampleRate=args.sample_rate
                        )()

                    # ensure all stems have the same length
                    assert (
                        len(loaded_wavs[i]) == len(loaded_wavs[0])
                        for i in range(1, len(loaded_wavs))
                    )

                    # first create the full mix
                    if args.vocals:
                        harmonic_mix = sum([l for i, l in enumerate(loaded_wavs) if i != drum_track_index])
                    else:
                        harmonic_mix = sum([l for i, l in enumerate(loaded_wavs) if i not in [drum_track_index, vocal_track_index]])

                    full_mix = harmonic_mix + loaded_wavs[drum_track_index]

                    total_segs = int(numpy.floor(float(args.sample_rate)/args.segment_size))
                    seg_samples = int(numpy.floor(args.segment_size*args.sample_rate))

                    for seg in range(min(total_segs-1, args.segment_limit)):
                        seqstr = "%03d%03d" % (seq, seg)

                        left = seg*seg_samples
                        right = (seg+1)*seg_samples

                        harm_path = os.path.join(data_dir, "{0}_harmonic.wav".format(seqstr))
                        mix_path = os.path.join(data_dir, "{0}_mix.wav".format(seqstr))
                        perc_path = os.path.join(data_dir, "{0}_percussive.wav".format(seqstr))

                        soundfile.write(harm_path, harmonic_mix[left:right], args.sample_rate)
                        soundfile.write(mix_path, full_mix[left:right], args.sample_rate)

                        # write the drum track
                        soundfile.write(
                            perc_path,
                            loaded_wavs[drum_track_index][left:right],
                            args.sample_rate,
                        )

                    seq += 1

                    if args.track_limit > -1:
                        if seq == args.track_limit:
                            return 0

    return 0


if __name__ == "__main__":
    sys.exit(main())
