function WMDCTLassoShrink(filename, varargin)
p = inputParser;

defaultHarmonicWMDCT= 256;
defaultPercussiveWMDCT = 32;
defaultHarmonicLambda = 0.8;
defaultPercussiveLambda = 0.5;

defaultOutDir = '.';

addRequired(p, 'filename', @ischar);
addOptional(p, 'OutDir', defaultOutDir, @ischar);
addParameter(p, 'HarmonicWMDCT', defaultHarmonicWMDCT, @isnumeric);
addParameter(p, 'PercussiveWMDCT', defaultPercussiveWMDCT, @isnumeric);
addParameter(p, 'HarmonicLambda', defaultHarmonicLambda, @isnumeric);
addParameter(p, 'PercussiveLambda', defaultPercussiveLambda, @isnumeric);

parse(p, filename, varargin{:});

[x, fs] = audioread(p.Results.filename);

% Tonal layer
% -----------

F1=frametight(frame('wmdct', 'gauss', p.Results.HarmonicWMDCT));

% Group lasso and invert
c1 = franagrouplasso(F1, x, p.Results.HarmonicLambda, 'soft', 'freq');
xh = frsyn(F1, c1);

% Transient layer
% ---------------

F2=frametight(frame('wmdct', 'gauss', p.Results.PercussiveWMDCT));

c2 = franagrouplasso(F2, x, p.Results.PercussiveLambda, 'soft', 'time');
xp = frsyn(F2, c2);

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname,"_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.OutDir, prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.OutDir, prefix);

if size(xh, 1) < size(x, 1)
    xh = [xh; x(size(xh, 1)+1:size(x, 1))];
end

if size(xp, 1) < size(x, 1)
    xp = [xp; x(size(xp, 1)+1:size(x, 1))];
end

if size(xh, 1) > size(x, 1)
    xh = xh(1:size(x, 1), :);
end

if size(xp, 1) > size(x, 1)
    xp = xp(1:size(x, 1), :);
end

audiowrite(xhOut, xh, fs);
audiowrite(xpOut, xp, fs);
end
