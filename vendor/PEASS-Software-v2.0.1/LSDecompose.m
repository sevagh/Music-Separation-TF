function proj = LSDecompose(se,s,flen2,wa)
% SPROJ Weighted least-squares projection of each channel of se on the subspace
% spanned by delayed versions of the channels of s, with delays between
% -flen2 and flen2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.0
% Copyright 2010 Valentin Emiya (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


flen = 2*flen2+1;
J = size(s,2);


S = zeros(size(se,1),J*flen);
for j=1:J
    try
        S(:,(j-1)*flen+1:j*flen) =...
            toeplitzC(s(flen:end,j),s(flen:-1:1,j));
    catch
        S(:,(j-1)*flen+1:j*flen) =...
            toeplitz(s(flen:end,j),s(flen:-1:1,j));
    end
end

% Weighted ...
Sw = diag(wa)*S;
se = diag(wa)*se;

% ... Least squares
gramSw = Sw'*Sw;

lambda = 10^-15; % regularization parameter (useful when a sequence of zeroes occurs in sources "s"
[R testCond] = chol(gramSw+lambda*eye(size(gramSw))); % very fast but raises an error if gramS is not well conditionned
if testCond
    % if gramS is not well conditionned, use pseudo-inverse (more
    % computations)
    y = pinv(Sw)*se;
else
    y = R\(R'\Sw'*se);
end

proj = zeros([size(se), size(s,2)]); % length x channels x sources
Wa = diag(wa);
for j=1:J
%     proj(:,:,j) = S(:,(j-1)*flen+(1:flen))*y((j-1)*flen+(1:flen),:);
    proj(:,:,j) = Wa*S(:,(j-1)*flen+(1:flen))*y((j-1)*flen+(1:flen),:);
end
return

