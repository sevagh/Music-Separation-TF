files = dir('data/*.wav');
for file = files'
    fname = sprintf('%s/%s', file.folder, file.name);
    if contains(fname, "mix")
        HPSS(fname, 'separated', 'fitzgerald', 'mask', 'soft');
    end
    % Do some stuff
end