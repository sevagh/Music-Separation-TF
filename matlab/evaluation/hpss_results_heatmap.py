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

        n_testcases = len(results)

        harm_fig_peass = plt.figure()
        perc_fig_peass = plt.figure()

        ax_harm_peass = harm_fig_peass.add_subplot(111)
        ax_perc_peass = perc_fig_peass.add_subplot(111)

        ax_harm_peass.set_title('Harmonic PEASS scores')
        ax_perc_peass.set_title('Percussive PEASS scores')

        cmap = LinearSegmentedColormap.from_list(
            name='custom',
            colors=['red', 'orange', 'yellow', 'chartreuse', 'green'],
        )

        sns.heatmap(pd.DataFrame(results['harmonic_peass']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_harm_peass)
        sns.heatmap(pd.DataFrame(results['percussive_peass']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_perc_peass)

        # vocal eval
        if results.get('vocal_peass', None) is not None:
            vocal_fig_peass = plt.figure()
            ax_vocal_peass = vocal_fig_peass.add_subplot(111)

            ax_vocal_peass.set_title('Vocal PEASS scores')

            sns.heatmap(pd.DataFrame(results['vocal_peass']).transpose(), annot=True, cbar=False, cmap=cmap, fmt=".2f", ax=ax_vocal_peass)


        plt.show()
    except Exception as e:
        print(e)
        print('usage: {0} json-string'.format(sys.argv[0]), file=sys.stderr)
        sys.exit(1)
