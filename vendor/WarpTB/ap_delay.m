function delayed = ap_delay(sig,lambda)
% AP_DELAY - implementation of a single first order allpass filter
%
% y = ap_delay(x,lambda)
%
% filters sequence x with a first order allpass filter with
% parameter lambda.
%
% This function is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples

% Authors: Matti Karjalainen, Aki Härmä
% Helsinki University of Technology, Laboratory of Acoustics and
% Audio Signal Processing

b = [-lambda 1]';
a = [1 -lambda]';
delayed = filter(b,a,sig);
