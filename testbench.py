#!/usr/bin/env python3

import sys
import argparse
import os
import numpy
import subprocess
from collections import defaultdict
from vendor.peaq import PEAQ
from essentia.standard import MonoLoader
import soundfile
import cdpam

# this needs to be fixed to 48000 for visqol
FIXED_SAMPLE_RATE = 48000


def parse_args():
    parser = argparse.ArgumentParser(
        prog="testbench",
        description="Evaluate different HPSS variants",
    )
    parser.add_argument(
        "data_dir", type=str, default="./data", help="directory containing original data files"
    )
    parser.add_argument(
        "separated_dir", type=str, default="./separated", help="directory containing separated files"
    )
    parser.add_argument(
        "visqol_path", type=str, help="path to visqol binary (https://github.com/google/visqol)"
    )
    return parser.parse_args()


def main():
    args = parse_args()
    data_dir = os.path.abspath(args.data_dir)
    sep_dir = os.path.abspath(args.separated_dir)

    testcases = defaultdict(list)
    separations = defaultdict(list)
    results = defaultdict(dict)

    for dirname, _, wav_files in os.walk(data_dir):
        wav_files = [f for f in wav_files if f.endswith('.wav')]
        for w in wav_files:
            prefix = w.split('_')[0]
            testcases[prefix].append(w)

    for dirname, _, wav_files in os.walk(sep_dir):
        wav_files = [f for f in wav_files if f.endswith('.wav')]
        for w in wav_files:
            for k in testcases.keys():
                if k in w:
                    separations[k].append(w)

    peaq = PEAQ(Fs=FIXED_SAMPLE_RATE)

    # try batch_size=1
    # as per https://github.com/pranaymanocha/PerceptualAudio/issues/18#issuecomment-757365731
    loss_fn = cdpam.CDPAM(batch_size=1)

    for k in testcases:
        harmonic_orig = os.path.join(data_dir, [f for f in testcases[k] if 'harmonic' in f][0])
        percussive_orig = os.path.join(data_dir, [f for f in testcases[k] if 'percussive' in f][0])

        harmonic_sep = [f for f in separations[k] if 'harm_sep' in f][0]

        result_type = harmonic_sep.split('_')[0]

        harmonic_sep = os.path.join(sep_dir, harmonic_sep)
        percussive_sep = os.path.join(sep_dir, [f for f in separations[k] if 'perc_sep' in f][0])

        harm_ref = MonoLoader(
            filename=harmonic_orig, sampleRate=FIXED_SAMPLE_RATE
        )()

        harm_test = MonoLoader(
            filename=harmonic_sep, sampleRate=FIXED_SAMPLE_RATE
        )()

        perc_ref = MonoLoader(
            filename=percussive_orig, sampleRate=FIXED_SAMPLE_RATE
        )()

        perc_test = MonoLoader(
            filename=percussive_sep, sampleRate=FIXED_SAMPLE_RATE
        )()

        # PEAQ metric
        peaq.process(harm_ref, harm_test)
        peaq.process(perc_ref, perc_test)

        results[result_type][k]['peaq'] = {
            'harmonic': 0.0,
            'percussive': 0.0,
        }

        # cdpam metric
        harm_ref = cdpam.load_audio(harmonic_orig)
        harm_out = cdpam.load_audio(harmonic_sep)
        harm_dist = loss_fn.forward(harm_ref, harm_out)

        perc_ref = cdpam.load_audio(percussive_orig)
        perc_out = cdpam.load_audio(percussive_sep)
        perc_dist = loss_fn.forward(perc_ref, perc_out)

        results[result_type][k]['cdpam'] {
            'harmonic': harm_dist,
            'percussive': perc_dist,
        }

        # use subprocess for visqol

    print(results)

    return 0


if __name__ == "__main__":
    sys.exit(main())
