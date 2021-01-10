function [xSynth, synthesizer, M] = ...
    myPemoSynthesisFilterBank(xFB,analyzer,M)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.0
% Copyright 2010 Valentin Emiya (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2,
    error('Not enough input arguments.');
end

% upsample
Nb = size(xFB,1);
fs = analyzer.sampling_frequency_hz;
gfb_out_proc = zeros(Nb,max(cellfun('length',xFB(:)).*analyzer.Ndec(:)));
for k=1:Nb
    gfb_out_proc(k,1:length(xFB{k})*analyzer.Ndec(k)) = resample(xFB{k},analyzer.Ndec(k),1);
end

if nargin<3 || isempty(M)
    M = exp(2*1i*pi/fs*analyzer.center_frequencies_hz(:)*(0:size(gfb_out_proc,2)-1));
end
gfb_out_proc = gfb_out_proc.*M;

% synthesis gammatone filterbank
desired_delay_in_seconds = 1 / fs*1000;
synthesizer = Gfb_Synthesizer_new(analyzer, desired_delay_in_seconds);
[xSynth, synthesizer] = Gfb_Synthesizer_process(synthesizer, gfb_out_proc);
xSynth = resample(xSynth,analyzer.fsOrig,analyzer.fs);
xSynth = xSynth(round(desired_delay_in_seconds*analyzer.fsOrig+1):end);

return
