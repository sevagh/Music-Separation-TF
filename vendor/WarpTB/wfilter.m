function wfilter
%WFILTER Warped FIR/IIR filter 
%
% [y,Zo]=wfilter(A,B,x,lambda,Zi)
%
% This MEX-function is a real-valued implementation of a warped filter. 
% The function was designed so that it resembles the original filter function
% from Signal Processing Toolbox by Mathworks. One difference
% to Matlabs filter function is that wfilter is implemented as a 
% Direct Form II structure which makes it possible to use the function 
% recursively using the same representation for inner states even 
% if filter coefficients are changed during computation.
% A and B are coefficient vectors for feedforward and feedbackward branches
% of the filter, respectively. Vectors x and y are input and output 
% signals, lambda is the warping coefficient. Zi and Zo are optional
% vectors and they represent the inner states of the filter. If Zi is 
% not specified, inner states are initialized to zeroes.
%
% This function is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples.

% Authors: Matti Karjalainen, Aki Härmä
% Helsinki University of Technology, Laboratory of Acoustics and
% Audio Signal Processing

% This is just a help function. A MEX-function written in C-language
% is used for computation.

