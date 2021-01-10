function filter = Gfb_Filter_clear_state(filter)
% filter = Gfb_Filter_clear_state(filter)
% 
% returns a copy of the filter, with the filter state cleared.
%
% PARAMETER:
% filter  a Gfb_Filter structure as returned by Gfb_Filter_new.  A copy
%         of the filter is returned, with the filter state cleared
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006

% filename : Gfb_Filter_clear_state.m


filter.state = zeros(1, filter.gamma_order);


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
