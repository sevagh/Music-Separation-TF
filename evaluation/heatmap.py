#!/usr/bin/env python3

import sys
import json
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import seaborn as sns
import pandas as pd
import numpy as np
import argparse
from collections.abc import MutableMapping

sns.set_theme()


def delete_keys_from_dict(dictionary, keys):
    keys_set = set(keys)  # Just an optimization for the "if key in keys" lookup.

    modified_dict = {}
    for key, value in dictionary.items():
        if key not in keys_set:
            if isinstance(value, MutableMapping):
                modified_dict[key] = delete_keys_from_dict(value, keys_set)
            else:
                modified_dict[
                    key
                ] = value  # or copy.deepcopy(value) if a copy is desired for non-dicts.
    return modified_dict


if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser(
            prog="heatmap.py",
            description="generate heatmaps from MATLAB source sep eval json",
            formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        )

        parser.add_argument(
            "--disable-global-metrics",
            action="store_true",
            help="Disable global (OPS, qGlobal, SDR) metrics",
        )

        parser.add_argument(
            "--disable-pemoq",
            action="store_true",
            help="Disable PEMO-Q metrics",
        )

        parser.add_argument(
            "--disable-bss",
            action="store_true",
            help="Disable BSS metrics",
        )

        parser.add_argument(
            "--disable-peass",
            action="store_true",
            help="Disable PEASS metrics",
        )

        parser.add_argument(
            "--separate-figures",
            action="store_true",
            help="Generate separate figures per component (default = all components side-by-side with subplots)",
        )

        parser.add_argument(
            "matlab_json_in", help="input json string (MATLAB eval output)"
        )

        args = parser.parse_args()

        results = json.loads(args.matlab_json_in)

        if args.disable_global_metrics:
            results = delete_keys_from_dict(results, ["OPS", "qGlobal", "SDR"])

        vocals_present = False
        n_subplot = 2
        if results.get("vocal_peass", None) is not None:
            vocals_present = True
            n_subplot = 3

        n_testcases = len(results)

        cmap = LinearSegmentedColormap.from_list(
            name="custom",
            colors=["red", "orange", "yellow", "chartreuse", "green"],
        )

        if not args.disable_peass:
            if not args.separate_figures:
                fig_peass = plt.figure()
                fig_peass.suptitle("PEASS")
                ax_peass_harm = fig_peass.add_subplot(1, n_subplot, 1)
                ax_peass_perc = fig_peass.add_subplot(1, n_subplot, 2)
                if vocals_present:
                    ax_peass_vocal = fig_peass.add_subplot(1, n_subplot, 3)
            else:
                fig_peass_harm = plt.figure()
                fig_peass_harm.suptitle("PEASS")
                fig_peass_perc = plt.figure()
                fig_peass_perc.suptitle("PEASS")
                ax_peass_harm = fig_peass_harm.add_subplot(111)
                ax_peass_perc = fig_peass_perc.add_subplot(111)
                if vocals_present:
                    fig_peass_vocal = plt.figure()
                    fig_peass_vocal.suptitle("PEASS")
                    ax_peass_vocal = fig_peass_vocal.add_subplot(111)

            ax_peass_harm.set_title("Harmonic")
            ax_peass_perc.set_title("Percussive")
            sns.heatmap(
                pd.DataFrame(results["harmonic_peass"]).transpose(),
                annot=True,
                cbar=False,
                cmap=cmap,
                fmt=".2f",
                ax=ax_peass_harm,
            )
            sns.heatmap(
                pd.DataFrame(results["percussive_peass"]).transpose(),
                annot=True,
                cbar=False,
                cmap=cmap,
                fmt=".2f",
                ax=ax_peass_perc,
            )
            if vocals_present:
                ax_peass_vocal.set_title("Vocal")
                sns.heatmap(
                    pd.DataFrame(results["vocal_peass"])
                    .transpose()
                    .fillna(value=np.nan),
                    annot=True,
                    cbar=False,
                    cmap=cmap,
                    fmt=".2f",
                    ax=ax_peass_vocal,
                )

        if not args.disable_bss:
            if not args.separate_figures:
                fig_bss = plt.figure()
                fig_bss.suptitle("BSS")
                ax_bss_harm = fig_bss.add_subplot(1, n_subplot, 1)
                ax_bss_perc = fig_bss.add_subplot(1, n_subplot, 2)
                if vocals_present:
                    ax_bss_vocal = fig_bss.add_subplot(1, n_subplot, 3)
            else:
                fig_bss_harm = plt.figure()
                fig_bss_harm.suptitle("BSS")
                fig_bss_perc = plt.figure()
                fig_bss_perc.suptitle("BSS")
                ax_bss_harm = fig_bss_harm.add_subplot(111)
                ax_bss_perc = fig_bss_perc.add_subplot(111)
                if vocals_present:
                    fig_bss_vocal = plt.figure()
                    fig_bss_vocal.suptitle("BSS")
                    ax_bss_vocal = fig_bss_vocal.add_subplot(111)

            ax_bss_harm.set_title("Harmonic")
            ax_bss_perc.set_title("Percussive")
            sns.heatmap(
                pd.DataFrame(results["harmonic_bss"]).transpose(),
                annot=True,
                cbar=False,
                cmap=cmap,
                fmt=".2f",
                ax=ax_bss_harm,
            )
            sns.heatmap(
                pd.DataFrame(results["percussive_bss"]).transpose(),
                annot=True,
                cbar=False,
                cmap=cmap,
                fmt=".2f",
                ax=ax_bss_perc,
            )
            if vocals_present:
                ax_bss_vocal.set_title("Vocal")
                sns.heatmap(
                    pd.DataFrame(results["vocal_bss"]).transpose().fillna(value=np.nan),
                    annot=True,
                    cbar=False,
                    cmap=cmap,
                    fmt=".2f",
                    ax=ax_bss_vocal,
                )

        if not args.disable_pemoq:
            if not args.separate_figures:
                fig_pemoq = plt.figure()
                fig_pemoq.suptitle("PEMO-Q")
                ax_pemoq_harm = fig_pemoq.add_subplot(1, n_subplot, 1)
                ax_pemoq_perc = fig_pemoq.add_subplot(1, n_subplot, 2)
                if vocals_present:
                    ax_pemoq_vocal = fig_pemoq.add_subplot(1, n_subplot, 3)
            else:
                fig_pemoq_harm = plt.figure()
                fig_pemoq_harm.suptitle("PEMO-Q")
                fig_pemoq_perc = plt.figure()
                fig_pemoq_perc.suptitle("PEMO-Q")
                ax_pemoq_harm = fig_pemoq_harm.add_subplot(111)
                ax_pemoq_perc = fig_pemoq_perc.add_subplot(111)
                if vocals_present:
                    fig_pemoq_vocal = plt.figure()
                    fig_pemoq_vocal.suptitle("BSS")
                    ax_pemoq_vocal = fig_pemoq_vocal.add_subplot(111)

            ax_pemoq_harm.set_title("Harmonic")
            ax_pemoq_perc.set_title("Percussive")
            sns.heatmap(
                pd.DataFrame(results["harmonic_pemoq"]).transpose(),
                annot=True,
                cbar=False,
                cmap=cmap,
                fmt=".2f",
                ax=ax_pemoq_harm,
            )
            sns.heatmap(
                pd.DataFrame(results["percussive_pemoq"]).transpose(),
                annot=True,
                cbar=False,
                cmap=cmap,
                fmt=".2f",
                ax=ax_pemoq_perc,
            )
            if vocals_present:
                ax_pemoq_vocal.set_title("Vocal")
                sns.heatmap(
                    pd.DataFrame(results["vocal_pemoq"])
                    .transpose()
                    .fillna(value=np.nan),
                    annot=True,
                    cbar=False,
                    cmap=cmap,
                    fmt=".2f",
                    ax=ax_pemoq_vocal,
                )

        plt.show()
    except Exception as e:
        print("exception: {0}".format(e))
        sys.exit(1)
