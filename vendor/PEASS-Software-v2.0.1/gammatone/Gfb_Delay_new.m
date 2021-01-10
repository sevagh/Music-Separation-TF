function delay = Gfb_Delay_new(analyzer, delay_samples)
% delay = Gfb_Delay_new(analyzer, delay_samples)
%
% Gfb_Delay_new creates a new Gfb_Delay object that can act as the first stage
% of a synthsizer that resynthesizes the output of the gammatone filterbank
% analyzer.  The purpose of the delay object is to delay the output of each
% band by a band-dependent ammount of samples, so that the envelope of
% the impulse response of the analyzer is as large as possible at the desired
% delay.
% Additionally, the delay object will multiply this delayed output with a
% band-dependent complex phase factor, so that the real part of the impulse
% response has a local maximum at the desired delay.  Finally, the delay ob-
% ject will output only the real part of each band.
%
% The phase factors are approximated numerically in this constructor,
% using a method described in [Herzke & Hohmann 2007].  The
% approximation assumes parabolic behaviour of the real part of the
% impulse response in the region of the desired local maximum: The phase
% factors are chosen so that the real parts of the impulse response in
% the samples directly preceeding and following the desired local
% maximum will be equal after multiplication with the pase factor.
%
% PARAMETERS:
% analyzer      The Gfb_Analyzer structure as returned by Gfb_Analyzer_new.
% delay_samples The desired group delay in samples. must be at least 1,
%               because of the way the phase factors are computed.  Larger
%               delays lead to better signal quality
% delay         The new Gfb_Delay object
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002; Nov 2003; Mar Jun Nov 2006; Jan Feb 2007

% filename : Gfb_Delay_new.m


delay.type           = 'Gfb_Delay';

  analyzer             = Gfb_Analyzer_clear_state(analyzer);
  impulse              = zeros(1, delay_samples + 2);
  impulse(1)           = 1;

    impulse_response = ...
      Gfb_Analyzer_process(analyzer, impulse);

number_of_bands      = size(impulse_response, 1);

[dummy, max_indices] = max(abs(impulse_response(:,1:(delay_samples+1))).');

delay.delays_samples = delay_samples + 1 - max_indices;

delay.memory         = zeros(number_of_bands, max(delay.delays_samples));

slopes = zeros(1, number_of_bands);
for band = [1:number_of_bands]
  band_max_index = max_indices(band);
  slopes(band) = (impulse_response(band, band_max_index+1) - ...
                  impulse_response(band, band_max_index-1));
end
slopes = slopes ./ abs(slopes);
delay.phase_factors = 1i ./ slopes;


%%-----------------------------------------------------------------------------
%%
%%   Copyright (C) 2002 2003 2006 2007 AG Medizinische Physik,
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
