function delay = Gfb_Delay_clear_state(delay)
% delay = Gfb_Delay_clear_state(delay)
%
% Gfb_Delay_clear_state returns a copy of delay with cleared delay lines.
%
% PARAMETER:
% delay    A Gfb_Delay structure as returned by Gfb_Delay_new.  The returned
%          copy will have cleared delay lines
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006

% filename : Gfb_Delay_clear_state.m


delay.memory = zeros(size(delay.memory));


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
