function [S] = NUSTFT(x, nwin, nhop, nfft)

addpath(genpath('vendor/finufft/matlab'));

win = sqrt(hann(nwin, "periodic"));

xlen = size(x, 1);
nhops = floor(xlen/nhop);

xlen = nhops*nhop;

x = x(1:xlen);
S = zeros(nfft, nhops);

for i = 1:nhops
    start = 1+(i-1)*nhop;
    display(start);
    
    xwin = x(start:start+nwin-1).*win;
    display(start+nwin);
    
    f = 1:nfft;
    
    X = chebfun.nufft(xwin);
    X2 = fft(xwin);

    S(:, i) = X;
end