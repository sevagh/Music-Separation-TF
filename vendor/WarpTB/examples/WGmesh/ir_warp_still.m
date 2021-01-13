% This script produces Figs. 26-27 of 
% A. Härmä, M. Karjalainen, L. Savioja, V. Välimäki, U. K. Laine, and
% J. Huopaniemi, 'Frequency-Warped Signal Processing for Audio
% Applications', J. Aud. Eng. Soc., November 2000.

load impulse_response_animation;

len=length(tscale);
dur=max(tscale);

maxy=0.025;
miny=-maxy;
min_delay=30;
max_delay=60;
max_frq=0.22;

lambda=-0.25;

FFT_POINTS=512;
fscale=linspace(0,0.5,FFT_POINTS);

h=figure(1);
clf;

fs=12;
xpos=0.68;

subplot(3,1,1);
ph=plot(tscale, ideal_response, 'k');
hold on;
text(xpos,0.01,'Ideal response','FontSize',fs);
set(gca,'FontSize',fs);
axis([0 dur miny maxy]);

subplot(3,1,2);
ph=plot(tscale, simulation_result, 'k');
ylabel('AMPLITUDE','FontSize',fs);
text(xpos,0.01,'Simulation result','FontSize',fs);
set(gca,'FontSize',fs);
axis([0 dur miny maxy]);

D=(1-lambda)/(1+lambda);
warped=warp_impres(simulation_result, lambda, len-1);
resampwarped=resample(warped, 1024, round(D*1024));

subplot(3,1,3);
ph=plot(tscale(1:length(resampwarped)), resampwarped, 'k');
xlabel('TIME [ms]','FontSize',fs);
tt=['Warped \lambda = ' num2str(lambda,'%1.3f')];
text(xpos,0.01,tt,'FontSize',fs);
set(gca,'FontSize',fs);
axis([0 dur miny maxy]);

% print -deps2 warp_ir.eps

h=figure(2);
clf;

xpos=0.07;
ypos=50;

subplot(3,1,1);
ph=plot(fscale, grpdelay(ideal_response, 1, FFT_POINTS), 'k');
text(xpos,ypos,'Ideal response','FontSize',fs);
set(gca,'FontSize',fs);
axis([0 max_frq min_delay max_delay]);

subplot(3,1,2);
ph=plot(fscale, grpdelay(simulation_result, 1, FFT_POINTS), 'k');
text(xpos,ypos,'Simulation result','FontSize',fs);
ylabel('GROUP DELAY [samples]','FontSize',fs);
set(gca,'FontSize',fs);
axis([0 max_frq min_delay max_delay]);


subplot(3,1,3);
ph=plot(fscale, grpdelay(resampwarped, 1, FFT_POINTS), 'k');
xlabel('NORMALIZED FREQUENCY','FontSize',fs);
tt=['Warped \lambda = ' num2str(lambda,'%1.3f')];
text(xpos,ypos,tt,'FontSize',fs);
set(gca,'FontSize',fs);
axis([0 max_frq min_delay max_delay]);
  
% print -deps2 warp_ir_grpdelay.eps
