function zresponse = Gfb_Filter_zresponse(filter, z)
% zresponse = Gfb_Filter_zresponse(filter, z)
%
% Computes the frequency response of the gammatone filter at the frequency z.
% 
% PARAMETERS
% filter  A Gfb_Filter struct as created by Gfb_Filter_new.
% z       A vector of z-plane frequencies where the frequency response should
%         be computed. z = exp(2i*pi*f[Hz]/fs[Hz])
% zresponse The complex response of the filter at z.
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan & Nov 2006

zresponse = (1 - filter.coefficient ./ z) .^ -filter.gamma_order * ...
    filter.normalization_factor;

%%-----------------------------------------------------------------------------
%%
%%   Copyright (C) 2006   AG Medizinische Physik,
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
