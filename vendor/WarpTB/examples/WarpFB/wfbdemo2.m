function wfbdemo2()
% WFBDEMO1 - This script demonstrates the design of warped IIR filterbanks
% introduced in Fig. 17 of 
% A. Härmä, M. Karjalainen, L. Savioja, V. Välimäki, U. K. Laine, and
% J. Huopaniemi, 'Frequency-Warped Signal Processing for Audio
% Applications', J. Aud. Eng. Soc., November 2000.

N=24;% Number of channels
lam=barkwarp(32000); % value of the warping coefficient at 32 kHz 
                     % sampling rate
		     
str1=char('Let us design a filterbank of 23 uniformly spaced',...
    'fifth order Butterworth filters (just a minute)',' ');
disp(str1);
		  
bb=linspace(0.01,0.99,24); % Band borders on the Bark scale
A=zeros(N,5);B=zeros(N,5);
F=[];WF=[];
warning off
for q=1:N-1,
  [a,b]=butter(2,[bb(q) bb(q+1)]);% Compute a filter
  [wa,wb]=wfilter2wfilter(a,b,lam,0.0); % Bilinear mapping
  
  ff=freqz(a,b,256);F=[F 20*log10(abs(ff))];  
  wf=freqz(wa,wb,256);WF=[WF 20*log10(abs(wf))];
end
disp(char('Ok. Press anything',' '));pause
xx=linspace(0,16,256);
plot(xx,F),axis([0 16 -80 10]);xlabel('Frequency [kHz]');
ylabel('Magnitude [dB]');
str1=char('Figure 1 shows the frequency responses of the filterbank',...
    'If this same filterbank was implemented using warped IIR filters',...
'with warping parameter 0.71 (Bark-approx. at a 32 kHz sampling rate)',...
'we would get (Press Any Key)','  ');
disp(str1);pause
plot(xx,WF),axis([0 16 -80 10]);xlabel('Frequency [kHz]');
ylabel('Magnitude [dB]');title('THIS!');
str1=char('This is a uniform filterbank on the Bark scale. The bandwidth',...
    'of each filter is approximately one Bark',' ');
disp(str1);

