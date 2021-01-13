%
% 26.1.2000 Lauri Savioja
%
% The propagation of an impulse in an ideal membrane was simulated
% using the interpolated digital waveguide mesh.
% The result is dispersed such that high frequencies are 
% remarkably delayed. This animation shows the impulse response
% and the group delay with various values of warping factor.
%

load impulse_response_animation;

len=length(tscale);
dur=max(tscale);

maxy=0.025;
miny=-maxy;
min_delay=30;
max_delay=60;
max_frq=0.23;

FRAMES=100;
max_lambda=-0.25;
lambdas=linspace(0,max_lambda,FRAMES);

FFT_POINTS=512;
fscale=linspace(0,0.5,FFT_POINTS);

h=figure;
clf;

fs=12;
xpos=0.68;

subplot(3,2,1);
ph=plot(tscale, ideal_response, 'k');
hold on;
text(xpos,0.01,'Ideal response','FontSize',fs);
set(gca,'FontSize',fs);
axis([0 dur miny maxy]);

subplot(3,2,2);
ph=plot(fscale, grpdelay(ideal_response, 1, FFT_POINTS), 'k');
set(gca,'FontSize',fs);
axis([0 max_frq min_delay max_delay]);

subplot(3,2,3);
ph=plot(tscale, simulation_result, 'b');
ylabel('Amplitude','FontSize',fs);
text(xpos,0.01,'Simulation result','FontSize',fs);
set(gca,'FontSize',fs);
axis([0 dur miny maxy]);

subplot(3,2,4);
ph=plot(fscale, grpdelay(simulation_result, 1, FFT_POINTS), 'b');
ylabel('Group delay [samples]','FontSize',fs);
set(gca,'FontSize',fs);
axis([0 max_frq min_delay max_delay]);

for i=1:FRAMES

  lambda=lambdas(i);
  D=(1-lambda)/(1+lambda);
  warped=warp_impres(simulation_result, lambda, len-1);
  resampwarped=resample(warped, 1024, round(D*1024));

  subplot(3,2,5);
  ph=plot(tscale(1:length(resampwarped)), resampwarped, 'r');
  xlabel('Time [ms]','FontSize',fs);
  tt=['Warped \lambda = ' num2str(lambda,'%1.3f')];
  text(xpos,0.01,tt,'FontSize',fs);
  set(gca,'FontSize',fs);
  axis([0 dur miny maxy]);

  subplot(3,2,6);
  ph=plot(fscale, grpdelay(resampwarped, 1, FFT_POINTS), 'r');
  xlabel('Normalized frequency','FontSize',fs);
  set(gca,'FontSize',fs);
  axis([0 max_frq min_delay max_delay]);
  
  xx=getframe;

end  

% set(ph,'LineWidth',2);
