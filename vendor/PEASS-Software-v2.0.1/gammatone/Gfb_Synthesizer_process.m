function [output, synthesizer] = Gfb_Synthesizer_process(synthesizer, input)
% [output, synthesizer] = Gfb_Synthesizer_process(synthesizer, input)
%
% The synthesizer will resynthesize the given input.
%
% PARAMETERS:
% synthesizer  A synthesizer structure as created by Gfb_Synthesizer_new. A
%              copy of the synthesizer object with an updated internal state
%              is returned in the second return parameter
% input        A matrix containing the (possibly processed) complex output of
%              the analyzer corresponding to this synthesizer.  The number of
%              rows in input must match the number of filter bands
% output       The synthesized output signal
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006

% filename : Gfb_Synthesizer_process.m


[output, synthesizer.delay] = Gfb_Delay_process(synthesizer.delay, input);
[output, synthesizer.mixer] = Gfb_Mixer_process(synthesizer.mixer, output);


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
