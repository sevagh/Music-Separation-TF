function ERBscale = Gfb_hz2erbscale(Hz)
% ERBscale = Gfb_hz2erbscale(Hz)
% 
% implements equation (16) of [Hohmann 2002]:  computes an ERBscale
% value from a frequency in Hz
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006

% filename : Gfb_hz2erbscale.m


global GFB_L;
global GFB_Q;
Gfb_set_constants;

ERBscale = GFB_Q * log(1 + Hz / (GFB_L * GFB_Q));



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
