function sproj = LSDecompose_tv(se,s,flen,Lw,hop)
% SPROJ Least-squares projection of each channel of se on the subspace
% spanned by delayed versions of the channels of s, with delays between
% -flen2 and +flen2 where flen = 2*flen2+1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.0
% Copyright 2010 Valentin Emiya (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flen2 = (flen-1)/2;
if flen2~=round(flen2)
    error('filterParam:NotOdd','Not an odd order');
end

s (end+1:end+flen-1+Lw-1,:) = 0;
se(end+1:end+flen-1+Lw-1,:) = 0;
[nsampl,nsrc]=size(s);
nchanEst = size(se,2);

% sine analysis window / sine synthesis window
fahandle = @hann;
fshandle = @hann;
wa = sqrt(flipud(window(fahandle,Lw,'periodic')));
ws = sqrt(flipud(window(fshandle,Lw,'periodic')));

WS = zeros(Lw,nchanEst,nsrc);
for chan = 1:nchanEst
    for j=1:nsrc
        WS(:,chan,j) = ws;
    end
end
wBegin = 1;
wEnd = wBegin+Lw-1;
sproj = zeros(nsampl,nchanEst,nsrc);
wAccum = zeros(nsampl,1);
Ns = size(s,2);
Ls = size(s,1);

while wEnd-Lw/2<=size(sproj,1)-Lw+1
    % get frames
    sew = se(wBegin:wEnd,:);
    sw = [zeros(max(0,flen2-wBegin+1),Ns);...
        s(max(1,wBegin-flen2):min(end,wEnd+flen2),:);...
        zeros(max(0,wEnd+flen2-Ls),Ns)];
    
    % projection
    sprojw=LSDecompose(sew,sw,flen2,wa);
    
    % overlap add
    sproj(wBegin:wEnd,:,:) = sproj(wBegin:wEnd,:,:)...
        + sprojw(1:Lw,:,:).*WS;
    
    wAccum(wBegin:wEnd,1) = wAccum(wBegin:wEnd,1)+ws.*wa;
    
    % update for next iteration
    wBegin = wBegin+hop;
    wEnd = wEnd+hop;
end
I = wAccum~=0;
for j=1:nsrc
    sproj(I,:,j) = sproj(I,:,j) ./(wAccum(I)*ones(1,nchanEst));
end

sproj = sproj(1:end-Lw+1,:,:);
return

