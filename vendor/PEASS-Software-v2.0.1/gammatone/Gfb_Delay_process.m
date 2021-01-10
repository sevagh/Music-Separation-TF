function [output, delay] = Gfb_Delay_process(delay, input)
% [output, delay] = Gfb_Delay_process(delay, input)
%
% Each band (row) of the input data will be delayed by a band-dependend
% ammount of samples, then multiplied with a band-dependend complex
% constant.  Finally, the real part of this product will be returned.
%
% PARAMETERS
% delay   A Gfb_Delay structure created from Gfb_Delay_new.  The delay
%         will be returned with updated delayline states as the second
%         return parameter
% input   A complex matrix containing the signal to delay.  Each row
%         corresponds to a filterbank band
% output  A real matrix containing the delay's output
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006

% filename : Gfb_Delay_process.m


[number_of_bands, number_of_samples] = size(input);
if (number_of_bands ~= length(delay.delays_samples))
  error('input rows must match the number of bands');
end
output = zeros(number_of_bands, number_of_samples);
for band = [1:number_of_bands]
  if (delay.delays_samples(band) == 0)
    output(band,:) = ...
        real(input(band,:) * delay.phase_factors(band));
  else
    tmp_out = [delay.memory(band,1:delay.delays_samples(band)), ...
               real(input(band,:) * delay.phase_factors(band))];
    delay.memory(band,1:delay.delays_samples(band)) = ...
        tmp_out(number_of_samples+1:length(tmp_out));
    output(band,:) = tmp_out(1:number_of_samples);
  end
end


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
