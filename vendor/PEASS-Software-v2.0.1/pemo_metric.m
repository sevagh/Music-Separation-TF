function PSMt = pemo_metric(mref,mtest,fs)

% PEMO_METRIC Example implementation of the PEMO-Q objective quality
% assessment metric
% 
% Disclaimer: this implementation differs from the commercial version at
% http://www.hoertech.de/web_en/produkte/pemo-q.shtml
% When accuracy is a crucial concern, the use of the commercial version is
% recommended instead.
%
% PSMt = pemo_metric(mref,mtest,fs)
%
% Inputs:
% mref: nband x nsampl x nmod internal representation of the reference
% signal
% mtest: nband x nsampl x nmod internal representation of the test signal
% fs: sampling frequency of the internal representation
%
% Outputs:
% PSMt: PSMt metric
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version history
% - Version 2.0, October 2011: kept PSMt only and changed the parameters
% - Version 1.1, September 2011: first release
% Copyright 2011 Emmanuel Vincent (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Errors and warnings %%%
if nargin<2, error('Not enough input arguments.'); end
[nband,nsampl,nmod]=size(mref);
[nband2,nsampl2,nmod2]=size(mtest);
if (nband2~=nband) , error('The reference and the test representations must have the same number of frequency subbands.'); end
if (nsampl2~=nsampl), error('The reference and the test representations must have the same duration.'); end
if (nmod2~=nmod), error('The reference and the test representations must have the same number of modulation subbands.'); end

%%% Assimilation and cross-correlation %%%
% Assimilation
assim=(abs(mtest)<abs(mref));
mtest(assim)=.25*mref(assim)+.75*mtest(assim);
% PSMt
flen=min(nsampl,.1*fs);
nfram=floor(nsampl/flen);
nsampl=nfram*flen;
mref=mref(:,1:nsampl,:);
mtest=mtest(:,1:nsampl,:);
PSMt=zeros(nfram,1);
lPSM=zeros(nmod,1);
lNMS=zeros(nmod,1);
for t=1:nfram,
    for m=1:nmod,
        lref=mref(:,(t-1)*flen+1:t*flen,m);
        lref=lref(:)-mean(lref(:));
        ltest=mtest(:,(t-1)*flen+1:t*flen,m);
        lNMS(m)=sum(ltest(:).*ltest(:));
        ltest=ltest(:)-mean(ltest(:));
        lPSM(m)=sum(lref.*ltest)./sqrt(sum(lref.*lref)*sum(ltest.*ltest));
    end
    PSMt(t)=sum(lPSM.*lNMS)/sum(lNMS);
end
%%% From local to global similarity %%%
% Lowpass-filtered RMS
ilen=1*fs;
mtest=sum(sum(mtest.^2,1),3);
RMS=zeros(nfram,1);
for t=1:nfram,
    ltest=mtest(max(1,(t-.5)*flen-.5*ilen+1):min(nsampl,(t-.5)*flen+.5*ilen));
    RMS(t)=mean(ltest);
end
% Weighted percentile
[PSMt,ind]=sort(PSMt);
RMS=RMS(ind);
RMS=cumsum(RMS);
ind=find(RMS>=.5*RMS(end));
PSMt=PSMt(ind(1));

return;