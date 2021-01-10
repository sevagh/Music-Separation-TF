function Hz = Gfb_erbscale2hz(ERBscale)
% Hz = Gfb_erbscale2hz(ERBscale)
% 
% implements equation (17) of [Hohmann 2002]: computes a frequency
% in Hz from its value on the ERBscale
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006

% filename : Gfb_set_erbscale2hz.m


global GFB_L;
global GFB_Q;
Gfb_set_constants;

Hz = (exp(ERBscale / GFB_Q) - 1) * (GFB_L * GFB_Q);


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
