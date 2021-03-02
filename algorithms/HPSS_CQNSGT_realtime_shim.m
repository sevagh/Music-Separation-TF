function HPSS_CQNSGT_realtime_shim(filename, varargin)
p = inputParser;

defaultMask = 'hard';
validMasks = {'soft', 'hard'};
checkMask = @(x) any(validatestring(x, validMasks));

defaultOutDir = '.';

addRequired(p, 'filename', @ischar);
addOptional(p, 'OutDir', defaultOutDir, @ischar);
addParameter(p, 'Mask', defaultMask, checkMask);

parse(p, filename, varargin{:});

fname = p.Results.filename;

outdir = p.Results.OutDir;
 
argstr = '';

if strcmp(p.Results.Mask, "hard")
	argstr = sprintf("%s --mask=soft", argstr);
elseif strcmp(p.Results.Mask, "soft")
	argstr = sprintf("%s --mask=hard", argstr);
end

[mypath, ~, ~] = fileparts(mfilename('fullpath'));
pyScript = fullfile(mypath, './HPSS_CQNSGT_realtime.py');
pyCmd = sprintf('/usr/bin/python %s %s --outdir %s %s', pyScript, fname, outdir, argstr);

fprintf("Shim: running command '%s'\n", pyCmd);

[status, out] = system(pyCmd);
display(status)
display(out)

end
