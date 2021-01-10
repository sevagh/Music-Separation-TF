% This file defines global constants for the matlab gammatone filterbank
% implementation.
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006

% filename : Gfb_set_constants

global GFB_L GFB_Q GFB_PREFERED_GAMMA_ORDER GFB_GAINCALC_ITERATIONS;

GFB_L = 24.7;  % see equation (17) in [Hohmann 2002]
GFB_Q = 9.265; % see equation (17) in [Hohmann 2002]

% We will use 4th order gammatone filters:
GFB_PREFERED_GAMMA_ORDER = 4;

% The gain factors are approximated in iterations. This is the default
% number of iterations:
GFB_GAINCALC_ITERATIONS  = 100;

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
