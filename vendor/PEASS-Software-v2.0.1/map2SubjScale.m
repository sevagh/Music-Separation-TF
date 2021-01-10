function [OPS, TPS, IPS, APS] = ...
    map2SubjScale(qTarget, qInterf, qArtif, qGlobal)
% Non-linear mapping to subjective scale
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version history
% - Version 2.0, October 2011: replaced 1.5-layer net by 2-layer net with
% unconstrained feature selection and input log-mapping
% - Version 1.0, June 2010: first release
% Copyright 2010-2011 Valentin Emiya and Emmanuel Vincent (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

q = [qGlobal; qTarget; qInterf; qArtif];

% Log-mapping
q=max(min(log((1+q)./(1-q)),5.5),-5.5);

taskQ = NaN(4,1);
for nTask = 1:4
    % Feature selection and neural net
    load(sprintf('paramTask%d.mat',nTask));
    taskQ(nTask) = myMapping(q(selec),W,b,v,a);
end

OPS = taskQ(1);
TPS = taskQ(2);
IPS = taskQ(3);
APS = taskQ(4);
return