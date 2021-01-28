function [xh, p] = HPSS_Multipass_Fitzgerald(filename, varargin)

p = inputParser;

defaultMask = 'hard';
validMasks = {'soft', 'hard'};
checkMask = @(x) any(validatestring(x, validMasks));

defaultWindowSize = 1024;
defaultBeta = 2;
defaultPower = 2;
defaultLHarm = 0.2; % 200 ms
defaultLPerc = 500; % 500 Hz
defaultOutDir = 'separated';

addRequired(p, 'filename', @ischar);
addOptional(p, 'outDir', defaultOutDir, @ischar);
addParameter(p, 'mask', defaultMask, checkMask);
addParameter(p, 'windowSize', defaultWindowSize, @isnumeric);
addParameter(p, 'beta', defaultBeta, @isnumeric);
addParameter(p, 'power', defaultPower, @isnumeric);
addParameter(p, 'harmFilter', defaultLHarm, @isnumeric);
addParameter(p, 'percFilter', defaultLPerc, @isnumeric);

parse(p, filename, varargin{:});

[x, fs] = audioread(p.Results.filename);

% STFT parameters
winLen = p.Results.windowSize;
fftLen = winLen * 2;
overlapLen = winLen / 2;
win = sqrt(hann(winLen, "periodic"));

% STFT of original signal
S = stft(x, "Window", win, "OverlapLength", overlapLen, ...
  "FFTLength", fftLen, "Centered", true);

halfIdx = 1:ceil(size(S, 1) / 2); % only half the STFT matters
Shalf = S(halfIdx, :);
Smag = abs(Shalf); % use the magnitude STFT for creating masks

% median filters
lHarm = p.Results.harmFilter / ((fftLen - overlapLen) / fs); % 200ms in samples
H = movmedian(Smag, lHarm, 2);
lPerc = p.Results.percFilter / (fs / fftLen); % 500Hz in samples
P = movmedian(Smag, lPerc, 1);

if strcmp(p.Results.mask, "hard")
    % binary masks with separation factor, Driedger et al. 2014
    Mh = (H ./ (P + eps)) > p.Results.beta;
    Mp = (P ./ (H + eps)) >= p.Results.beta;
elseif strcmp(p.Results.mask, "soft")
    % soft masks, Fitzgerald 2010 - p is usually 1 or 2
    Hp = H .^ p.Results.power;
    Pp = P .^ p.Results.power;
    total = Hp + Pp;
    Mh = Hp ./ total;
    Mp = Pp ./ total;
end

% recover the complex STFT H and P from S using the masks
H = Mh .* Shalf;
P = Mp .* Shalf;

% we previously dropped the redundant second half of the fft
H = cat(1, H, flipud(conj(H)));
P = cat(1, P, flipud(conj(P)));

% finally istft to convert back to audio
xh = istft(H, "Window", win, "OverlapLength", overlapLen, ...
  "FFTLength", fftLen, "ConjugateSymmetric", true);
xp = istft(P, "Window", win, "OverlapLength", overlapLen,...
  "FFTLength", fftLen, "ConjugateSymmetric", true);

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname,"_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.outDir,prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.outDir,prefix);

if size(xh, 1) < size(x, 1)
    xh = [xh; x(size(xh, 1)+1:size(x, 1))];
    xp = [xp; x(size(xp, 1)+1:size(x, 1))];
end

audiowrite(xhOut, xh, fs);
audiowrite(xpOut, xp, fs);
endfunction [xh, p] = HPSS_CQT(filename, varargin)
p = inputParser;

defaultMask = 'hard';
validMasks = {'soft', 'hard'};
checkMask = @(x) any(validatestring(x, validMasks));

defaultBeta = 2;
defaultPower = 2;
defaultLHarm = 100;
defaultLPerc = 10;
defaultOutDir = 'separated';

addRequired(p, 'filename', @ischar);
addOptional(p, 'outDir', defaultOutDir, @ischar);
addParameter(p, 'mask', defaultMask, checkMask);
addParameter(p, 'beta', defaultBeta, @isnumeric);
addParameter(p, 'power', defaultPower, @isnumeric);
addParameter(p, 'harmFilter', defaultLHarm, @isnumeric);
addParameter(p, 'percFilter', defaultLPerc, @isnumeric);

parse(p, filename, varargin{:});

[x, fs] = audioread(p.Results.filename);

% CQT of original signal
[cfs,~,g,fshifts] = cqt(x, 'SamplingFrequency', fs);

cmag = abs(cfs); % use the magnitude CQT for creating masks

% median filters
lHarm = p.Results.harmFilter; % 200ms in samples
H = movmedian(cmag, lHarm, 2);
lPerc = p.Results.percFilter; % 500Hz in samples
P = movmedian(cmag, lPerc, 1);

if strcmp(p.Results.mask, "hard")
    % binary masks with separation factor, Driedger et al. 2014
    Mh = (H ./ (P + eps)) > p.Results.beta;
    Mp = (P ./ (H + eps)) >= p.Results.beta;
elseif strcmp(p.Results.mask, "soft")
    % soft masks, Fitzgerald 2010 - p is usually 1 or 2
    Hp = H .^ p.Results.power;
    Pp = P .^ p.Results.power;
    total = Hp + Pp;
    Mh = Hp ./ total;
    Mp = Pp ./ total;
end

% recover the complex STFT H and P from S using the masks
H = Mh .* cfs;
P = Mp .* cfs;

% finally istft to convert back to audio
xh = icqt(H, g, fshifts);
xp = icqt(P, g, fshifts);

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname,"_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.outDir,prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.outDir,prefix);

if size(xh, 1) < size(x, 1)
    xh = [xh; x(size(xh, 1)+1:size(x, 1))];
    xp = [xp; x(size(xp, 1)+1:size(x, 1))];
end

audiowrite(xhOut, xh, fs);
audiowrite(xpOut, xp, fs);
end