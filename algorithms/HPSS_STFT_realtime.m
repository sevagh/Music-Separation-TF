function HPSS_STFT_realtime(filename, varargin)
p = inputParser;

defaultMask = 'hard';
validMasks = {'soft', 'hard'};
checkMask = @(x) any(validatestring(x, validMasks));

defaultOutDir = '.';

Beta = 2;
Power = 2;

LHarm = 17;
LPerc = 17;

addRequired(p, 'filename', @ischar);
addOptional(p, 'OutDir', defaultOutDir, @ischar);
addParameter(p, 'Mask', defaultMask, checkMask);

parse(p, filename, varargin{:});

nfft = 2048;
nwin = 1024;
hop = 512;

mixIn = dsp.AudioFileReader(p.Results.filename,'SamplesPerFrame',hop);
fs = mixIn.SampleRate;

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname,"_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.OutDir, prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.OutDir, prefix);

harmOut = dsp.AudioFileWriter(xhOut,'FileFormat','WAV','SampleRate',fs);
percOut = dsp.AudioFileWriter(xpOut,'FileFormat','WAV','SampleRate',fs);

win = sqrt(hann(nwin, "periodic"));

STFT = zeros(nfft, ceil(LHarm/2));  % preallocate the sliding stft

% nwin-framed ringbuffers to store input and output
x = zeros(nwin, 1);
xh = x;
xp = x;

eof = 0;
totalTime = 0;
iters = 0;

while eof == 0
    [nextHop, eof] = mixIn();

    tic
    x = vertcat(x(hop+1:nwin), nextHop); % append latest hop samples
    X = fft(x.*win, nfft);
    Xhalf = X(1:(nfft/2)); % FFT current frame

    STFT = STFT(:, 2:size(STFT, 2)); % remove oldest stft frame 
    STFT(:, size(STFT, 2)+1) = X; % append latest frame

    Smag = abs(STFT(1:(nfft/2), :));  % median filter and binary mask
    H = movmedian(Smag, LHarm, 2);
    P = movmedian(Smag, LPerc, 1);    
    
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

    % recover h and p from the half FFT using masks + IFFT
    H = Mh(:, size(Mh, 2)).*Xhalf;
    H = cat(1, H, flipud(conj(H)));
    
    P = Mp(:, size(Mp, 2)).*Xhalf;
    P = cat(1, P, flipud(conj(P)));
    
    xhw = real(ifft(H, nfft));
    xpw = real(ifft(P, nfft));

    % Weighted-OLA with previous hop samples
    xh = xh + xhw(1:(nfft/2)).*nfft/sum(win.*win);
    xp = xp + xpw(1:(nfft/2)).*nfft/sum(win.*win);

    % first hop samples are finalized after the previous OLA
    percOut(xp(1:hop)); % write percussion stream in real-time
    harmOut(xh(1:hop)); % write harmonic stream in real-time

    % shift for future weighted OLA
    xh = vertcat(xh(hop+1:nwin), zeros(hop, 1));
    xp = vertcat(xp(hop+1:nwin), zeros(hop, 1));

    totalTime = totalTime + toc;
    iters = iters + 1;
end
totalTime = totalTime/iters;

fprintf("time per loop iter: %f\n", totalTime);
release(percOut);
release(harmOut);
release(mixIn);

[x, ~] = audioread(p.Results.filename);
[xh, ~] = audioread(xhOut);
[xp, ~] = audioread(xpOut);

% adjust lengths
if size(xh, 1) > size(x, 1)
    xh = xh(1:size(x, 1));
    xp = xp(1:size(x, 1));
end

audiowrite(xhOut, xh, fs);
audiowrite(xpOut, xp, fs);

end