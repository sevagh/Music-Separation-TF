PEASS software
Version 2.0, October 2011.
By Valentin Emiya and Emmanuel Vincent, INRIA, France.
This is joint work by Valentin Emiya (INRIA, France), Emmanuel Vincent (INRIA, France), Niklas Harlander (University of Oldenburg, Germany), Volker Hohmann (University of Oldenburg, Germany).
Reduction of the computation time of the decomposition step proposed by Audionamix within the i3DMusic project (http://i3dmusic.audionamix.com).


*********
What for?
*********
The PEASS Software provides a set of perceptually motivated objective measures
for the evaluation of audio source separation.

Similarly to BSS Eval, the distortion signal is decomposed into three
components: target distortion, interference, artifacts. These components are
then used to compute four quality scores, namely OPS (Overall Perceptual
Score), TPS (Target-related Perceptual Score), IPS (Interference-related
Perceptual Score), APS (Artifact-related Perceptual Score). These scores
better correlate with human assessments than the SDR/ISR/SIR/SAR measures of
BSS Eval.

*****************
In which context?
*****************
This method can be applied either to the source signals or to their spatial images, whatever the number of channels.

***********************
Installing the software
***********************
- Unzip the file into a new directory.

- Download the third-party haircell modeling software from
http://medi.uni-oldenburg.de/download/demo/adaption-loops/adapt_loop.zip
and unzip it in the above directory.

** Please pay attention to the specific user license agreement governing this
third-party software **

- Compile the MEX files by running compile.m under Matlab (this is optional but leads to much faster computation).

******************
Computing quality scores
******************
The main function is PEASS_ObjectiveMeasure.m. For an example of use, see example.m. The distortion components are stored as .wav files in the "example" directory.

*********
Platforms
*********
The code can be used on any platform where Matlab is installed.

*********************
Technical limitations
*********************
Please report any bug or comment to emmanuel.vincent@inria.fr and valentin.emiya@lif.univ-mrs.fr.
So far, some technical limitations have been noticed solved (but maybe not optimally yet):
- out of memory/large sound materials: when sounds are long, sampling frequency is high and/or sources are numerous, an "out of memory" issue may be raised. In this case, increase the "option.segmentationFactor" integer value to have the sounds segmented first, then decomposed and finally merged along the full time scale. This is due to the gammatone implementation and the current solution may be improved in the future.

**************************
How to cite this software?
**************************
When using this software, the following papers must be referred to:

Valentin Emiya, Emmanuel Vincent, Niklas Harlander and Volker Hohmann, Subjective and objective quality assessment of audio source separation, IEEE Transactions on Audio, Speech and Language Processing, 19(7):2046-2057, 2011.

Emmanuel Vincent, Improved perceptual metrics for the evaluation of audio source separation, 10th Int. Conf. on Latent Variable Analysis and Signal Separation (LVA/ICA 2012), submitted.

**********
References
**********
The toolbox uses an implementation of the gammatone filterbank freely available at http://www.uni-oldenburg.de/medi/download/demo/gammatone-filterbank/gammatone_filterbank-1.1.zip and related to `Frequency analysis and synthesis using a Gammatone filterbank' by V. Hohmann, Acustica/Acta Acustica, 88(3):433-442, 2002, and `Improved numerical methods for gammatone filterbank analysis and synthesis' by T. Herzke and V. Hohmann, Acustica/Acta Acustica, 93(3):498-500, 2007.
The toolbox uses the haircell model and the PEMO-Q metrics described in
`Modeling auditory processing of amplitude modulation: I. Modulation Detection and masking with narrowband carriers' by T. Dau, B. Kollmeier and A. Kohlrausch, J. Acoust. Soc. Am., 102(5):2892-2905, 1997, and `PEMO-Q -- A New Method for Objective Audio Quality Assessment Using a Model of Auditory Perception' by R. Huber and B. Kollmeier, IEEE Trans. on Audio, Speech, and Language Processing, 14(6):1902-1911, 2006.

*********
Copyright
*********
The files in root directory are under:
Copyright 2010-2011 Valentin Emiya and Emmanuel Vincent (INRIA).

The code in the current directory is distributed under the terms of the GNU Public License version 3 (http://www.gnu.org/licenses/gpl.txt).

The files in the directory named "gammatone" are under Copyright (C) 2002 2003 2006 2007 AG Medizinische Physik, Universitaet Oldenburg, Germany, http://www.physik.uni-oldenburg.de/docs/medi. See file "gammatone/README.txt".

********
Versions
********
Version 2.0, October 2011:
- changed some parameters of the decomposition and of PEMO-Q
- changed the training procedure
Version 1.1, September 2011:
- replaced the PEMO-Q software by a Matlab/MEX implementation
  (audioQualityFeatures.m).
- forced the subjective scores to 100 for hidden references in the training
  stage
Version 1.0.1, September 2011:
 - added an error message if signal sizes are not correct (extractDistortionComponents.m).
 - improved the processing of multichannel signals (audioQualityFeatures.m).
Version 1.0, May 12th, 2010: first release.
