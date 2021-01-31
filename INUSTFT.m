function [x] = INUSTFT()

win = sqrt(hann(nwin, "periodic"));

while eof == 0
    % take X from tip of STFT
    X = fft(x.*win, nfft); Xhalf = X(1:(nfft/2)); % FFT current frame

    xw = real(ifft(X, nfft));

    % Weighted-OLA with previous hop samples
    % by slice index
    x = x + xw(1:(nfft/2)).*nfft/sum(win.*win);

    totalTime = totalTime + toc;
    iters = iters + 1;
end