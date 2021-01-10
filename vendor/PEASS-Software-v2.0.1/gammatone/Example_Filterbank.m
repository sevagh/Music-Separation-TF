% This example program demonstrates how to create and use an analysis
% gammatone filterbank
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan, Mar 2002, Nov 2006

lower_cutoff_frequency_hz = 70;
upper_cutoff_frequency_hz = 6700;
base_frequency_hz = 1000;
sampling_rate_hz = 16276;
filters_per_ERB = 1.0;

disp(['Building a filterbank for ', num2str(sampling_rate_hz), ...
      'Hz sampling frequency.']);
disp(['Lower cutoff frequency: ', num2str(lower_cutoff_frequency_hz), 'Hz']);
disp(['Upper cutoff frequency: ', num2str(upper_cutoff_frequency_hz), 'Hz']);
disp(['Base frequency        : ', num2str(base_frequency_hz), 'Hz']);
disp(['filters per ERB       : ', num2str(filters_per_ERB)]);
disp(' ')
analyzer = Gfb_Analyzer_new(sampling_rate_hz, lower_cutoff_frequency_hz, ...
                            base_frequency_hz, upper_cutoff_frequency_hz,...
			    filters_per_ERB);
bands = length(analyzer.center_frequencies_hz);
disp(['filterbank contains ', num2str(bands), ' filters:']);

fprintf(1,'%3s|%12s |%15s |%16s\n\n', ...
        '# ', 'f / Hz ', 'normalization', 'coefficient');

%% display filter parameters of the individual filters: %%
for band = 1:bands
  filter = analyzer.filters(band);
  fprintf(1,'%3d|%12f |%15e | %f + %fi\n', ...
	  band, analyzer.center_frequencies_hz(band), ...
	  filter.normalization_factor, ...
	  real(filter.coefficient), imag(filter.coefficient));
end


%%% plot the frequency response of the individual filters: %%%         

impulse = [1, zeros(1,8191)];                                          
[impulse_response, analyzer] = Gfb_Analyzer_fprocess(analyzer, impulse);
frequency_response = fft(real(impulse_response)');                     
frequency = [0:8191] * sampling_rate_hz / 8192;                        
Gfb_plot(1, [0, sampling_rate_hz/2, -40, 0], ...
	 'frequency response of the individual filters in this filterbank', ...
	 'frequency / Hz', 'filter response / dB', ...
	 frequency, 20 * log10(abs(frequency_response)));

disp(' ');
disp('Figure 1 shows the frequency response of the individual filters.');


%%-----------------------------------------------------------------------------
%%
%%   Copyright (C) 2002 2006  AG Medizinische Physik,
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
