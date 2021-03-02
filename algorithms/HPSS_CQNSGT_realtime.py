import os
import numpy
import sys
import librosa
import scipy
import scipy.signal
import scipy.ndimage
import scipy.io.wavfile
from nsgt import NSGT_sliced, LogScale, LinScale, MelScale, OctScale, BarkScale
from nsgt.reblock import reblock
from argparse import ArgumentParser


def cputime():
    utime, stime, cutime, cstime, elapsed_time = os.times()
    return utime


def main():
    parser = ArgumentParser()

    parser.add_argument(
        "--mask",
        type=str,
        default="soft",
        choices=("hard", "soft"),
        help="mask strategy",
    )
    parser.add_argument("--outdir", type=str, default="./", help="output directory")
    parser.add_argument(
        "--stream-size",
        type=int,
        default=1024,
        help="stream size for simulated realtime from wav (default=%(default)s)",
    )
    parser.add_argument("input", type=str, help="input file")

    args = parser.parse_args()

    prefix = args.input.split("/")[-1].split("_")[0]

    harm_out = os.path.join(args.outdir, prefix + "_harmonic.wav")
    perc_out = os.path.join(args.outdir, prefix + "_percussive.wav")
    print("writing files to {0}, {1}".format(harm_out, perc_out))

    lharm = 17
    lperc = 7

    # calculate transform parameters
    nsgt_scale = OctScale(80, 20000, 12)

    trlen = args.stream_size  # transition length
    sllen = 4 * args.stream_size  # slice length

    x, fs = librosa.load(args.input, sr=None)
    xh = numpy.zeros_like(x)
    xp = numpy.zeros_like(x)

    hop = trlen
    chunk_size = hop
    n_chunks = int(numpy.floor(x.shape[0] // hop))

    eps = numpy.finfo(numpy.float32).eps

    slicq = NSGT_sliced(
        nsgt_scale,
        sllen,
        trlen,
        fs,
        real=True,
        matrixform=True,
    )
    total_time = 0.0

    for chunk in range(n_chunks - 1):
        t1 = cputime()

        start = chunk * hop
        end = start + sllen

        s = x[start:end]
        signal = (s,)

        c = slicq.forward(signal)

        c = list(c)
        C = numpy.asarray(c)

        Cmag = numpy.abs(C)
        H = scipy.ndimage.median_filter(Cmag, size=(1, lharm, 1))
        P = scipy.ndimage.median_filter(Cmag, size=(1, 1, lperc))

        if args.mask == "soft":
            # soft mask first
            tot = numpy.power(H, 2.0) + numpy.power(P, 2.0) + eps
            Mp = numpy.divide(numpy.power(H, 2.0), tot)
            Mh = numpy.divide(numpy.power(P, 2.0), tot)
        else:
            Mh = numpy.divide(H, P + eps) > 2.0
            Mp = numpy.divide(P, H + eps) >= 2.0

        Cp = numpy.multiply(Mp, C)
        Ch = numpy.multiply(Mh, C)

        # generator for backward transformation
        outseq_h = slicq.backward(Ch)
        outseq_p = slicq.backward(Cp)

        # make single output array from iterator
        sh_r = next(reblock(outseq_h, len(s), fulllast=False))
        sh_r = sh_r.real

        sp_r = next(reblock(outseq_p, len(s), fulllast=False))
        sp_r = sp_r.real

        xh[start:end] = sh_r
        xp[start:end] = sp_r

        t2 = cputime()
        total_time += t2 - t1

    print("Calculation time per iter: %fs" % (total_time / n_chunks))

    scipy.io.wavfile.write(harm_out, fs, xh)
    scipy.io.wavfile.write(perc_out, fs, xp)

    return 0


if __name__ == "__main__":
    sys.exit(main())
