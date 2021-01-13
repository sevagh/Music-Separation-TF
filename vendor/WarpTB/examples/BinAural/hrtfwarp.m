% HRTFWARP example script for warped HRTF design
% 
% 		Copyright (c) 2000 Jyri Huopaniemi 
%		Nokia Research Center, Speech and Audio Systems Laboratory 
%		P.O.Box 407, FIN-00045 Nokia Group, Finland 
%		e-mail: Jyri.Huopaniemi@nokia.com 
%		Last modification: Jan 31, 2000 
% 
%		Example HRTF: Cortex MKII dummy head, 30deg. azimuth, 
% 0deg. elevation, right ear 
%
% This script produces Fig. 25 of 
% A. Härmä, M. Karjalainen, L. Savioja, V. Välimäki, U. K. Laine, and
% J. Huopaniemi, 'Frequency-Warped Signal Processing for Audio
% Applications', J. Aud. Eng. Soc., November 2000.
%
% This function is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples
 

clf; 
fs=48000; 
lambda=0.65; 
iirord=[20 6]; 
load hrir; 
N=512; 
k=0; 
for i=iirord, 
   k=k+1; 
   % 
   % Original HRTF 
   % 
   [h,f] = freqz(hrir,1,N,fs); 
   % 
   % Design original using Prony's method 
   % 
   [b,a] = prony(hrir,i,i); 
   [hp,f]=freqz(b,a,N,fs); 
   % 
   % Warp and design using Prony's method 
   % 
   %hrir_wp = warpsig(hrir,lambda,N); 
   hrir_wp = warp_impres(hrir,lambda,N); 
   [bw,aw] = prony(hrir_wp,i,i); 
   [buw,auw] = unwarp(bw,aw,-lambda); 
   [hw,f]=freqz(buw,auw,N,fs); 
   % 
   % Plot results 
   % 
   figure(1); 
   subplot(length(iirord),1,k); 
   semilogx(f,20*log10(abs(h))); 
   hold on; 
   semilogx(f,20*log10(abs(hp)),':'); 
   semilogx(f,20*log10(abs(hw)),'--'); 
   axis([50 24000 -40 10]); 
end 
subplot(2,1,1);hold off; set(gca,'FontName','Times','FontSize',14); 
ylabel('Magnitude (dB)'); 
%title('HRTF modeling - solid line: original, dashed line: warped Prony,
%dotted line: linear Prony'); 
title('HRTF modeling example'); 
text(100,-30,'IIR modeling order: 20'); 
subplot(2,1,2);hold off; set(gca,'FontName','Times','FontSize',14); 
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); 
text(100,-30,'IIR modeling order: 6');         


