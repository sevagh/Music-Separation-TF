function Driedger_Iterative(filename, varargin)

% include vendored WarpTB code
addpath(genpath('vendor/WarpTB/'));

p = inputParser;

defaultLowResSTFT = 'linear';
validLowResSTFT = {'linear', 'cqt', 'warped'};
checkLowResSTFT = @(x) any(validatestring(x, validLowResSTFT));

WindowSizeH = 4096;
WindowSizeP = 256;
Beta = 2;

LHarmSTFT = 17;
LPercSTFT = 17;

LHarmCQT = 17;
LPercCQT = 7;

defaultOutDir = 'separated';

addRequired(p, 'filename', @ischar);
addOptional(p, 'outDir', defaultOutDir, @ischar);
addParameter(p, 'LowResSTFT', defaultLowResSTFT, checkLowResSTFT);

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

% binary masks with separation factor, Driedger et al. 2014
Mh1 = (H1 ./ (P1 + eps)) > Beta;
Mp1 = (P1 ./ (H1 + eps)) >= Beta;

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

if strcmp(p.Results.LowResSTFT, "linear")
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
elseif strcmp(p.Results.LowResSTFT, "cqt")
    % CQT of original signal
    [cfs,~,g,fshifts] = cqt(xim2, 'SamplingFrequency', fs, 'BinsPerOctave', 24);
    
    cmag = abs(cfs); % use the magnitude CQT for creating masks

    H2 = movmedian(cmag, LHarmCQT, 2);
    P2 = movmedian(cmag, LPercCQT, 1);
    
    Mp2 = (P2 ./ (H2 + eps)) >= Beta;
    
    % recover the complex STFT H and P from S using the masks
    %H = Mh .* cfs;
    P2 = Mp2 .* cfs;

    % finally istft to convert back to audio
    %xh = icqt(H, g, fshifts);
    xp2 = icqt(P2, g, fshifts);
elseif strcmp(p.Results.LowResSTFT, "warped")
    lambda = -barkwarp(fs);
    
    xim2Warped = longchain(xim2, size(xim2, 1), lambda);
    display(size(xim2Warped));

    % STFT parameters
    winLen2 = WindowSizeP;
    fftLen2 = winLen2 * 2;
    overlapLen2 = winLen2 / 2;
    win2 = sqrt(hann(winLen2, "periodic"));
    
    % STFT of original signal, on a warped frequency scale
    SW2 = stft(xim2Warped, "Window", win2, "OverlapLength", overlapLen2, ...
      "FFTLength", fftLen2, "Centered", true);

    halfIdx2 = 1:ceil(size(SW2, 1) / 2); % only half the STFT matters
    Shalf2 = SW2(halfIdx2, :);
    Smag2 = abs(Shalf2); % use the magnitude STFT for creating masks

    % median filters
    H2 = movmedian(Smag2, LHarmCQT, 2);
    P2 = movmedian(Smag2, LPercCQT, 1);

    % binary masks with separation factor, Driedger et al. 2014
    Mp2 = (P2 ./ (H2 + eps)) >= Beta;

    % recover the complex STFT H and P from S using the masks
    P2 = Mp2 .* Shalf2;

    % we previously dropped the redundant second half of the fft
    P2 = cat(1, P2, flipud(conj(P2)));

    % finally istft to convert back to audio
    % but this is still warped. last thing to do is unwarp it
    xp2Warped = istft(P2, "Window", win2, "OverlapLength", overlapLen2,...
      "FFTLength", fftLen2, "ConjugateSymmetric", true);
  
    xp2 = longchain(xp2Warped, 1024, -lambda);
end

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname, "_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.outDir, prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.outDir, prefix);

if size(xh1, 1) < size(x, 1)
    xh1 = [xh1; x(size(xh1, 1)+1:size(x, 1))];
end

if size(xp2, 1) < size(x, 1)
    xp2 = [xp2; x(size(xp2, 1)+1:size(x, 1))];
end

audiowrite(xhOut, xh1, fs);
audiowrite(xpOut, xp2, fs);
end
