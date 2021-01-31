function [S] = NUSTFT()

win = sqrt(hann(nwin, "periodic"));

S = zeros(nfft, ceil(lHarm/2));  % preallocate the sliding stft

while eof == 0 % loop over real audio signal
    % take slices in hops, no need to vertcat
    x = vertcat(x(hop+1:nwin), nextHop); % append latest hop samples
    
    X = fft(x.*win, nfft); % replace with nufft
    Xhalf = X(1:(nfft/2));

    S(:, size(S, 2)+1) = X; % append latest frame
end