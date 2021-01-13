% BASICDEMO1 - Warping of a signal segment
%
% In this demo, the warping effect is introduced. 
% 
% This script is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples

% Authors: Matti Karjalainen, Aki Härmä
% Helsinki University of Technology, Laboratory of Acoustics and
% Audio Signal Processing


disp('****************************************************');
disp('* Basic Demo 1 -warping effect in an allpass chain *');
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
disp(' 2. The signal is warped by   ');
disp(' feeding it into a chain of 1024 allpass elements.');
disp(' Warping parameter is lambda=0.75. The duration  ');
disp(' of the original signal is 6000 samples.');
echo on;
WS=longchain(S,1024,0.75);echo off;
disp(' 3. Warped signal and warped spectrum are shown in Figure 2');
figure(2);
subplot(2,1,1),plot(WS(1:1024));title('A warped test signal');
axis([0 1024 -1 1]);xlabel('Tap-index of an allpass chain');
subplot(2,1,2),spectrum(WS(1:1024),1024,1,[]);
axis([0 1 10e-10 10e2]);xlabel('Warped frequency');
disp('--------------- press any key to continue ----------');
pause;
disp('----------------------------------------------------');
disp(' WARPING OF A SIGNAL SEGMENT IS NOT USUALLY A USEFUL');
disp(' TECHNIQUE IN ANY APPLICATION BECAUSE THIS EFFECT   ');
disp(' IS SHIFT-VARIANT AND IT LOSES INFORMATION.         ');
disp(' See other demonstrations for techniques where a DSP');
disp(' system, not a signal, is warped.');

close all;


