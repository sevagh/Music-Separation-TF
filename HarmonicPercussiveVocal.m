function HarmonicPercussiveVocal(filename, varargin)
p = inputParser;

WindowSizeH = 16384;
HopSizeH = 2048;

WindowSizeP = 512;
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

% STFT parameters
winLen1 = WindowSizeH;
fftLen1 = winLen1 * 2;
overlapLen1 = HopSizeH;
win1 = sqrt(hann(winLen1, "periodic"));

% STFT of original signal
S1 = stft(x, "Window", win1, "OverlapLength", overlapLen1, ...
  "FFTLength", fftLen1, "Centered", true);

halfIdx1 = 1:ceil(size(S1, 1) / 2); % only half the STFT matters
Shalf1 = S1(halfIdx1, :);
Smag1 = abs(Shalf1); % use the magnitude STFT for creating masks

% median filters
H1 = movmedian(Smag1, LHarmSTFT, 2);
P1 = movmedian(Smag1, LPercSTFT, 1);

% soft masks, Fitzgerald 2010 - p is usually 1 or 2
Hp1 = H1 .^ Power;
Pp1 = P1 .^ Power;
total1 = Hp1 + Pp1;
Mh1 = Hp1 ./ total1;
Mp1 = Pp1 ./ total1;

% recover the complex STFT H and P from S using the masks
H1 = Mh1 .* Shalf1;
P1 = Mp1 .* Shalf1;

% we previously dropped the redundant second half of the fft
H1 = cat(1, H1, flipud(conj(H1)));
P1 = cat(1, P1, flipud(conj(P1)));

% finally istft to convert back to audio
xh1 = istft(H1, "Window", win1, "OverlapLength", overlapLen1, ...
  "FFTLength", fftLen1, "ConjugateSymmetric", true);
xp1 = istft(P1, "Window", win1, "OverlapLength", overlapLen1,...
  "FFTLength", fftLen1, "ConjugateSymmetric", true);
%xr1 = istft(R1, "Window", win1, "OverlapLength", overlapLen1,...
%  "FFTLength", fftLen1, "ConjugateSymmetric", true);

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

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname, "_");
prefix = splt{1};

% fix up some lengths
if size(xh1, 1) < size(x, 1)
    xh1 = [xh1; x(size(xh1, 1)+1:size(x, 1))];
end

if size(xp3, 1) < size(x, 1)
    xp3 = [xp3; x(size(xp3, 1)+1:size(x, 1))];
end

if size(xh2, 1) < size(x, 1)
    xh2 = [xh2; x(size(xh2, 1)+1:size(x, 1))];
    xp2 = [xp2; x(size(xp2, 1)+1:size(x, 1))];
end

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.OutDir, prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.OutDir, prefix);
xvOut = sprintf("%s/%s_vocal.wav", p.Results.OutDir, prefix);

audiowrite(xhOut, xh1, fs);
audiowrite(xpOut, xp3 + xp2, fs);
audiowrite(xvOut, xh2, fs);
end
