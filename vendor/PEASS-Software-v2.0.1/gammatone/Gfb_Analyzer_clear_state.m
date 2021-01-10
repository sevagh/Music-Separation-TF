function analyzer = Gfb_Analyzer_clear_state(analyzer)
% analyzer = Gfb_Analyzer_clear_state(analyzer)
%
% method for resetting the filter states to zeros
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006, Feb 2007

% filename : Gfb_Analyzer_clear_state.m

  for band = [1:length(analyzer.center_frequencies_hz)]
    analyzer.filters(1, band) = ...
	Gfb_Filter_clear_state(analyzer.filters(1, band));
  end



%%-----------------------------------------------------------------------------
%%
%%   Copyright (C) 2002 2006 2007 AG Medizinische Physik,
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
