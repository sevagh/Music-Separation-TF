function mixer = Gfb_Mixer_new(analyzer, delay, iterations)
% mixer = Gfb_Mixer_new(analyzer, delay, iterations)
% 
% Gfb_Mixer_new creates a Gfb_Mixer object with gain factors suitable
% to calculate a weighted sum of the bands present in the output of the
% given delay.  The gain factors are computed using a numerical optimization
% method described in [Herzke & Hohmann 2007].
% The <iterations> argument may be omitted.
%
% PARAMETERS
% analyzer   A Gfb_Analyzer structure as created by Gfb_Analyzer_new. The
%            mixer created by this function can act as part of a synthesizer
%            that resynthesizes the output of this analyzer
% delay      A Gfb_Delay structure as created by Gfb_Delay_new, Together with
%            the mixer created by this function, this delay can form a
%            synthesizer that resynthesizes the output of the analyzer
% iterations The gain factors are approximated numerically in iterations.
%            If this parameter is omitted, then the number of iterations will
%            be  GFB_GAINCALC_ITERATIONS (see Gfb_set_constants.m, usually
%            =100)
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2003, Mar & Nov 2006, Jan Feb 2007

% filename : Gfb_Mixer_new.m


global GFB_GAINCALC_ITERATIONS;
Gfb_set_constants;

mixer.type           = 'Gfb_Mixer';
center_frequencies   = analyzer.center_frequencies_hz;
number_of_bands   = length(center_frequencies);
sampling_frequency   = analyzer.sampling_frequency_hz;


% The center frequencies in the z plain
z_c = exp(2i * pi * center_frequencies(:) / sampling_frequency);

mixer.gains          = ones(number_of_bands, 1);

% compute the frequency response of each filter (col) at the center
% frequencies of all filters (row)
  pos_f_response = ...
    Gfb_Analyzer_zresponse(analyzer, z_c);
  neg_f_response = ...
    Gfb_Analyzer_zresponse(analyzer, conj(z_c));

% apply delay and phase correction
for band = [1:number_of_bands]
  pos_f_response(:,band) = pos_f_response(:,band) * ...
    delay.phase_factors(band) .* ...
    z_c .^ -delay.delays_samples(band);
  neg_f_response(:,band) = neg_f_response(:,band) * ...
    delay.phase_factors(band) .* ...
    conj(z_c) .^ -delay.delays_samples(band);
end

% combine responses at positive and negative responses to yield
% responses for real part.
f_response = (pos_f_response + conj(neg_f_response)) / 2;

if (nargin < 4)
  iterations = GFB_GAINCALC_ITERATIONS;
end
for i = [1:iterations]
  % add selected spectrum of all bands with gain factors
  selected_spectrum = f_response * mixer.gains;

  % calculate better gain factors from result
  mixer.gains = mixer.gains ./ abs(selected_spectrum);
end
mixer.gains = mixer.gains.';


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
