function [sTrue,eSpat,eInterf,eArtif] =...
    extractTSIA(s,sEst,flen,Lw,hop,options)
% decompose each multichannel estimate sEst(:,:,nEst) into TSIA
% using original sources s
% where s(:,:,1) is the target source and
% s(:,:,j), j>1, are the interfering sources

[L,NChan,NSources] = size(s);
NEst = size(sEst,3);

s = reshape(s,[L,NSources*NChan]);
sEst = reshape(sEst,[L,NEst*NChan]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Projection on all sources/channels      %
yProjAll_ = LSDecompose_tv(...
    sEst,s,flen,Lw,hop);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% merge projections on channels and remove last samples (filter length)
yProjAll = zeros([L,NChan,NSources]);
for nSource = 1:NSources
    yProjAll(:,:,nSource) = ...
        sum(yProjAll_(1:end-flen+1,:,(nSource-1)*NChan+(1:NChan)),3);
end

if options.FLAG_2PROJ
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Projection on target sources/channels   %
    eSpat = zeros(size(sEst));
    for nEst=1:NEst
        % project each estimate onto the target (first NChan channels in s)
        eSpat_ = LSDecompose_tv(...
            sEst(:,(nEst-1)*NChan+(1:NChan)),...
            s(:,1:NChan),flen,Lw,hop);
        % merge projections on channels and remove last samples (filter length)
        eSpat(:,:) = ...
            sum(eSpat_(1:end-flen+1,:,:),3);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

% Build distortion components
sTrue = zeros([L,NChan,NEst]);
for nEst=1:NEst
    sTrue(:,:,nEst) = s(:,1:NChan);
end
if options.FLAG_2PROJ
    eSpat = eSpat-sTrue;
else
    eSpat = yProjAll(:,:,1:NEst)-sTrue;
end

eInterf = sum(yProjAll,3) - eSpat - sTrue;

eArtif = reshape(sEst,[L,NChan,NEst]) - sTrue - eSpat - eInterf;

return