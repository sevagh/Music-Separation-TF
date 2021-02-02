#!/usr/bin/env python3

import sys
import csv


if __name__ == '__main__':
    header = ['algo', 'H-OPS', 'H-TPS', 'H-IPS', 'H-APS', 'H-ISR', 'H-SIR', 'H-SAR', 'H-SDR', 'H-qTarget', 'H-qInterf', 'H-qArtif', 'H-qGlobal', 'P-OPS', 'P-TPS', 'P-IPS', 'P-APS', 'P-ISR', 'P-SIR', 'P-SAR', 'P-SDR', 'P-qTarget', 'P-qInterf', 'P-qArtif', 'P-qGlobal']

    try:
        curr_algo = None
        curr_algo_idx = -1
        prev_algo_idx = -1
        all_scores = [header]
        curr_scores = []
        with open(sys.argv[1], 'r') as f:
            for l in f:
                if ', median scores' in l:
                    curr_algo = l.split(',')[0]
                    prev_algo_idx = curr_algo_idx
                    curr_algo_idx += 1

                    # store previous scores
                    if len(curr_scores) > 0:
                        all_scores.append(curr_scores.copy())
                        curr_scores = []

                    curr_scores.append(curr_algo)
                    continue

                # we're in the same algorithm block
                if prev_algo_idx == curr_algo_idx-1:
                    if ':' in l:
                        curr_scores.append(float(l.split(':')[-1][:-1]))

            all_scores.append(curr_scores)

        with open("output.csv", "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerows(all_scores)
    except Exception as e:
        print(e)
        print('usage: {0} /path/to/saved/matlab/output'.format(sys.argv[0]), file=sys.stderr)
        sys.exit(1)
