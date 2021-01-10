function [mx,fs]=pemo_internal(x,fs,modproc)

% PEMO_INTERNAL Example implementation of the PEMO internal representation
% 
% Disclaimer: this implementation differs from the commercial version at
% http://www.hoertech.de/web_en/produkte/pemo-q.shtml
% When accuracy is a crucial concern, the use of the commercial version is
% recommended instead.
%
% mx=internal(x,fs,modproc)
%
% Inputs:
% x: 1 x nsampl signal
% fs: sampling frequency in Hz
% modproc: type of modulation processing: 'lp' for lowpass (default) or
% 'fb' for filterbank
%
% Outputs:
% mx: nband x nsampl x nmod internal representation
% fs: sampling frequency of the internal representation (800 Hz for 'fb' or
% 100 Hz for 'lp')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version history
% - Version 2.0, October 2011: added scaling and changed 'lp' to default
% - Version 1.1, September 2011: first release
% Copyright 2011 Emmanuel Vincent (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%
% This software requires the code for the gammatone filterbank and the
% haircell model at
% http://medi.uni-oldenburg.de/download/demo/gammatone-filterbank/gammatone_filterbank-1.1.zip
% http://medi.uni-oldenburg.de/download/demo/adaption-loops/adapt_loop.zip
% Copyright 1998-2007 Medizinische Physik, Universität Oldenburg, Germany
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isdeployed
    addpath(genpath('gammatone/'));
end

%%% Errors and warnings %%%
if nargin<2, error('Not enough input arguments.'); end
[nchan,nsampl]=size(x);
if nsampl < nchan, x=x'; nchan=nsampl; end
if (nchan~=1), error('The input signal must be mono.'); end
if nargin<3, modproc='lp'; end
if ~any(strcmp(modproc,{'fb' 'lp'})), error('Unknown type of modulation processing.'); end

%%% Scaling %%%
x=10*x;

%%% Basilar membrane filtering %%%
% Gammatone filterbank with 1 filter per ERB between 235 and 14500 Hz
fmin=235;
fmax=min(.5*fs,14500);
if fs < 3*fmax,
	x=resample(x,round(1.5*fs),fs);
	fs=round(1.5*fs);
end
nsampl=length(x);
analyzer=Gfb_Analyzer_new(fs,fmin,1000,fmax,1);
nband=length(analyzer.center_frequencies_hz);
if exist('Gfb_Analyzer_fprocess','file'),
    analyzer.fast=true;
else
    warning('PEMO:noMex','MEX gammatone filterbank not compiled. Using the slow Matlab version.');
end
rx=real(Gfb_Analyzer_process(analyzer,x));

%%% Envelope extraction %%%
% Haircell model (halfwave rectification, 1 kHz lowpass filter)
if exist('haircell','file'),
    for b=1:nband,
        rx(b,:)=haircell(rx(b,:),fs);
    end
else
    warning('PEMO:noMex','MEX haircell model not compiled. Using the slow Matlab version.');
    gain=exp(-pi*2000/fs);
    rx=filter(1-gain,[1 -gain],max(rx,0),[],2);
end
% Frequency-independent absolute hearing threshold and adaptation loops
if exist('adapt','file'),
    for b=1:nband,
        rx(b,:)=adapt(rx(b,:),fs,0);
    end
else
    warning('PEMO:noMex','MEX adaptation loops not compiled. Using the slow Matlab version.');
    dbrange=single(100);
    thresh=single(10^(-dbrange/20));
    bw=1./(pi*[0.005 0.05 0.129 0.253 0.5]);
    rx=max(single(rx),thresh);
    for b=1:nband,
        sthresh=thresh;
        for s=1:5,
            gain=single(exp(-pi*bw(s)/fs));
            sthresh=sqrt(sthresh);
            factor=sthresh;
            for t=1:nsampl,
                rx(b,t)=rx(b,t)/factor;
                factor=max((1-gain)*rx(b,t)+gain*factor,sthresh);
            end
        end
    end
    rx=double(dbrange/(1-sthresh))*(double(rx)-double(sthresh));
end

%%% Modulation filtering %%%
if strcmp(modproc,'fb'),
    % Downsampling to 800 Hz
    rx=resample(rx.',800,fs).';
    nsampl=size(rx,2);
    fs=800;
    % Filterbank with 5 Hz bandwidth below 10 Hz and constant Q-value of 2 above
    fc=[0 5 10*(5/3).^(0:5)];
    bw=[5 5 5*(5/3).^(0:5)];
else
    % Downsampling to 100 Hz
    rx=resample(rx.',100,fs).';
    nsampl=size(rx,2);
    fs=100;
    % 8 Hz lowpass filter
    fc=0;
    bw=15.92;
end
nmod=length(fc);
mx=zeros(nband,nsampl,nmod);
for m=1:nmod,
    gain=exp(-pi*bw(m)/fs);
    mx(:,:,m)=filter(1-gain,[1 -gain*exp(2i*pi*fc(m)/fs)],rx,[],2);
end
% Hilbert envelope above 10 Hz
above=(fc>10);
mx(:,:,~above)=real(mx(:,:,~above));
mx(:,:,above)=abs(mx(:,:,above));

return;
