addpath(genpath('../algorithms'));

testCases = {...
    {'id-default', @(fname, dest) Driedger_Iterative_Default(fname, dest)}...
    {'1pass-hpss-f-cqt-96', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFT", "cqt", "CQTBinsPerOctave", 96)}...
    {'wmdctlasso-11', @(fname, dest) WMDCTLassoShrink(fname, dest, "HarmonicWMDCT", 512, "PercussiveWMDCT", 32)}...
    {'hybrid-v10', @(fname, dest) HarmonicPercussiveVocal10(fname, dest)}...
    {'umx', @(fname, dest) UMX_python_shim(fname, dest)}...
};