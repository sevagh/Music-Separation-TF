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
        results = json.loads(sys.argv[1])

        vocals_present = False
        if results.get('vocal_peass', None) is not None:
            vocals_present = True

        n_testcases = len(results)

        fig_peass = plt.figure()
        fig_peass.suptitle('PEASS')

        fig_bss = plt.figure()
        fig_bss.suptitle('BSS')

        fig_pemoq = plt.figure()
        fig_pemoq.suptitle('PEMO-Q')

        if vocals_present:
            ax_peass_harm = fig_peass.add_subplot(131)
            ax_peass_perc = fig_peass.add_subplot(132)

            ax_bss_harm = fig_bss.add_subplot(131)
            ax_bss_perc = fig_bss.add_subplot(132)

            ax_pemoq_harm = fig_pemoq.add_subplot(131)
            ax_pemoq_perc = fig_pemoq.add_subplot(132)
        else:
            ax_peass_harm = fig_peass.add_subplot(121)
            ax_peass_perc = fig_peass.add_subplot(122)

            ax_bss_harm = fig_bss.add_subplot(121)
            ax_bss_perc = fig_bss.add_subplot(122)

            ax_pemoq_harm = fig_pemoq.add_subplot(121)
            ax_pemoq_perc = fig_pemoq.add_subplot(122)

        ax_peass_harm.set_title('Harmonic PEASS scores')
        ax_peass_perc.set_title('Percussive PEASS scores')

        ax_bss_harm.set_title('Harmonic BSS scores')
        ax_bss_perc.set_title('Percussive BSS scores')

        ax_pemoq_harm.set_title('Harmonic PEMO-Q scores')
        ax_pemoq_perc.set_title('Percussive PEMO-Q scores')

        cmap = LinearSegmentedColormap.from_list(
            name='custom',
            colors=['red', 'orange', 'yellow', 'chartreuse', 'green'],
        )

        sns.heatmap(pd.DataFrame(results['harmonic_peass']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_peass_harm)
        sns.heatmap(pd.DataFrame(results['percussive_peass']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_peass_perc)

        sns.heatmap(pd.DataFrame(results['harmonic_bss']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_bss_harm)
        sns.heatmap(pd.DataFrame(results['percussive_bss']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_bss_perc)

        sns.heatmap(pd.DataFrame(results['harmonic_pemoq']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_pemoq_harm)
        sns.heatmap(pd.DataFrame(results['percussive_pemoq']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_pemoq_perc)

        # vocal eval
        if vocals_present:
            ax_peass_vocal = fig_peass.add_subplot(133)
            ax_bss_vocal = fig_bss.add_subplot(133)
            ax_pemoq_vocal = fig_pemoq.add_subplot(133)

            ax_peass_vocal.set_title('Vocal PEASS scores')
            ax_bss_vocal.set_title('Vocal BSS scores')
            ax_pemoq_vocal.set_title('Vocal PEMO-Q scores')

            sns.heatmap(pd.DataFrame(results['vocal_peass']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_peass_vocal)
            sns.heatmap(pd.DataFrame(results['vocal_bss']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_bss_vocal)
            sns.heatmap(pd.DataFrame(results['vocal_pemoq']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_pemoq_vocal)

        plt.show()
    except Exception as e:
        print(e)
        print('usage: {0} json-string'.format(sys.argv[0]), file=sys.stderr)
        sys.exit(1)
