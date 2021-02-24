function MiXiN_python_shim(filename, varargin)
p = inputParser;

defaultOutDir = '.';
defaultSinglemodel = false;
defaultInstrumental = false;

addRequired(p, 'filename', @ischar);
addOptional(p, 'OutDir', defaultOutDir, @ischar);
addParameter(p, 'SingleModel', defaultSinglemodel, @islogical);
addParameter(p, 'Instrumental', defaultInstrumental, @islogical);

parse(p, filename, varargin{:});

fname = p.Results.filename;

outdir = p.Results.OutDir;

argstr = '';

if p.Results.Instrumental
	argstr = sprintf('%s %s', argstr, "--instrumental");
end
if p.Results.SingleModel
	argstr = sprintf('%s %s', argstr, "--single-model");
end

[mypath, ~, ~] = fileparts(mfilename('fullpath'));
vendoredMixinScript = fullfile(mypath, '../vendor/MiXiN/xtract_mixin.py');
mixin_python_cmd = sprintf('/usr/bin/python %s %s --first-prefix --outdir %s %s', vendoredMixinScript, fname, outdir, argstr);

[status, out] = system(mixin_python_cmd);
display(status)
display(out)

end
