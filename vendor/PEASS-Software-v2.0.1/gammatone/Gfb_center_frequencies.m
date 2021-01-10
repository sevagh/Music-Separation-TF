function center_frequencies_hz =                            ...
      Gfb_center_frequencies(filters_per_ERBaud,            ...
			     lower_cutoff_frequency_hz,     ...
			     specified_center_frequency_hz, ...
			     upper_cutoff_frequency_hz)
% function frequencies_hz =                                   ...
%       Gfb_center_frequencies(frequencies_per_ERBaud,        ...
%                              lower_cutoff_frequency_hz,     ...
%                              specified_center_frequency_hz, ...
%                              upper_cutoff_frequency_hz)
% 
% constructs a vector of frequencies that are equidistand on the ERB
% scale.
% PARAMETERS:
% frequencies_per_ERBaud     The density of frequencies on the ERB scale.
% lower_cutoff_frequency_hz  The lowest possible frequency.
% specified_center_frequency_hz       ( == "base frequency")
%                            The result vector will contain this exact
%                            frequency. Must be >= lower_cutoff_frequency_hz
% upper_cutoff_frequency_hz  The highest possible frequency. Must be >=
%                            specified_center_frequency_hz
% OUTPUT:
% frequencies_hz             A vector containing frequencies between
%                            lower_cutoff_frequency_hz and
%                            upper_cutoff_frequency_hz, equally
%                            distributed on the ERB scale with a distance
%                            of (1 / frequencies_per_ERBaud) ERB, with
%                            one of the frequencies being
%                            specified_center_frequency_hz.
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan, Sep 2003, Nov 2006, Feb 2007

% filename : Gfb_center_frequencies.m

if (nargin < 4)
  upper_cutoff_frequency_hz = specified_center_frequency_hz;
end

% Calculate the values of the parameter frequencies on the ERBscale:
lower_cutoff_frequency_erb     = ...
    Gfb_hz2erbscale(lower_cutoff_frequency_hz);
specified_center_frequency_erb = ...
    Gfb_hz2erbscale(specified_center_frequency_hz);
upper_cutoff_frequency_erb     = ...
    Gfb_hz2erbscale(upper_cutoff_frequency_hz);


% The center frequencies of the individual filters are equally
% distributed on the ERBscale.  Distance between adjacent filters'
% center frequencies is 1/filters_per_ERBaud.
% First, we compute how many filters are to be placed at center
% frequencies below the base frequency:
erbs_below_base_frequency = ...
    specified_center_frequency_erb - lower_cutoff_frequency_erb;
num_of_filters_below_base_freq = ...
    floor(erbs_below_base_frequency * filters_per_ERBaud);

% Knowing this number of filters with center frequencies below the
% base frequency, we can easily compute the center frequency of the
% gammatone filter with the lowest center frequency:
start_frequency_erb = ...
    specified_center_frequency_erb - ...
    num_of_filters_below_base_freq / filters_per_ERBaud;

% Now we create a vector of the equally distributed ERBscale center
% frequency values:
center_frequencies_erb = ...
    [start_frequency_erb:(1/filters_per_ERBaud):upper_cutoff_frequency_erb];
center_frequencies_hz = Gfb_erbscale2hz(center_frequencies_erb);

%%-----------------------------------------------------------------------------
%%
%%   Copyright (C) 2003 2006 2007 AG Medizinische Physik,
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
