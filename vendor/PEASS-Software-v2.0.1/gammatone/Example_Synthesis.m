% This Example demonstrates how to create and how to use the combined
% analysis-synthesis Filterbank system.
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan, Mar 2002, Nov 2003, Nov 2006


%%% First, create a filterbank analyzer as in Example_Filterbank.m %%%

lower_cutoff_frequency_hz =    70;
upper_cutoff_frequency_hz =  6700;
base_frequency_hz         =  1000;
sampling_rate_hz          = 16276;
filters_per_ERB           =     1.0;
desired_delay_in_seconds  =     0.004;
filter_order              =     4;
bandwidth_factor          =     1.0;

disp(['Building analysis filterbank']);
analyzer = Gfb_Analyzer_new(sampling_rate_hz, lower_cutoff_frequency_hz, ...
                            base_frequency_hz, upper_cutoff_frequency_hz,...
			    filters_per_ERB, filter_order, bandwidth_factor);


%%% Now create a synthesizer that can resynthesize the analyzer's output %%%

disp(['Building synthesizer for an analysis-synthesis delay of ', ...
      num2str(desired_delay_in_seconds), ' seconds']);
synthesizer = Gfb_Synthesizer_new(analyzer, desired_delay_in_seconds);

%%% Extract the synthesizer's parameters %%%
disp(['The synthesizers parameters:';...
      '----------------------------']);
delay = synthesizer.delay;
mixer = synthesizer.mixer;

bands = length(mixer.gains);

fprintf(1,'%3s|%7s | %22s | %5s\n\n', ...
        '# ', 'delay ', 'phase factor    ', 'gain / dB');

for band = 1:bands
  fprintf(1,'%3d|%7d | %9f + %9fi | %5.2f\n', ...
	  band,                            ...
	  delay.delays_samples(band),      ...
	  real(delay.phase_factors(band)), ...
	  imag(delay.phase_factors(band)), ...
	  20*log10(mixer.gains(band)));
end

%%%  plot the resynthesized impulse and the frequency response of the  %%%
%%%  analysis-synthesis system                                         %%%

impulse = [1, zeros(1,8191)];                                          
[analyzed_impulse, analyzer] = Gfb_Analyzer_process(analyzer, impulse);
[resynthesized_impulse, synthesizer] = ...
    Gfb_Synthesizer_process(synthesizer, analyzed_impulse);

Gfb_plot(1, [40/sampling_rate_hz*1e3, 120/sampling_rate_hz*1e3, -1, 1],...
         'impulse response of the analysis-synthesis system',          ...
         'time / ms', 'system output',                                 ...
         [0:8191]/sampling_rate_hz*1e3, resynthesized_impulse);

frequency = [0:8191] * sampling_rate_hz / 8192;                        
Gfb_plot(2, [0, sampling_rate_hz/2, -40, 5],                    ...
	 'frequency response of the analysis-synthesis-system', ...
	 'frequency / Hz', 'system response level / dB',        ...
	 frequency, 20 * log10(abs(fft(resynthesized_impulse'))));

disp('Figure 1 shows the impulse response of the analysis-synthesis system');
disp('in the time domain; figure 2 shows its frequency response.');

%%-----------------------------------------------------------------------------
%%
%%   Copyright (C) 2002 2003 2006 AG Medizinische Physik,
%%                        Universitaet Oldenburg, Germany
%%                        http://www.physik.uni-oldenburg.de/docs/medi
%%
%%   Permission to use, copy, and distribute this software/file and its
%%   documentation for any purpose without permission by UNIVERSITAET OLDENBURG
%%   is not granted.
%%   
%%   Permission to use this software for academic purposes is generally
%%   granted.
%%
%%   Permission to modify the software is granted, but not the right to
%%   distribute the modified code.
%%
%%   This software is provided "as is" without expressed or implied warranty.
%%
%%   Author: Tobias Herzke
%%
%%-----------------------------------------------------------------------------
