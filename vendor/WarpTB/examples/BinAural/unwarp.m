function [buw,auw] = unwarp(bw,aw,lambda); 
% UNWARP unwarp via second-order-sections in closed form a WIIR 
% presentation using lambda [1] 
% 
%	Syntax:  [buw,auw]=unwarp(bw,aw,lambda); 
%  				 
%	bw,aw are the warped IIR filter coefficients 
%	lambda is the unwarping coefficient 
 
% 		Copyright (c) 2000 Jyri Huopaniemi 
%		Nokia Research Center, Speech and Audio Systems Laboratory 
%		P.O.Box 407, FIN-00045 Nokia Group, Finland 
%		e-mail: Jyri.Huopaniemi@nokia.com 
%		Last modification: Jan 31, 2000 
% 
%		[1] Huopaniemi, J. Virtual acoustics and 3-D sound 
% in multimedia signal processing, PhD thesis, Helsinki Univ. of Tech., 
% Lab. of Acoustics and Audio Signal Processing,  Report 53, Nov. 1999, 
% 189 p. 
%
% See also wfilter2wfilter.

% This function is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples
 

sosw=tf2sos(bw,aw); 
[x y]=size(sosw); 
for i=1:x, 
   sosn4=1+sosw(i,5)*lambda+sosw(i,6)*(lambda^2); 
   sosn(i,1)=(sosw(i,1)+sosw(i,2)*lambda+sosw(i,3)*(lambda^2))/sosn4; 
   sosn(i,2)=(2*sosw(i,1)*lambda+sosw(i,2)*(1+lambda^2)+sosw(i,3)*2*lambda)/sosn4; 
   sosn(i,3)=(sosw(i,1)*(lambda^2)+lambda*sosw(i,2)+sosw(i,3))/sosn4; 
   sosn(i,4)=1; 
   sosn(i,5)=(2*lambda+sosw(i,5)*(1+lambda^2)+sosw(i,6)*2*lambda)/sosn4; 
   sosn(i,6)=(lambda^2+lambda*sosw(i,5)+sosw(i,6))/sosn4; 
end; 
[buw,auw] = sos2tf(sosn);  


