function [ISR, SIR, SAR, SDR] = ...
    ISR_SIR_SAR_fromNewDecomposition(decompositionFilenames)
% Computes the ISR, SIR and SAR (and the SDR optionaly) from the output of 
% the new decomposition method.
%
% Usage:
%   [ISR, SIR, SAR] = ...
%         ISR_SIR_SAR_fromNewDecomposition(decompositionFilenames)
%
%   [ISR, SIR, SAR, SDR] = ...
%         ISR_SIR_SAR_fromNewDecomposition(decompositionFilenames)
%
% decompositionFilenames is a cell array with the file names of (the order
% below must be the same):
% - the true source
% - the the target distortion
% - the interference distortion component
% - the artifact and noise component
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.0
% Copyright 2010 Valentin Emiya (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RLB
%sTrue = wavread(decompositionFilenames{1});
%eTarget = wavread(decompositionFilenames{2});
%eInterf = wavread(decompositionFilenames{3});
%eArtif = wavread(decompositionFilenames{4});
sTrue = audioread(decompositionFilenames{1});
eTarget = audioread(decompositionFilenames{2});
eInterf = audioread(decompositionFilenames{3});
eArtif = audioread(decompositionFilenames{4});

ISR = 10*log10(sum(sTrue(:).^2)/sum(eTarget(:).^2));
SIR = 10*log10(sum((sTrue(:)+eTarget(:)).^2)/sum(eInterf(:).^2));
SAR = 10*log10(sum((sTrue(:)+eTarget(:)+eInterf(:)).^2)/sum(eArtif(:).^2));

if nargout>3
    SDR = 10*log10(sum(sTrue(:).^2)/sum((eTarget(:)+eInterf(:)+eArtif(:)).^2));
end
return