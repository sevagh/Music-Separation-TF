#!/usr/bin/env python3

from bsseval import evaluate
import os
import sys
import json
import argparse
import numpy
from collections import defaultdict
from essentia.standard import MonoLoader

mypath = os.path.dirname(os.path.abspath(__file__))

hpss_results_dir = os.path.join(mypath, "results-hpss")
hpss_data_dir = os.path.join(mypath, "../data/data-hpss")

vocal_results_dir = os.path.join(mypath, "results-vocal")
vocal_data_dir = os.path.join(mypath, "../data/data-vocal")

bss_metric_names = ["SDR", "ISR", "SIR", "SAR"]


def parse_args():
    parser = argparse.ArgumentParser(
        prog="bss4_eval",
        description="Evaluate MATLAB results using BSS4 eval",
    )
    parser.add_argument(
        "--algorithms",
        type=str,
        default="",
        help="limit evaluation to these algorithms",
    )
    parser.add_argument(
        "--vocal", action="store_true", help="evaluate vocal instead of hpss"
    )
    parser.add_argument(
        "--seg-len-samples",
        type=int,
        default=661500,
        help="segment length in samples (default: 15s)",
    )
    return parser.parse_args()


def eval_hpss(
    harm_estimates, harm_references, perc_estimates, perc_references, n_segs, seg_len
):
    total = {}
    total["harmonic_bss"] = {}
    total["percussive_bss"] = {}

    for algo_name in perc_estimates.keys():
        print()
        print("\tEVALUATING ALGO {0}".format(algo_name))

        bss_results = numpy.zeros(dtype=numpy.float32, shape=(n_segs, 4, 2))

        n_seg = 0
        for track_prefix in perc_estimates[algo_name].keys():
            if n_seg >= n_segs:
                break
            cum_est_per_algo = numpy.zeros(dtype=numpy.float32, shape=(2, seg_len, 1))
            cum_ref_per_algo = numpy.zeros(dtype=numpy.float32, shape=(2, seg_len, 1))

            harm_ref = harm_references[track_prefix]
            harm_est = harm_estimates[algo_name][track_prefix]
            loaded_harm_ref = MonoLoader(filename=harm_ref)().reshape(seg_len, 1)
            loaded_harm_est = MonoLoader(filename=harm_est)().reshape(seg_len, 1)

            cum_est_per_algo[0] = loaded_harm_est
            cum_ref_per_algo[0] = loaded_harm_ref

            perc_ref = perc_references[track_prefix]
            perc_est = perc_estimates[algo_name][track_prefix]
            loaded_perc_ref = MonoLoader(filename=perc_ref)().reshape(seg_len, 1)
            loaded_perc_est = MonoLoader(filename=perc_est)().reshape(seg_len, 1)

            cum_est_per_algo[1] = loaded_perc_est
            cum_ref_per_algo[1] = loaded_perc_ref

            bss_metrics_segs = evaluate(cum_ref_per_algo, cum_est_per_algo)
            bss_metrics = numpy.nanmedian(bss_metrics_segs, axis=2)
            bss_results[n_seg][:] = numpy.asarray(bss_metrics)
            n_seg += 1

        total["harmonic_bss"][algo_name] = {}
        total["percussive_bss"][algo_name] = {}

        harm_bss = numpy.nanmedian(bss_results[:, :, 0], axis=0)

        for i, bss_metric_name in enumerate(bss_metric_names):
            total["harmonic_bss"][algo_name][bss_metric_name] = float(harm_bss[i])

        perc_bss = numpy.nanmedian(bss_results[:, :, 1], axis=0)

        for i, bss_metric_name in enumerate(bss_metric_names):
            total["percussive_bss"][algo_name][bss_metric_name] = float(perc_bss[i])

    return total


def eval_vocal(
    harm_estimates,
    harm_references,
    perc_estimates,
    perc_references,
    vocal_estimates,
    vocal_references,
    n_segs,
    seg_len,
):
    total = {}
    total["harmonic_bss"] = {}
    total["percussive_bss"] = {}
    total["vocal_bss"] = {}

    for algo_name in perc_estimates.keys():
        print()
        print("\tEVALUATING ALGO {0}".format(algo_name))

        bss_results = numpy.zeros(dtype=numpy.float32, shape=(n_segs, 4, 3))

        n_seg = 0
        for track_prefix in perc_estimates[algo_name].keys():
            if n_seg >= n_segs:
                break
            cum_est_per_algo = numpy.zeros(dtype=numpy.float32, shape=(3, seg_len, 1))
            cum_ref_per_algo = numpy.zeros(dtype=numpy.float32, shape=(3, seg_len, 1))

            harm_ref = harm_references[track_prefix]
            harm_est = harm_estimates[algo_name][track_prefix]
            loaded_harm_ref = MonoLoader(filename=harm_ref)().reshape(seg_len, 1)
            loaded_harm_est = MonoLoader(filename=harm_est)().reshape(seg_len, 1)

            cum_est_per_algo[0] = loaded_harm_est
            cum_ref_per_algo[0] = loaded_harm_ref

            perc_ref = perc_references[track_prefix]
            perc_est = perc_estimates[algo_name][track_prefix]
            loaded_perc_ref = MonoLoader(filename=perc_ref)().reshape(seg_len, 1)
            loaded_perc_est = MonoLoader(filename=perc_est)().reshape(seg_len, 1)

            cum_est_per_algo[1] = loaded_perc_est
            cum_ref_per_algo[1] = loaded_perc_ref

            novoc = False

            try:
                vocal_ref = vocal_references[track_prefix]
                vocal_est = vocal_estimates[algo_name][track_prefix]
                loaded_vocal_ref = MonoLoader(filename=vocal_ref)().reshape(seg_len, 1)
                loaded_vocal_est = MonoLoader(filename=vocal_est)().reshape(seg_len, 1)

                cum_est_per_algo[2] = loaded_vocal_est
                cum_ref_per_algo[2] = loaded_vocal_ref
            except:
                # an hpss algorithm with no vocal output
                novoc = True
                pass

            if novoc:
                # slice off vocal part
                cum_ref_per_algo = cum_ref_per_algo[:-1]
                cum_est_per_algo = cum_est_per_algo[:-1]

            bss_metrics_segs = evaluate(cum_ref_per_algo, cum_est_per_algo)
            bss_metrics = numpy.nanmedian(bss_metrics_segs, axis=2)

            if novoc:
                empties = numpy.empty(shape=(4, 1))
                empties[:] = numpy.nan
                adjusted_metrics = numpy.concatenate((bss_metrics, empties), axis=1)
                bss_results[n_seg][:] = numpy.asarray(adjusted_metrics)
            else:
                bss_results[n_seg][:] = numpy.asarray(bss_metrics)
            n_seg += 1

        total["harmonic_bss"][algo_name] = {}
        total["percussive_bss"][algo_name] = {}
        total["vocal_bss"][algo_name] = {}

        harm_bss = numpy.nanmedian(bss_results[:, :, 0], axis=0)

        for i, bss_metric_name in enumerate(bss_metric_names):
            total["harmonic_bss"][algo_name][bss_metric_name] = float(harm_bss[i])

        perc_bss = numpy.nanmedian(bss_results[:, :, 1], axis=0)

        for i, bss_metric_name in enumerate(bss_metric_names):
            total["percussive_bss"][algo_name][bss_metric_name] = float(perc_bss[i])

        vocal_bss = numpy.nanmedian(bss_results[:, :, 2], axis=0)

        for i, bss_metric_name in enumerate(bss_metric_names):
            total["vocal_bss"][algo_name][bss_metric_name] = float(vocal_bss[i])

    return total


if __name__ == "__main__":
    args = parse_args()

    seg_len = args.seg_len_samples

    if not args.vocal:
        perc_estimates = defaultdict(dict)
        perc_references = defaultdict(dict)

        harm_estimates = defaultdict(dict)
        harm_references = defaultdict(dict)

        for song in os.scandir(hpss_results_dir):
            for dir_name, _, file_list in os.walk(song):
                algo_name = dir_name.split("/")[-1]
                if args.algorithms:
                    if algo_name not in args.algorithms.split(","):
                        continue
                for sep_file in file_list:
                    track_prefix = sep_file.split("_")[0]
                    if "percussive" in sep_file:
                        perc_estimates[algo_name][track_prefix] = os.path.join(
                            dir_name, sep_file
                        )
                    elif "harmonic" in sep_file:
                        harm_estimates[algo_name][track_prefix] = os.path.join(
                            dir_name, sep_file
                        )

        for dir_name, _, file_list in os.walk(hpss_data_dir):
            for ref_file in file_list:
                track_prefix = ref_file.split("_")[0]
                if "percussive" in ref_file:
                    perc_references[track_prefix] = os.path.join(dir_name, ref_file)
                elif "harmonic" in ref_file:
                    harm_references[track_prefix] = os.path.join(dir_name, ref_file)

        # percussive first
        n_segs = len(perc_references)

        bss_json = eval_hpss(
            harm_estimates,
            harm_references,
            perc_estimates,
            perc_references,
            n_segs,
            seg_len,
        )
        print(json.dumps(bss_json))

    # VOCAL case
    else:
        perc_estimates = defaultdict(dict)
        perc_references = defaultdict(dict)

        harm_estimates = defaultdict(dict)
        harm_references = defaultdict(dict)

        vocal_estimates = defaultdict(dict)
        vocal_references = defaultdict(dict)

        for song in os.scandir(vocal_results_dir):
            for dir_name, _, file_list in os.walk(song):
                algo_name = dir_name.split("/")[-1]
                if args.algorithms:
                    if algo_name not in args.algorithms.split(","):
                        continue
                for sep_file in file_list:
                    track_prefix = sep_file.split("_")[0]
                    if "percussive" in sep_file:
                        perc_estimates[algo_name][track_prefix] = os.path.join(
                            dir_name, sep_file
                        )
                    elif "harmonic" in sep_file:
                        harm_estimates[algo_name][track_prefix] = os.path.join(
                            dir_name, sep_file
                        )
                    elif "vocal" in sep_file:
                        vocal_estimates[algo_name][track_prefix] = os.path.join(
                            dir_name, sep_file
                        )

        for dir_name, _, file_list in os.walk(vocal_data_dir):
            for ref_file in file_list:
                track_prefix = ref_file.split("_")[0]
                if "percussive" in ref_file:
                    perc_references[track_prefix] = os.path.join(dir_name, ref_file)
                elif "harmonic" in ref_file:
                    harm_references[track_prefix] = os.path.join(dir_name, ref_file)
                elif "vocal" in ref_file:
                    vocal_references[track_prefix] = os.path.join(dir_name, ref_file)

        # percussive first
        n_segs = len(perc_references)

        bss_json = eval_vocal(
            harm_estimates,
            harm_references,
            perc_estimates,
            perc_references,
            vocal_estimates,
            vocal_references,
            n_segs,
            seg_len,
        )
        print(json.dumps(bss_json))
