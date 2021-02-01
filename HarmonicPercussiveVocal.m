function HarmonicPercussiveVocal(filename, varargin)
p = inputParser;

WindowSizeH = 16384;
WindowSizeP = 256;
Beta = 2;
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
overlapLen1 = winLen1 / 2;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECOND ITERATION, PERCUSSIVE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xim2 = xp1; % + xr1;

% STFT parameters
winLen2 = WindowSizeP;
fftLen2 = winLen2 * 2;
overlapLen2 = winLen2 / 2;
win2 = sqrt(hann(winLen2, "periodic"));

% STFT of original signal
S2 = stft(xim2, "Window", win2, "OverlapLength", overlapLen2, ...
  "FFTLength", fftLen2, "Centered", true);

halfIdx2 = 1:ceil(size(S2, 1) / 2); % only half the STFT matters
Shalf2 = S2(halfIdx2, :);
Smag2 = abs(Shalf2); % use the magnitude STFT for creating masks

% median filters
H2 = movmedian(Smag2, LHarmSTFT, 2);
P2 = movmedian(Smag2, LPercSTFT, 1);

% binary masks with separation factor, Driedger et al. 2014
Mp2 = (P2 ./ (H2 + eps)) >= Beta;

% recover the complex STFT H and P from S using the masks
P2 = Mp2 .* Shalf2;

% we previously dropped the redundant second half of the fft
P2 = cat(1, P2, flipud(conj(P2)));

% finally istft to convert back to audio
xp2 = istft(P2, "Window", win2, "OverlapLength", overlapLen2,...
  "FFTLength", fftLen2, "ConjugateSymmetric", true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECOND ITERATION, VOCAL %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CQT of original signal
[cfs2,~,g2,fshifts2] = cqt(xim2, 'SamplingFrequency', fs, 'BinsPerOctave', 24);

cmag2 = abs(cfs2); % use the magnitude CQT for creating masks

H2 = movmedian(cmag2, LHarmCQT, 2);
P2 = movmedian(cmag2, LPercCQT, 1);

% soft masks, Fitzgerald 2010 - p is usually 1 or 2
Hp2 = H2 .^ Power;
Pp2 = P2 .^ Power;
total2 = Hp2 + Pp2;
Mh2 = Hp2 ./ total2;

% recover the complex STFT H and P from S using the masks
H2 = Mh2 .* cfs2;

% finally istft to convert back to audio
xh2 = icqt(H2, g2, fshifts2);

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname, "_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.OutDir, prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.OutDir, prefix);
xvOut = sprintf("%s/%s_vocal.wav", p.Results.OutDir, prefix);

if size(xh1, 1) < size(x, 1)
    xh1 = [xh1; x(size(xh1, 1)+1:size(x, 1))];
end

if size(xp2, 1) < size(x, 1)
    xp2 = [xp2; x(size(xp2, 1)+1:size(x, 1))];
end

if size(xh2, 1) < size(x, 1)
    xh2 = [xh2; x(size(xh2, 1)+1:size(x, 1))];
end

audiowrite(xhOut, xh1, fs);
audiowrite(xpOut, xp2, fs);
audiowrite(xvOut, xh2, fs);
end
