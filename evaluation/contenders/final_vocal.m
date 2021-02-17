testCases = {...
    {'mf-default-linear', @(fname, dest) Fitzgerald_Multipass(fname, dest)}...
    {'mf-default-cqt', @(fname, dest) Fitzgerald_Multipass(fname, dest, "LoResSTFT", "cqt")}... % same as mf-cqt2-24
    {'hybrid', @(fname, dest) HarmonicPercussiveVocal(fname, dest)}...
    {'umx', @(fname, dest) UMX_python_shim(fname, dest)}... % REMOVE ME
};
