#!/usr/bin/env python3

import sys
import json
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import seaborn as sns
import pandas as pd
import numpy as np

sns.set_theme()


if __name__ == '__main__':
    try:
        with open(sys.argv[1], 'r') as jf:
            results = json.load(jf)

            n_testcases = len(results)

            for k, v in results.items():
                print('{0}: {1}'.format(k, v))

            harm_fig_peass = plt.figure()
            harm_fig_peass.suptitle('Harmonic PEASS scores', fontsize=14)

            #harm_fig_bss = plt.figure()
            #harm_fig_bss.suptitle('Harmonic BSS scores', fontsize=14)

            #harm_fig_pemoq = plt.figure()
            #harm_fig_pemoq.suptitle('Harmonic PEMO-Q scores', fontsize=14)

            perc_fig_peass = plt.figure()
            perc_fig_peass.suptitle('Percussive PEASS scores', fontsize=14)

            #perc_fig_bss = plt.figure()
            #perc_fig_bss.suptitle('Percussive BSS scores', fontsize=14)

            #perc_fig_pemoq = plt.figure()
            #perc_fig_pemoq.suptitle('Percussive PEMO-Q scores', fontsize=14)

            # 3 measures: artifact, interference, target
            # 2 results: harmonic, percussive
            # 6 subplots total

            ax_harm_peass = harm_fig_peass.add_subplot(111)
            #ax_harm_bss = harm_fig_bss.add_subplot(111)
            #ax_harm_pemoq = harm_fig_pemoq.add_subplot(111)

            ax_perc_peass = perc_fig_peass.add_subplot(111)
            #ax_perc_bss = perc_fig_bss.add_subplot(111)
            #ax_perc_pemoq = perc_fig_pemoq.add_subplot(111)

            cmap = LinearSegmentedColormap.from_list(
                name='custom',
                colors=['red', 'orange', 'yellow', 'chartreuse', 'green'],
            )

            sns.heatmap(pd.DataFrame(results['harmonic_peass']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_harm_peass)
            #sns.heatmap(pd.DataFrame(results['harmonic_bss']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_harm_bss)
            #sns.heatmap(pd.DataFrame(results['harmonic_pemoq']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_harm_pemoq)

            sns.heatmap(pd.DataFrame(results['percussive_peass']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_perc_peass)
            #sns.heatmap(pd.DataFrame(results['percussive_bss']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_perc_bss)
            #sns.heatmap(pd.DataFrame(results['percussive_pemoq']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_perc_pemoq)

            plt.show()


    except Exception as e:
        print(e)
        print('usage: {0} /path/to/saved/matlab/output.json'.format(sys.argv[0]), file=sys.stderr)
        sys.exit(1)
