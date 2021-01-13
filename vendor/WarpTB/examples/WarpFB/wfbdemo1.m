function wfbdemo1()
% WFBDEMO1 - This script demonstrates the use of a frequency-warped
% FFT introduced in Fig. 16 of 
% A. Härmä, M. Karjalainen, L. Savioja, V. Välimäki, U. K. Laine, and
% J. Huopaniemi, 'Frequency-Warped Signal Processing for Audio
% Applications', J. Aud. Eng. Soc., November 2000.

load seq2;

N=128;% Number of channels
lam=0.7; % value of the warping coefficient

O=zeros(1024,N);
O(:,1)=S;
for q=2:N,
  S=ap_delay(S,lam);
  O(:,q)=S;
end

subplot(2,1,1),imagesc(O');axis('xy');xlabel('Time [samples]');
title('Outputs of a 128 element AP-chain');

F=dct(O');

subplot(2,1,2),imagesc(F);axis('xy');title('Warped spectrogram');
xlabel('Time [samples]');ylabel('Warped frequency bins');
