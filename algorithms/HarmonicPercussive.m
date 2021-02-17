function HarmonicPercussive(filename, varargin)
p = inputParser;

defaultOutDir = '.';

addRequired(p, 'filename', @ischar);
addOptional(p, 'OutDir', defaultOutDir, @ischar);

parse(p, filename, varargin{:});

[x, fs] = audioread(p.Results.filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HARMONIC WITH TFJIGSAW-1 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tfjigsaw-5
[seps, ~] = tfjigsawsep(x, 0.88, 1.05, 2, 'fs', fs);
xh = seps(:, 1);

if size(xh, 1) < size(x, 1)
    xh = [xh; x(size(xh, 1)+1:size(x, 1))];
end

Power = 2;
LPercSTFT = 17;

% STFT parameters
winLen = 2048;
fftLen = winLen * 2;
overlapLen = winLen / 2;
win = sqrt(hann(winLen, "periodic"));

% STFT of original signal
S = stft(x, "Window", win, "OverlapLength", overlapLen, ...
  "FFTLength", fftLen, "Centered", true);

halfIdx = 1:ceil(size(S, 1) / 2); % only half the STFT matters
Shalf = S(halfIdx, :);
Smag = abs(Shalf); % use the magnitude STFT for creating masks

% use excellent tfjigsaw5 harmonic sep to estimate harmonic energy
Sh = stft(xh, "Window", win, "OverlapLength", overlapLen, ...
  "FFTLength", fftLen, "Centered", true);
Shalfh = Sh(halfIdx, :);
H = abs(Shalfh);

% median filters
P = movmedian(Smag, LPercSTFT, 1);

% soft masks, Fitzgerald 2010 - p is usually 1 or 2
Hp = H .^ Power;
Pp = P .^ Power;
total = Hp + Pp;
Mh = Hp ./ total;
Mp = Pp ./ total;

% recover the complex STFT H and P from S using the masks
H = Mh .* Shalf;
P = Mp .* Shalf;

% we previously dropped the redundant second half of the fft
P = cat(1, P, flipud(conj(P)));

% finally istft to convert back to audio
xp = istft(P, "Window", win, "OverlapLength", overlapLen,...
  "FFTLength", fftLen, "ConjugateSymmetric", true);

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname,"_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.OutDir, prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.OutDir, prefix);

if size(xp, 1) < size(x, 1)
    xp = [xp; x(size(xp, 1)+1:size(x, 1))];
end

audiowrite(xhOut, xh, fs);
audiowrite(xpOut, xp, fs);
end
