function wac = wautoc(sig,lambda,n)
% WAUTOC - Computation of a warped autocorrelation function
%
% function ac = wautoc(x,lambda,N)
%
% computes warped autocorrelation coefficients
% of sequence x using allpass warping with lambda for lags 0..N.
%
% This function is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples

% Authors: Matti Karjalainen, Aki Härmä
% Helsinki University of Technology, Laboratory of Acoustics and
% Audio Signal Processing

sig=sig(:); sigt=sig';
wac(1,1)=sigt*sig;
wrpd=sig(:);
for i=2:n,
	wrpd=ap_delay(wrpd,lambda);
	wac(1,i)=sigt*wrpd;
end
