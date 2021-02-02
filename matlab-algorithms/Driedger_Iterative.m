function Driedger_Iterative(filename, varargin)
p = inputParser;

defaultLoResSTFT = 'linear';
defaultHiResSTFT = 'linear';

validSTFT = {'linear', 'cqt'};
checkSTFT = @(x) any(validatestring(x, validSTFT));

WindowSizeH = 4096;
WindowSizeP = 256;
Beta = 2;

LHarmSTFT = 17;
LPercSTFT = 17;

LHarmCQT = 17;
LPercCQT = 7;

defaultOutDir = '.';

addRequired(p, 'filename', @ischar);
addOptional(p, 'OutDir', defaultOutDir, @ischar);
addParameter(p, 'LoResSTFT', defaultLoResSTFT, checkSTFT);
addParameter(p, 'HiResSTFT', defaultHiResSTFT, checkSTFT);

parse(p, filename, varargin{:});

[x, fs] = audioread(p.Results.filename);

%%%%%%%%%%%%%%%%%%%
% FIRST ITERATION %
%%%%%%%%%%%%%%%%%%%

if strcmp(p.Results.HiResSTFT, "linear")
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

    % binary masks with separation factor, Driedger et al. 2014
    Mh1 = (H1 ./ (P1 + eps)) > Beta;
    Mp1 = (P1 ./ (H1 + eps)) >= Beta;
    Mr1 = 1 - (Mh1 + Mp1);

    % recover the complex STFT H and P from S using the masks
    H1 = Mh1 .* Shalf1;
    P1 = Mp1 .* Shalf1;
    R1 = Mr1 .* Shalf1;

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
elseif strcmp(p.Results.HiResSTFT, "cqt")
    % CQT of original signal
    [cfs1,~,g1,fshifts1] = cqt(x, 'SamplingFrequency', fs, 'BinsPerOctave', 96);
    
    cmag1 = abs(cfs1); % use the magnitude CQT for creating masks

    H1 = movmedian(cmag1, LHarmCQT, 2);
    P1 = movmedian(cmag1, LPercCQT, 1);
    
    Mh1 = (H1 ./ (P1 + eps)) > Beta;
    Mp1 = (P1 ./ (H1 + eps)) >= Beta;
    Mr1 = 1 - (Mh1 + Mp1);
    
    % recover the complex STFT H and P from S using the masks
    H1 = Mh1 .* cfs1;
    P1 = Mp1 .* cfs1;
    R1 = Mr1 .* cfs1;

    % finally istft to convert back to audio
    xh1 = icqt(H1, g1, fshifts1);
    xp1 = icqt(P1, g1, fshifts1);
    xr1 = icqt(R1, g1, fshifts1);
end

%%%%%%%%%%%%%%%%%%%%
% SECOND ITERATION %
%%%%%%%%%%%%%%%%%%%%

xim2 = xp1 + xr1;

if strcmp(p.Results.LoResSTFT, "linear")
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
    Mh2 = (H2 ./ (P2 + eps)) > Beta;
    Mp2 = (P2 ./ (H2 + eps)) >= Beta;
    Mr2 = 1 - (Mh2 + Mp2);

    % recover the complex STFT H and P from S using the masks
    H2 = Mh2 .* Shalf2;
    P2 = Mp2 .* Shalf2;
    R2 = Mr2 .* Shalf2;

    % we previously dropped the redundant second half of the fft
    H2 = cat(1, H2, flipud(conj(H2)));
    P2 = cat(1, P2, flipud(conj(P2)));
    R2 = cat(1, R2, flipud(conj(R2)));

    % finally istft to convert back to audio
    xh2 = istft(H2, "Window", win2, "OverlapLength", overlapLen2,...
      "FFTLength", fftLen2, "ConjugateSymmetric", true);
    xr2 = istft(R2, "Window", win2, "OverlapLength", overlapLen2,...
      "FFTLength", fftLen2, "ConjugateSymmetric", true);
    xp2 = istft(P2, "Window", win2, "OverlapLength", overlapLen2,...
      "FFTLength", fftLen2, "ConjugateSymmetric", true);
elseif strcmp(p.Results.LoResSTFT, "cqt")
    % CQT of original signal
    [cfs2,~,g2,fshifts2] = cqt(xim2, 'SamplingFrequency', fs, 'BinsPerOctave', 24);
    
    cmag2 = abs(cfs2); % use the magnitude CQT for creating masks

    H2 = movmedian(cmag2, LHarmCQT, 2);
    P2 = movmedian(cmag2, LPercCQT, 1);
    
    Mh2 = (H2 ./ (P2 + eps)) > Beta;
    Mp2 = (P2 ./ (H2 + eps)) >= Beta;
    Mr2 = 1 - (Mh2 + Mp2);
    
    % recover the complex STFT H and P from S using the masks
    H2 = Mh2 .* cfs2;
    R2 = Mr2 .* cfs2;
    P2 = Mp2 .* cfs2;

    % finally istft to convert back to audio
    xp2 = icqt(P2, g2, fshifts2);
    xr2 = icqt(R2, g2, fshifts2);
    xh2 = icqt(H2, g2, fshifts2);
end

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname, "_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.OutDir, prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.OutDir, prefix);
xrOut = sprintf("%s/%s_vocal.wav", p.Results.OutDir, prefix);

if size(xh1, 1) < size(x, 1)
    xh1 = [xh1; x(size(xh1, 1)+1:size(x, 1))];
end

if size(xp2, 1) < size(x, 1)
    xp2 = [xp2; x(size(xp2, 1)+1:size(x, 1))];
end

if size(xr2, 1) < size(x, 1)
    xr2 = [xr2; x(size(xr2, 1)+1:size(x, 1))];
    xh2 = [xh2; x(size(xh2, 1)+1:size(x, 1))];
end

audiowrite(xhOut, xh1, fs);
audiowrite(xpOut, xp2, fs);
audiowrite(xrOut, xr2+xh2, fs);
end
