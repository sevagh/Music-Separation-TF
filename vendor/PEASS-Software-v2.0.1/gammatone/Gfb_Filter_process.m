function [output, filter_obj] = Gfb_Filter_process(filter_obj, input)
% [output, filter] = Gfb_Filter_process(filter, input)
%
% The filter processes the input data.
%
% PARAMETERS
% filter  A Gfb_Filter struct created from Gfb_Filter_new.  The filter
%         will be returned with an updated filter state as the second
%         return parameter
% input   A vector containing the input signal to process
% output  A vector containing the filter's output signal
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006, Jan 2007

% filename : Gfb_filter_process.m


factor = filter_obj.normalization_factor;

% for compatibility of the filter state with the MEX extension, we
% have to multiply the filter state with the filter coefficient before the
% call to filter:
filter_state = filter_obj.state * filter_obj.coefficient;

for i = [1:filter_obj.gamma_order]
  [input, filter_state(i)] = ...
      filter(factor, [1, -filter_obj.coefficient], ...
             input, filter_state(i));
  factor = 1;
end

output = input;

% for compatibility of the filter state with the MEX extension, we
% have to divide the filter state by the filter coefficient after the
% call to filter:
filter_obj.state = filter_state / filter_obj.coefficient;


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
