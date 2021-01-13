function wlpdemo2()
% This script produces Fig. 19 of 
% A. Härmä, M. Karjalainen, L. Savioja, V. Välimäki, U. K. Laine, and
% J. Huopaniemi, 'Frequency-Warped Signal Processing for Audio
% Applications', J. Aud. Eng. Soc., November 2000.

%
% This is just one way to do this. 
%

load seq2.mat;

a=lpc(S.*hanning(1024),37);
wa=wlpc(S.*hanning(1024),37,0.723);
%wa=wlpc(S,0.723,40);

f=1024*abs(dct(S.*hanning(1024))).^2; % Power spectrum

% non-warped spectral estimates
ffa=freqz(1,a,1024);ffa=abs(ffa).^2;
ee=wfilter(1,wa,imp(1800),0.723); 
ffwa=freqz(fadeout(ee,200),1,1024);ffwa=abs(ffwa).^2;   

% warped spectral estimates
ww=longchain(sig(9000:12000),1023,0.723);
wf=1024*abs(dct(ww'.*hanning(1024))).^2;
wffwa=freqz(1,wa,1024);wffwa=abs(wffwa).^2;
ee=wfilter(1,a,imp(1600),-0.723); 
wffa=freqz(ee,1,1024);wffa=abs(wffa).^2;   

% Figures
x=linspace(0,22.50,1024);
subplot(2,1,1),plot(x,20*log10([f ffa ffwa]));axis([0 22 -150 150]);
xlabel('Frequency [kHz]');ylabel('Magnitude [dB]');
text(10,5,'LP estimate');text(10,-30,'WLP estimate');
text(10,-80,'Power spectrum');

subplot(2,1,2),ss=Hertz2Bartz([0 5000 10000 15000 20000],44100);
x=linspace(0,22.50,1024);
plot(x,20*log10([wf wffa wffwa]));axis([0 22 -150 150]);
xlabel('Frequency [kHz]');ylabel('Magnitude [dB]');
text(8.5,115,'LP estimate');text(4,90,'WLP estimate');
text(5,-128,'Power spectrum');set(gca,'Xticklabel',round(ss/100)/10);

%%%%%%%%
% Additional functions
function ret=imp(len,pos,bip)
%
% 	ret=imp(LEN,POS)
%	This function creates a signal of length LEN with
%	impulses at positions given by vector POS. If POS is not
%	given signal is of type: 1 0 0 0 0 0 ...
%
if nargin<2, pos=1; end;
ret=zeros(1,len);

if nargin==3, ret(pos)=ones(1,length(pos));ret(pos+1)=-ones(1,length(pos));
else ret(pos)=ones(1,length(pos));end
%%%%%%%%%%
function bz=Hertz2Bartz(hz,fs)
%
% bz=Hertz2Bartz(hz,fs)
%

lam=-barkwarp(fs);

%bz=atan((1-lam^2)*sin(hz)./((1+lam^2)*cos(hz)-2*lam));

bz=-(fs/(j*2*pi))*log((exp(-j*2*pi*hz/fs) - lam)./(1-exp(-j*2*pi*hz/fs)*lam));
bz=real(bz);
%%
function ret=fadeout(S,len)
%
%	ret=fadeout(S,len)
%
S=S(:);
l=length(S);
ret=[S(1:l-len); S(l-len+1:l).*linspace(1,0,len)'];
%ret=[S(1:len).*linspace(0,1,len)' ;S(len+1:l)];



