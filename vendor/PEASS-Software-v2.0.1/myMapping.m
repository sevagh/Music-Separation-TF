function [y,dW,db,dv,da] = myMapping(x,W,b,v,a)
% Single-output two-layer perceptron with one hidden layer.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version history
% - Version 2.0, October 2011: replaced 1.5-layer NN by 2-layer NN
% - Version 1.0, June 2010: first release
% Copyright 2010-2011 Valentin Emiya and Emmanuel Vincent (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nin,ndata]=size(x);
nhid=length(v);

s1=W*x+b*ones(1,ndata); % weighted sum of the inputs
o1=sigmoid(s1); % output of the first layer
s2=v'*o1+a; % weighted sum of the first layer outputs
y=100*sigmoid(s2); % output

if nargout>1
    do1=dsigmoid(s1);
    dy=dsigmoid(s2);
    da=100*dy;
    dv=(ones(nhid,1)*da).*o1;
    db=100*(v*dy).*do1;
    dW=repmat(permute(db,[1 3 2]),[1 nin 1]).*repmat(permute(x,[3 1 2]),[nhid 1 1]);
end

return


function y=sigmoid(x)

y=1./(1+exp(-x));

return


function dy=dsigmoid(x)

dy=1./(2+exp(x)+exp(-x));

return