function [xh, p] = HPSS_1pass(filename, varargin)
p = inputParser;

defaultSTFT = 'linear';
defaultWindowSize = 1024;
defaultBinsPerOctave = 48;

validSTFT = {'linear', 'cqt'};
checkSTFT = @(x) any(validatestring(x, validSTFT));

defaultMask = 'hard';
validMasks = {'soft', 'hard'};
checkMask = @(x) any(validatestring(x, validMasks));

defaultOutDir = '.';

Beta = 2;
Power = 2;

LHarmSTFT = 17;
LPercSTFT = 17;

LHarmCQT = 17;
LPercCQT = 7;

addRequired(p, 'filename', @ischar);
addOptional(p, 'OutDir', defaultOutDir, @ischar);
addParameter(p, 'Mask', defaultMask, checkMask);
addParameter(p, 'STFT', defaultSTFT, checkSTFT);
addParameter(p, 'STFTWindowSize', defaultWindowSize, @isnumeric);
addParameter(p, 'CQTBinsPerOctave', defaultBinsPerOctave, @isnumeric);

parse(p, filename, varargin{:});

[x, fs] = audioread(p.Results.filename);

if strcmp(p.Results.STFT, "linear")
    % STFT parameters
    winLen = p.Results.STFTWindowSize;
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
    H = movmedian(Smag, LHarmSTFT, 2);
    P = movmedian(Smag, LPercSTFT, 1);

    if strcmp(p.Results.Mask, "hard")
        % binary masks with separation factor, Driedger et al. 2014
        Mh = (H ./ (P + eps)) > Beta;
        Mp = (P ./ (H + eps)) >= Beta;
    elseif strcmp(p.Results.Mask, "soft")
        % soft masks, Fitzgerald 2010 - p is usually 1 or 2
        Hp = H .^ Power;
        Pp = P .^ Power;
        total = Hp + Pp;
        Mh = Hp ./ total;
        Mp = Pp ./ total;
    end
    
    Mr = 1 - (Mh + Mp);

    % recover the complex STFT H and P from S using the masks
    H = Mh .* Shalf;
    P = Mp .* Shalf;
    R = Mr .* Shalf;

    % we previously dropped the redundant second half of the fft
    H = cat(1, H, flipud(conj(H)));
    P = cat(1, P, flipud(conj(P)));
    R = cat(1, R, flipud(conj(R)));

    % finally istft to convert back to audio
    xh = istft(H, "Window", win, "OverlapLength", overlapLen, ...
      "FFTLength", fftLen, "ConjugateSymmetric", true);
    xp = istft(P, "Window", win, "OverlapLength", overlapLen,...
      "FFTLength", fftLen, "ConjugateSymmetric", true);
    xr = istft(R, "Window", win, "OverlapLength", overlapLen,...
      "FFTLength", fftLen, "ConjugateSymmetric", true);
elseif strcmp(p.Results.STFT, "cqt")
    [cfs,~,g, fshifts] = cqt(x, 'SamplingFrequency', fs, 'BinsPerOctave', p.Results.CQTBinsPerOctave);
    
    cmag = abs(cfs);

    % median filters
    H = movmedian(cmag, LHarmCQT, 2);
    P = movmedian(cmag, LPercCQT, 1);

    if strcmp(p.Results.Mask, "hard")
        % binary masks with separation factor, Driedger et al. 2014
        Mh = (H ./ (P + eps)) > Beta;
        Mp = (P ./ (H + eps)) >= Beta;
    elseif strcmp(p.Results.Mask, "soft")
        % soft masks, Fitzgerald 2010 - p is usually 1 or 2
        Hp = H .^ Power;
        Pp = P .^ Power;
        total = Hp + Pp;
        Mh = Hp ./ total;
        Mp = Pp ./ total;
    end
    Mr = 1 - (Mh + Mp);

    % recover the complex STFT H and P from S using the masks
    H = Mh .* cfs;
    P = Mp .* cfs;
    R = Mr .* cfs;

    % finally istft to convert back to audio
    xh = icqt(H, g, fshifts);
    xp = icqt(P, g, fshifts);
    xr = icqt(R, g, fshifts);
end

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname,"_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.OutDir, prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.OutDir, prefix);
xrOut = sprintf("%s/%s_residual.wav", p.Results.OutDir, prefix);

if size(xh, 1) < size(x, 1)
    xh = [xh; x(size(xh, 1)+1:size(x, 1))];
    xp = [xp; x(size(xp, 1)+1:size(x, 1))];
    xr = [xr; x(size(xr, 1)+1:size(x, 1))];
end

audiowrite(xhOut, xh, fs);
audiowrite(xpOut, xp, fs);
audiowrite(xrOut, xr, fs);
end