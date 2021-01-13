function longchain
%LONGCHAIN - warp a signal using a long allpass filter chain
%
% y=longchain(x,M,lambda)
%
% warps a signal using a chain of M allpass filter elements.
% The output signal is obtained by feeding an original signal x
% into a chain of M allpass elements and then resding the output
% stages of the chain into vector y. lambda is the warping parameter.
%
% This function is provided just to illustrate the characteristics 
% of the warping effect. For warping of an impulse response, use
% warp_impres function. 
%
% This function is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples.

% Authors: Matti Karjalainen, Aki Härmä
% Helsinki University of Technology, Laboratory of Acoustics and
% Audio Signal Processing

% This is just a help function. A MEX-function written in C-language
% is used for computation.


