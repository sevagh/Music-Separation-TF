function [qTarget, qInterf, qArtif, qGlobal] = audioQualityFeatures(decompositionFilenames)
% Computes the qTarget, qInterf, qArtif, qGlobal features from the output
% of the new decomposition method:
%  - qTarget is related to the salience of the distortion of the target
%  source in the source estimate
%  - qInterf is related to the salience of the interference distortion
%  component in the source estimate
%  - qArtif is related to the salience of the artifact distortion
%  component in the source estimate
%  - qGlobal is related to audio quality of the whole estimate compared to
%  the reference
%
% decompositionFilenames is a cell array with the file names of (the order
% below must be the same):
% - the true source
% - the target distortion
% - the interference distortion component
% - the artifact and noise component
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version history
% - Version 2.0, October 2011: kept a single similarity measure for each
% distortion component
% - Version 1.1, September 2011: replaced the PEMO-Q software by a
% Matlab/MEX implementation.
% - Version 1.0.1, September 2011: added 'min' selection in the case of
% multichannel signals.
% - Version 1.0, June 2010: first release
% Copyright 2010-2011 Valentin Emiya and Emmanuel Vincent (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load signals
% RLB
% [sTrue, fs] = wavread(decompositionFilenames{1});
% eTarget = wavread(decompositionFilenames{2});
% eInterf = wavread(decompositionFilenames{3});
% eArtif = wavread(decompositionFilenames{4});

[sTrue, fs] = audioread(decompositionFilenames{1});
eTarget = audioread(decompositionFilenames{2});
eInterf = audioread(decompositionFilenames{3});
eArtif = audioread(decompositionFilenames{4});

testAll=sTrue+eTarget+eInterf+eArtif;

% compute internal representations and apply audio quality measures over
% each channel
NChan = size(sTrue,2);
qTarget = NaN(NChan,1);
qInterf = NaN(NChan,1);
qArtif = NaN(NChan,1);
qGlobal = NaN(NChan,1);
for kChan = 1:NChan
    [mtest,fr] = pemo_internal(testAll(:,kChan),fs);
    mref = pemo_internal(sTrue(:,kChan)+eInterf(:,kChan)+eArtif(:,kChan),fs);
    qTarget(kChan) = pemo_metric(mref,mtest,fr);
    mref=pemo_internal(sTrue(:,kChan)+eTarget(:,kChan)+eArtif(:,kChan),fs);
    qInterf(kChan) = pemo_metric(mref,mtest,fr);
    mref=pemo_internal(sTrue(:,kChan)+eTarget(:,kChan)+eInterf(:,kChan),fs);
    qArtif(kChan) = pemo_metric(mref,mtest,fr);
    mref=pemo_internal(sTrue(:,kChan),fs);
    qGlobal(kChan) = pemo_metric(mref,mtest,fr);
end

% for each feature, select the worst value over all channels
qTarget = min(qTarget);
qInterf = min(qInterf);
qArtif = min(qArtif);
qGlobal = min(qGlobal);

return