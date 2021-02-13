function HarmonicPercussiveVocal9(filename, varargin)
p = inputParser;

WindowSizeP = 1024;
HopSizeP = 256;

Power = 2;

LHarmSTFT = 17;
LPercSTFT = 17;

LHarmCQT = 17;
LPercCQT = 7;

defaultOutDir = '.';

addRequired(p, 'filename', @ischar);
addOptional(p, 'OutDir', defaultOutDir, @ischar);

parse(p, filename, varargin{:});

[x, fs] = audioread(p.Results.filename);

%%%%%%%%%%%%%%%%%%%
% FIRST ITERATION %
%%%%%%%%%%%%%%%%%%%

% CQT of original signal
[cfs1,~,g1,fshifts1] = cqt(x, 'SamplingFrequency', fs, 'BinsPerOctave', 96);

cmag1 = abs(cfs1); % use the magnitude CQT for creating masks

H1 = movmedian(cmag1, LHarmCQT, 2);
P1 = movmedian(cmag1, LPercCQT, 1);

% soft masks, Fitzgerald 2010 - p is usually 1 or 2
Hp1 = H1 .^ Power;
Pp1 = P1 .^ Power;
total1 = Hp1 + Pp1;
Mh1 = Hp1 ./ total1;
Mp1 = Pp1 ./ total1;

% recover the complex STFT H and P from S using the masks
H1 = Mh1 .* cfs1;
P1 = Mp1 .* cfs1;

% finally istft to convert back to audio
xh1 = icqt(H1, g1, fshifts1);
xp1 = icqt(P1, g1, fshifts1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECOND ITERATION, VOCAL %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

xim2 = xp1;

% CQT of original signal
[cfs2,~,g2,fshifts2] = cqt(xim2, 'SamplingFrequency', fs, 'BinsPerOctave', 24);

cmag2 = abs(cfs2); % use the magnitude CQT for creating masks

H2 = movmedian(cmag2, LHarmCQT, 2);
P2 = movmedian(cmag2, LPercCQT, 1);

% soft mask
Hp2 = H2 .^ Power;
Pp2 = P2 .^ Power;
total2 = Hp2 + Pp2;
Mh2 = Hp2 ./ total2;
Mp2 = Pp2 ./ total2;

% todo - set bins of mask below 100hz to 0

% recover the complex STFT H and P from S using the masks
H2 = Mh2 .* cfs2;
P2 = Mp2 .* cfs2;

% finally istft to convert back to audio
xh2 = icqt(H2, g2, fshifts2);
xp2 = icqt(P2, g2, fshifts2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIRD ITERATION, PERCUSSIVE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xim3 = xp1 + xp2;

% STFT parameters
winLen3 = WindowSizeP;
fftLen3 = winLen3 * 2;
overlapLen3 = HopSizeP;
win3 = sqrt(hann(winLen3, "periodic"));

% STFT of original signal
S3 = stft(xim3, "Window", win3, "OverlapLength", overlapLen3, ...
  "FFTLength", fftLen3, "Centered", true);

halfIdx3 = 1:ceil(size(S3, 1) / 2); % only half the STFT matters
Shalf3 = S3(halfIdx3, :);
Smag3 = abs(Shalf3); % use the magnitude STFT for creating masks

% median filters
H3 = movmedian(Smag3, LHarmSTFT, 2);
P3 = movmedian(Smag3, LPercSTFT, 1);

% binary masks with separation factor, Driedger et al. 2014
% soft masks, Fitzgerald 2010 - p is usually 1 or 2
Hp3 = H3 .^ Power;
Pp3 = P3 .^ Power;
total3 = Hp3 + Pp3;
Mp3 = Pp3 ./ total3;

% recover the complex STFT H and P from S using the masks
P3 = Mp3 .* Shalf3;

% we previously dropped the redundant second half of the fft
P3 = cat(1, P3, flipud(conj(P3)));

% finally istft to convert back to audio
xp3 = istft(P3, "Window", win3, "OverlapLength", overlapLen3,...
  "FFTLength", fftLen3, "ConjugateSymmetric", true);
%xp3 = xp3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOURTH ITERATION, REFINE HARMONIC %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if size(xp3, 1) < size(x, 1)
    xp3 = [xp3; x(size(xp3, 1)+1:size(x, 1))];
end

if size(xh2, 1) < size(x, 1)
    xh2 = [xh2; x(size(xh2, 1)+1:size(x, 1))];
    xp2 = [xp2; x(size(xp2, 1)+1:size(x, 1))];
end

% use 2nd iter vocal estimation to improve harmonic sep
x_vocal = xh2;
x_harmonic = xh1;
x_percussive = xp2+xp3;

% CQT of harmonic signal
% use a high frequency resolution here as  well
[cfs4,~,g4,fshifts4] = cqt(x_harmonic, 'SamplingFrequency', fs, 'BinsPerOctave', 12);
[cfs4_vocal,~,~,~] = cqt(x_vocal, 'SamplingFrequency', fs, 'BinsPerOctave', 12);
[cfs4_percussive,~,~,~] = cqt(x_percussive, 'SamplingFrequency', fs, 'BinsPerOctave', 12);

cmag4 = abs(cfs4); % use the magnitude CQT for creating masks
cmag4_vocal = abs(cfs4_vocal);
cmag4_percussive = abs(cfs4_percussive);

% soft masks, Fitzgerald 2010 - p is usually 1 or 2
H4 = cmag4 .^ Power;
V4 = cmag4_vocal .^ Power;
P4 = cmag4_percussive .^ Power;
total4 = H4 + V4 + P4;
Mh4 = H4 ./ total4;

H4 = Mh4 .* cfs4;

% finally istft to convert back to audio
xh4 = icqt(H4, g4, fshifts4);

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname, "_");
prefix = splt{1};

% fix up some lengths
if size(xh4, 1) < size(x, 1)
    xh4 = [xh4; x(size(xh4, 1)+1:size(x, 1))];
end

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.OutDir, prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.OutDir, prefix);
xvOut = sprintf("%s/%s_vocal.wav", p.Results.OutDir, prefix);

xh = xh4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIFTH STAGE - TRANSIENT SHAPER %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% enhance percussive transients (noisegate-ish function)
% suppress harmonic transients (expander)

% dont touch vocals since transients and tonal components are both present

b = hz2bark([20, 20000]);
barkVect = linspace(b(1), b(2), 24);
hzVect = bark2hz(barkVect);

xh_suppressed = zeros(size(xh));

attackFastMs = 1;
attackSlowMs = 15;
releaseMs = 20;

for bands = 1:1:size(hzVect, 2)-1
    bandEdges = hzVect(bands:bands+1);
    fprintf("band %f - %f Hz\n", bandEdges(1), bandEdges(2));

    yh = bandpass(xh, bandEdges, fs);

    [~, ~, ~, sustain] = transientShaper(yh, fs,...
        attackFastMs, attackSlowMs, releaseMs);

    yh_suppressed = yh .* sustain;
    
    xh_suppressed = xh_suppressed + yh_suppressed;
end

audiowrite(xhOut, xh_suppressed, fs);
audiowrite(xpOut, xp3+xp2, fs);
audiowrite(xvOut, xh2, fs);
end
