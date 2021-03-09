[x, fs] = gspi();

wintype = 'hann';
winsize1 = 4096;
a1 = 512;
M1 = 4096;
winsize2 = 512;
a2 = 64;
M2 = 512;

% windows
g1 = {wintype,winsize1};
g2 = {wintype,winsize2};

tonal = dgtreal(x,g1,a1,M1);
transient = dgtreal(x,g2,a2,M2);

figure;
plotdgtreal(tonal, a1, M1);
title('Tonal system, real DGT, Hann 4096');

figure;
plotdgtreal(transient, a2, M2);
title('Transient system, real DGT, Hann 256');



F1=wmdct(x, {'gauss'},256);
F2=wmdct(x, {'gauss'},32);

figure;
plotwmdct(F1,fs,90);
title('Tonal system, WMDCT, Gaussian 256');

figure;
plotwmdct(F2,fs,90);
title('Transient system, WMDCT, Gaussian 32');
