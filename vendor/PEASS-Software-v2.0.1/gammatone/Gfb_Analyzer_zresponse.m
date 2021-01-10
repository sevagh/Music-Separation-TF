function zresponse = Gfb_Analyzer_zresponse(analyzer, z)
% zresponse = Gfb_Analyzer_zresponse(analyzer, z)
%
% Computes the frequency response of the gammatone filters in the filterbank
% at the frequencies z.
% 
% PARAMETERS
% analyzer  A Gfb_Analyzer struct as created by Gfb_Analyzer_new.
% z         A vector of z-plane frequencies where the frequency response
%           should be computed. z = exp(2i*pi*f[Hz]/fs[Hz])
% zresponse The complex frequency response of the filter (col) at z (row).
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan & Nov 2006, Jan Feb 2007

number_of_bands = length(analyzer.center_frequencies_hz);
z = z(:);
zresponse = ones(length(z), number_of_bands);

for band = [1:number_of_bands]
  filter = analyzer.filters(band);
  zresponse(:,band) = Gfb_Filter_zresponse(filter, z);
end

%%-----------------------------------------------------------------------------
%%
%%   Copyright (C) 2006 2007  AG Medizinische Physik,
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
