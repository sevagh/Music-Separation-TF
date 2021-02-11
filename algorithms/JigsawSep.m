function JigsawSep(filename, varargin)
p = inputParser;

defaultV2 = false;
defaultp = 2;
defaultr1 = 0.88;
defaultr2 = 1.05;

defaultOutDir = '.';

addRequired(p, 'filename', @ischar);
addOptional(p, 'OutDir', defaultOutDir, @ischar);
addParameter(p, 'V2', defaultV2, @islogical);
addParameter(p, 'p', defaultp, @isnumeric);
addParameter(p, 'r1', defaultr1, @isnumeric);
addParameter(p, 'r2', defaultr2, @isnumeric);

parse(p, filename, varargin{:});

[x, fs] = audioread(p.Results.filename);

if p.Results.V2
    [seps, ~] = tfjigsawsep(x, p.Results.r1, p.Results.r2, p.Results.p,'ver2','fs', fs);
else
    [seps, ~] = tfjigsawsep(x, p.Results.r1, p.Results.r2, p.Results.p, 'fs', fs);
end

[~,fname,~] = fileparts(p.Results.filename);
splt = split(fname,"_");
prefix = splt{1};

xhOut = sprintf("%s/%s_harmonic.wav", p.Results.OutDir, prefix);
xpOut = sprintf("%s/%s_percussive.wav", p.Results.OutDir, prefix);
xrOut = sprintf("%s/%s_residual.wav", p.Results.OutDir, prefix);

audiowrite(xhOut, seps(:, 1), fs);
audiowrite(xpOut, seps(:, 2), fs);
audiowrite(xrOut, seps(:, 3), fs);
end
