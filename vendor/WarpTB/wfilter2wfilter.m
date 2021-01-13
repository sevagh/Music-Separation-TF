function [A,B,M]=wfilter2wfilter(a,b,lam1,lam2)
% 
% [An,Bn,M]=wfilter2wfilter(A,B,lam1,lam2)
%
% This function takes in filter coefficients A and B, corresponding
% to a warped filter with warping parameter lam1 and converts the filter
% to a another warped filter with parameters A2 and B2 and lam2 as
% a warping parameter. 
%
% WARNING: This mapping may suffer from finite word-length problems
% especially if the order of the filter is high.  
%
% This function is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples.

% Authors: Aki Härmä, Matti Karjalainen
% Helsinki University of Technology, Laboratory of Acoustics and
% Audio Signal Processing

a=a(:);b=b(:);
dima=length(a);dimb=length(b);

%%%%%%% Mappings for a-coefficients
Ba=-powerconv([-1+lam1*lam2 lam1-lam2],dima-1);

Ma=zeros(dima,dima);

for q=0:dima-1,
  mm=conv(powerconv([-lam1+lam2 1-lam1*lam2],q),...
      powerconv([1-lam1*lam2 -lam1+lam2],dima-1-q));
  Ma(q+1,1:length(mm))=mm;
end

Aa=a'*Ma;

%%%%%%% Mappings for b-coefficients
Bb=-powerconv([-1+lam1*lam2 lam1-lam2],dimb-1);

Mb=zeros(dimb,dimb);

for q=0:dimb-1,
  mm=conv(powerconv([-lam1+lam2 1-lam1*lam2],q),...
      powerconv([1-lam1*lam2 -lam1+lam2],dimb-1-q));
  Mb(q+1,1:length(mm))=mm;
end

Ab=b'*Mb;

A=conv(Aa,Bb);B=conv(Ab,Ba);

%%%%%%%%%%%%%%%%%%%%%%%%%
function y=powerconv(x,n)
%
y=x;
if n==0, y=1;end
for q=1:n-1,
  y=conv(y,x);
end
