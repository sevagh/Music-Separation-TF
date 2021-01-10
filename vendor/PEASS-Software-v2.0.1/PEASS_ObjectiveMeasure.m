function res = PEASS_ObjectiveMeasure(...
    originalFiles,estimateFile,options)
% Main function
%
% Decomposition of an estimated source (or source image) into
%      the true target
%      + the target distortion (spatially-distorted and filtered version
%      of the target)
%      + the interference distortion component (spatially-distorted and
%      filtered version of other sources)
%      + the artifact and noise component
%
% Usage:
%
%   - res = PEASS_ObjectiveMeasure(...
%      originalFiles,estimateFile)
%
%   - res = PEASS_ObjectiveMeasure(...
%      originalFiles,estimateFile,options)
%
% Inputs:
%   originalFiles is a cell array with the file names related to the
%   true sources (the target source is the first one), estimateFile is a string.
%   Signals must be stored in .wav files.
%
% Output:
%   a structure with final and intermediate results, as follows
%    - final results:
%            - res.OPS: Overall Perceptual Score
%            - res.TPS: Target-related Perceptual Score
%            - res.IPS: Interference-related Perceptual Score
%            - res.APS: Artifact-related Perceptual Score
%    - intermediate results:
%            - res.decompositionFilenames: decomposition of the estimate
%            - res.ISR, res.SIR, res.SAR, res.SDR: ISR, SIR, SAR, SDR
%            computed from the estimated components
%            - res.qTarget, res.qInterf, res.qArtif, res.qGlobal:
%            audio quality features.
%
% See also: 
% extractDistortionComponents.m,
% ISR_SIR_SAR_fromNewDecomposition.m,
% audioQualityFeatures.m,
% map2SubjScale.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.0
% Copyright 2010 Valentin Emiya (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decompose the distortion into specific components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
res.decompositionFilenames = extractDistortionComponents(originalFiles,estimateFile,options);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute ISR, SIR, SAR, SDR from the estimated components (optional)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[res.ISR, res.SIR, res.SAR, res.SDR] = ...
    ISR_SIR_SAR_fromNewDecomposition(res.decompositionFilenames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute quality features using PEMO-Q
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[res.qTarget, res.qInterf, res.qArtif, res.qGlobal] = ...
    audioQualityFeatures(res.decompositionFilenames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Non-linear mapping to subjective scale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[res.OPS, res.TPS,res.IPS,res.APS] = ...
    map2SubjScale(res.qTarget, res.qInterf, res.qArtif, res.qGlobal);

return
