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

mixin_python_cmd = sprintf('/usr/bin/python ~/repos/MiXiN/xtract_mixin.py %s --first-prefix --outdir %s %s', fname, outdir, argstr);

[status, out] = system(mixin_python_cmd);
display(status)
display(out)

end
