% WLPDEMO1 - Linear predictive coding
%
% This simple demonstration shows how warped linear predictive
% coding works. 
% 
% This script is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples

% Authors: Matti Karjalainen, Aki Härmä
% Helsinki University of Technology, Laboratory of Acoustics and
% Audio Signal Processing


disp('****************************************************');
disp('* WLP Demo 1 - Warped linear predictive coding   *');
disp('****************************************************');
disp(' ');
disp(' 1. A test signal and its spectrum are shown in Figure 1');
load seq1.mat
figure(1);
subplot(2,1,1),plot(S(1:1024));title('A test signal (seq1.mat)');
axis([0 1024 -1 1]);
subplot(2,1,2),spectrum(S(1:1024),1024,1,[],44100);
axis([0 22050 10e-10 10e2]);
xlabel('Normalized frequency'); ylabel('Magnitude [dB]');
disp('--------------- press any key to continue ----------');
pause;
disp('1. Estimate the coefficients of a 10th order warped ');
disp(' all-pole model using autocorrelation method of WLP');
disp(' and plot frequency response of the obtained model');
echo on;
c=wlpc(S(1:1000),20,0.723);echo off;
freqz(1,c);xlabel('Warped frequency');
disp('--------------- press any key to continue ----------');
pause;
disp('2. Do inverse filtering to produce a residual signal');
disp(' and plot it');
echo on;
res=wfilter(c,1,S,0.723);echo off
plot(res);title('Residual signal');
disp('--------------- press any key to continue ----------');
pause;
disp('3. Perform synthesis by filtering the residual using');
disp('the model and plot.');
echo on;
syn=wfilter(1,c,res,0.723);echo off;
subplot(2,1,1),plot(syn(1:1024));title('Perfect reconstruction')
axis([0 1024 -1 1]);
subplot(2,1,2),spectrum(syn(1:1024),1024,1,[],44100);
axis([0 22050 10e-10 10e2]);
disp('--------------- press any key to continue ----------');
pause;
disp('----------------------------------------------------');
disp(' A more detailed example with frame based processing');
disp(' is going to be available in WLP sub-toolkit of WarpTB');
close all;


