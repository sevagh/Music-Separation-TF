function synthesizer = Gfb_Synthesizer_new(analyzer, desired_delay_in_seconds)
% synthesizer = Gfb_Synthesizer_new(analyzer, desired_delay_in_seconds)
%
% Gfb_Synthesizer_new creates a new synthesizer object that fits to the
% given analyzer.
%
% PARAMETERS:
% analyzer                  an analyzer struct as returned by Gfb_Analyzer_new
% desired_delay_in_seconds  the desired group delay of the analysis-synthesis
%                           system in seconds.  Greater delays result in better
%                           output signal quality.  Minimum delay is
%                           (1 / analyzer.sampling_frequency_hz)
% synthesizer               the constructed Gfb_Synthesizer structure
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2003, Nov 2006, Jan 2007

% filename : Gfb_Synthesizer_new.m


synthesizer.type         = 'Gfb_Synthesizer';
desired_delay_in_samples = round(desired_delay_in_seconds * ...
			         analyzer.sampling_frequency_hz);
if (desired_delay_in_samples < 1)
    error('delay must be at least 1/analyzer.sampling_frequency_hz');
end

synthesizer.delay = Gfb_Delay_new(analyzer, desired_delay_in_samples);
synthesizer.mixer = Gfb_Mixer_new(analyzer, synthesizer.delay);


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
