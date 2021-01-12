function [xh1, p] = IHPSS(filename, varargin)
p = inputParser;

defaultWindowSizeH = 4096;
defaultWindowSizeP = 256;
defaultBetaH = 2;
defaultBetaP = 2;
defaultLHarm = 0.2; % 200 ms
defaultLPerc = 500; % 500 Hz
defaultOutDir = 'separated';

addRequired(p, 'filename', @ischar);
addOptional(p, 'outDir', defaultOutDir, @ischar);
addParameter(p, 'windowSizeH', defaultWindowSizeH, @isnumeric);
addParameter(p, 'windowSizeP', defaultWindowSizeP, @isnumeric);
addParameter(p, 'betaH', defaultBetaH, @isnumeric);
addParameter(p, 'betaP', defaultBetaP, @isnumeric);
addParameter(p, 'harmFilter', defaultLHarm, @isnumeric);
addParameter(p, 'percFilter', defaultLPerc, @isnumeric);

parse(p, filename, varargin{:});

[x, fs] = audioread(p.Results.filename);

% STFT parameters
winLen1 = p.Results.windowSizeH;
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
lHarm1 = p.Results.harmFilter / ((fftLen1 - overlapLen1) / fs); % 200ms in samples
lPerc1 = p.Results.percFilter / (fs / fftLen1); % 500Hz in samples

H1 = movmedian(Smag1, lHarm1, 2);
P1 = movmedian(Smag1, lPerc1, 1);

% binary masks with separation factor, Driedger et al. 2014
Mh1 = (H1 ./ (P1 + eps)) > p.Results.betaH;
Mp1 = (P1 ./ (H1 + eps)) >= p.Results.betaH;

% recover the complex STFT H and P from S using the masks
H1 = Mh1 .* Shalf1;
P1 = Mp1 .* Shalf1;
R1 = Shalf1 - (H1 + P1);

% we previously dropped the redundant second half of the fft
H1 = cat(1, H1, flipud(conj(H1)));
P1 = cat(1, P1, flipud(conj(P1)));
R1 = cat(1, R1, flipud(conj(R1)));

% finally istft to convert back to audio
xh1 = istft(H1, "Window", win1, "OverlapLength", overlapLen1, ...
  "FFTLength", fftLen1, "ConjugateSymmetric", true);
xp1 = istft(P1, "Window", win1, "OverlapLength", overlapLen1,...
  "FFTLength", fftLen1, "ConjugateSymmetric", true);
xr1 = istft(R1, "Window", win1, "OverlapLength", overlapLen1,...
  "FFTLength", fftLen1, "ConjugateSymmetric", true);

%%%%%%%%%%%%%%%%%%%%
% SECOND ITERATION %
%%%%%%%%%%%%%%%%%%%%

xim2 = xp1 + xr1;

% STFT parameters
winLen2 = p.Results.windowSizeP;
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
lHarm2 = p.Results.harmFilter / ((fftLen2 - overlapLen2) / fs); % 200ms in samples
lPerc2 = p.Results.percFilter / (fs / fftLen2); % 500Hz in samples

H2 = movmedian(Smag2, lHarm2, 2);
P2 = movmedian(Smag2, lPerc2, 1);

% binary masks with separation factor, Driedger et al. 2014
Mp2 = (P2 ./ (H2 + eps)) >= p.Results.betaP;

% recover the complex STFT H and P from S using the masks
P2 = Mp2 .* Shalf2;

% we previously dropped the redundant second half of the fft
P2 = cat(1, P2, flipud(conj(P2)));

% finally istft to convert back to audio
xp2 = istft(P2, "Window", win2, "OverlapLength", overlapLen2,...
  "FFTLength", fftLen2, "ConjugateSymmetric", true);

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname,"_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.outDir,prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.outDir,prefix);

if size(xh1, 1) < size(x, 1)
    xh1 = [xh1; x(size(xh1, 1)+1:size(x, 1))];
end

if size(xp2, 1) < size(x, 1)
    xp2 = [xp2; x(size(xp2, 1)+1:size(x, 1))];
end

audiowrite(xhOut, xh1, fs);
audiowrite(xpOut, xp2, fs);
end