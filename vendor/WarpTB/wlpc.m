function A = wlpc(sig,n,lambda)
%WLPC Warped Linear Prediction Coefficients
%
% A = wlpc(X,N,lambda)
%
% finds the coefficients, A=[ 1 A(2) ... A(N+1) ],
% of a Nth order warped forward linear predictor
% such that the mean square errors between the prediction
% and the original signal is minimized.
% The warping coefficient |lambda|<1 determines the characteristics
% of the frequency warping effect.
%
% This function is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples

% Authors: Matti Karjalainen, Aki Härmä
% Helsinki University of Technology, Laboratory of Acoustics and
% Audio Signal Processing

ac = wautoc(sig,lambda,n);
A = levinson(ac,n-1)';
