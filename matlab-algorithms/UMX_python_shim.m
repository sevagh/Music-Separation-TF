function UMX_python_shim(filename, varargin)
p = inputParser;

defaultOutDir = '.';

addRequired(p, 'filename', @ischar);
addOptional(p, 'OutDir', defaultOutDir, @ischar);

parse(p, filename, varargin{:});

fname = p.Results.filename;

outdir = p.Results.OutDir;

umx_python_cmd = sprintf('~/.conda/envs/umx-gpu/bin/python ../python-sota-baselines/umx.py %s --outdir %s', fname, outdir);

[status, out] = system(umx_python_cmd);
display(status)
display(out)

end
