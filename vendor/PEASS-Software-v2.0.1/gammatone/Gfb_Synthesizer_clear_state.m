function synthesizer = Gfb_Synthesizer_clear_state(synthesizer)
% synthesizer = Gfb_Synthesizer_clear_state(synthesizer)
%
% Gfb_Synthesizer_clear_state returns a copy of the synthesizer argument with
% a cleared state. (The delay lines will be cleared)
%
% PARAMETER
% synthesizer  A Gfb_Synthesizer structure as returned by Gfb_Synthesizer_new
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006

% filename : Gfb_Synthesizer_clear_state.m


synthesizer.delay = Gfb_Delay_clear_state(synthesizer.delay);


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
