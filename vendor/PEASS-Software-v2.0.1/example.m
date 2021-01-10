function example
% Run this file to see an example
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version history
%  - Version 2.0, October 2011: reduced the number of displayed digits
%  - Version 1.0, June 2010: first release
% Copyright 2010-2011 Valentin Emiya and Emmanuel Vincent (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%
% Set inputs
%%%%%%%%%%%%
originalFiles = {...
    'custom/000_harmonic.wav';...
    'custom/000_percussive.wav'};
estimateFile = 'custom/fitzgerald_000_mix_harm_sep.wav';

%%%%%%%%%%%%%
% Set options
%%%%%%%%%%%%%
options.destDir = 'custom/';
options.segmentationFactor = 1; % increase this integer if you experienced "out of memory" problems

%%%%%%%%%%%%%%%%%%%%
% Call main function
%%%%%%%%%%%%%%%%%%%%
res = PEASS_ObjectiveMeasure(originalFiles,estimateFile,options);

%%%%%%%%%%%%%%%%%
% Display results
%%%%%%%%%%%%%%%%%

fprintf('************************\n');
fprintf('* INTERMEDIATE RESULTS *\n');
fprintf('************************\n');

fprintf('The decomposition has been generated and stored in:\n');
cellfun(@(s)fprintf(' - %s\n',s),res.decompositionFilenames);

fprintf('The ISR, SIR, SAR and SDR criteria computed with the new decomposition are:\n');
fprintf(' - SDR = %.1f dB\n - ISR = %.1f dB\n - SIR = %.1f dB\n - SAR = %.1f dB\n',...
    res.SDR,res.ISR,res.SIR,res.SAR);

fprintf('The audio quality (PEMO-Q) criteria computed with the new decomposition are:\n');
fprintf(' - qGlobal = %.3f\n - qTarget = %.3f\n - qInterf = %.3f\n - qArtif = %.3f\n',...
    res.qGlobal,res.qTarget,res.qInterf,res.qArtif);

fprintf('*************************\n');
fprintf('****  FINAL RESULTS  ****\n');
fprintf('*************************\n');
fprintf(' - Overall Perceptual Score: OPS = %.f/100\n',res.OPS)
fprintf(' - Target-related Perceptual Score: TPS = %.f/100\n',res.TPS)
fprintf(' - Interference-related Perceptual Score: IPS = %.f/100\n',res.IPS)
fprintf(' - Artifact-related Perceptual Score: APS = %.f/100\n',res.APS);

return
