%
% 26.1.2000 Lauri Savioja
%
% Impulse response of an ideal square membrane was simulated by an interpolated
% digital waveguide mesh. The algorithm suffers from dispersion, which can be
% reduced by frequency warping. In this example a simulated response
% is warped and the magnitude response of the original and warped responses
% are shown. The red vertical lines show the analytical solution for the 
% eigenfrequencies of the membrane.
%
% This script produces Figs. 26-27 of 
% A. Härmä, M. Karjalainen, L. Savioja, V. Välimäki, U. K. Laine, and
% J. Huopaniemi, 'Frequency-Warped Signal Processing for Audio
% Applications', J. Aud. Eng. Soc., November 2000.

load membrane_simulation_data.mat 

lambda=-0.327358;
D=(1-lambda)/(1+lambda);

disp(['Let us warp the impulse response by warping factor ' num2str(lambda)]);

warped_result_tmp=warp_impres(membrane_result,lambda,round(length(membrane_result)*1.2));
warped_result=resample(warped_result_tmp, 1024, round(D*1024));

startfrq=0;
endfrq=0.25;

fs=max(fscale);
normfscale = fscale./fs;

eps=1e-20;

fontsize=16;
tx=0.013;
ty=60;
bot=0;
top=70;

%
% The magnitude response
%

figure(1);
clf;

subplot(2,1,1);
plot(normfscale, db(fft(membrane_result, FFT_POINTS)));
hold on;
for i=1:length(eigs)
    point=(eigs(i,1)/fs);
    plot([point-eps point],[bot top+20],'r--');
end
set(gca,'FontSize',fontsize);
ylabel('MAGNITUDE (dB)');
axis([startfrq endfrq bot top]);
text(tx,ty,'(a)','FontSize',fontsize);

subplot(2,1,2);
plot(normfscale, db(fft(warped_result, FFT_POINTS)));
hold on;
for i=1:length(eigs)
    point=(eigs(i,1)/fs);
    plot([point-eps point],[bot top+20],'r--');
end
set(gca,'FontSize',fontsize);
axis([startfrq endfrq bot top]);
ylabel('MAGNITUDE (dB)');
xlabel('NORMALIZED FREQUENCY');
zoom on;
text(tx,ty,'(b)','FontSize',fontsize);

% print -deps2 membrane_result.eps

%
% The impulse responses
%

figure(2);
clf;
plot(membrane_result);
hold on;
plot(warped_result,'r');


