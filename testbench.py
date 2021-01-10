#!/usr/bin/env python3

import sys
import argparse
import os
import numpy
import subprocess
from collections import defaultdict
from essentia.standard import MonoLoader
import soundfile
import tempfile
import torch

# disable GPU to avoid torch oom in cdpam
os.environ["CUDA_VISIBLE_DEVICES"] = " "
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
    return parser.parse_args()


def main():
    args = parse_args()
    data_dir = os.path.abspath(args.data_dir)
    sep_dir = os.path.abspath(args.separated_dir)

    testcases = defaultdict(list)
    separations = defaultdict(list)

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

    # as per https://github.com/pranaymanocha/PerceptualAudio/issues/18#issuecomment-757365731
    loss_fn = cdpam.CDPAM()

    results = {k: defaultdict(dict) for k in testcases.keys()}

    for k in testcases.keys():
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

        # cdpam metric
        harm_ref = cdpam.load_audio(harmonic_orig)
        harm_test = cdpam.load_audio(harmonic_sep)

        perc_ref = cdpam.load_audio(percussive_orig)
        perc_test = cdpam.load_audio(percussive_sep)

        with torch.no_grad():
            harm_dist = loss_fn.forward(harm_ref, harm_test)
            perc_dist = loss_fn.forward(perc_ref, perc_test)

        results[k][result_type]['cdpam'] = {
            'harmonic': harm_dist,
            'percussive': perc_dist,
        }

        # use subprocess for visqol
        # write tmp files for resampling
        with tempfile.TemporaryDirectory() as tmpdir:
            pref = os.path.join(tmpdir, "perc_ref.wav")
            ptest = os.path.join(tmpdir, "perc_test.wav")

            soundfile.write(
                pref,
                perc_ref,
                FIXED_SAMPLE_RATE,
            )
            soundfile.write(
                ptest,
                perc_test,
                FIXED_SAMPLE_RATE,
            )

            visqol_out_perc = subprocess.check_output(
                'visqol --reference_file {0} --degraded_file {1}'.format(
                    pref, ptest, shell=True)
            )
            print(visqol_out_perc)

            href = os.path.join(tmpdir, "harm_ref.wav")
            htest = os.path.join(tmpdir, "harm_test.wav")

            soundfile.write(
                href,
                harm_ref,
                FIXED_SAMPLE_RATE,
            )
            soundfile.write(
                htest,
                harm_test,
                FIXED_SAMPLE_RATE,
            )

            visqol_out_harm = subprocess.check_output(
                'visqol --reference_file {0} --degraded_file {1}'.format(href, htest, shell=True)
            )
            print(visqol_out_harm)


    print(results)

    return 0


if __name__ == "__main__":
    sys.exit(main())
