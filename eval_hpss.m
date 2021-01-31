% include vendored PEASS code
addpath(genpath('vendor/PEASS-Software-v2.0.1'));

files = dir('data-hpss/*.wav');

resultSize = floor(size(files, 1)/3);
results = zeros(16, resultSize, 8); % 16 test cases

testNames = [
    'id';
    'id-cqt1';
    'id-cqt2';
    'id-cqt3';
    '1pass-hpss-d-256';
    '1pass-hpss-d-1024';
    '1pass-hpss-d-4096';
    '1pass-hpss-f-256';
    '1pass-hpss-f-1024';
    '1pass-hpss-f-4096';
    '1pass-hpss-d-cqt-24';
    '1pass-hpss-d-cqt-48';
    '1pass-hpss-d-cqt-96';
    '1pass-hpss-f-cqt-24';
    '1pass-hpss-f-cqt-48';
    '1pass-hpss-f-cqt-96';
];

testFuncs = [
    @(fname, dest) Driedger_Iterative(fname, dest);
    @(fname, dest) Driedger_Iterative(fname, dest, "HiResSTFT", "cqt");
    @(fname, dest) Driedger_Iterative(fname, dest, "LoResSTFT", "cqt");
    @(fname, dest) Driedger_Iterative(fname, dest, "HiResSTFT", "cqt", "LoResSTFT", "cqt");
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFTWindowSize", 256);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFTWindowSize", 1024);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFTWindowSize", 4096);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFTWindowSize", 256);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFTWindowSize", 1024);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFTWindowSize", 4096);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFT", "cqt", "CQTBinsPerOctave", 24);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFT", "cqt", "CQTBinsPerOctave", 48);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFT", "cqt", "CQTBinsPerOctave", 96);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFT", "cqt", "CQTBinsPerOctave", 24);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFT", "cqt", "CQTBinsPerOctave", 48);
    @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFT", "cqt", "CQTBinsPerOctave", 96);
];

options.destDir = '/tmp/';
options.segmentationFactor = 1;

findex = 1;

for file = files'
    fname = sprintf('%s/%s', file.folder, file.name);
    
    if contains(fname, "mix")
        display(fname)
        
        % then evaluate it
        splt = split(file.name,"_");
        prefix = splt{1};
        
        harmOriginalFiles = {...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix);...
            sprintf('%s/%s_percussive.wav', file.folder, prefix)};

        percOriginalFiles = {...
            sprintf('%s/%s_percussive.wav', file.folder, prefix);...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix)};
        for testcase = 1:16
            tname = testNames(testcase);
            tfunc = testFuncs(testcase);
            
            destloc = sprintf('results/%s', tname); 
            fprintf('Executing %s\n', tname);
            tfunc(fname, dest); % execute the test case

            fprintf('Evaluating %s\n', tname);

            resH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
                sprintf('%s/%s_harmonic.wav', destloc, prefix), options);
            resP = PEASS_ObjectiveMeasure(percOriginalFiles,...
                sprintf('%s/%s_percussive.wav', destloc, prefix), options);

            results(testcase, findex, 1) = resH.OPS;
            results(testcase, findex, 2) = resH.TPS;
            results(testcase, findex, 3) = resH.IPS;
            results(testcase, findex, 4) = resH.APS;
            results(testcase, findex, 5) = resP.OPS;
            results(testcase, findex, 6) = resP.TPS;
            results(testcase, findex, 7) = resP.IPS;
            results(testcase, findex, 8) = resP.APS;
        end
        findex = findex + 1;
    end
end

toPrint = 1; % print OPS

% results are stored indexed as follows
% 1 = Overall Perceptual Score
% 2 = Target-related Perceptual Score
% 3 = Interference-related Perceptual Score
% 4 = Artifact-related Perceptual Score

fprintf('*************************\n');
fprintf('****  FINAL RESULTS  ****\n');
fprintf('*************************\n');

for testcase = 1:16
    tname = testNames(testcase);
    res = results(testcase, :, :);
    
    fprintf('%s, median scores\n', tname)
    fprintf('\tHarm OPS: %03f\n', median(results(:, toPrint)));
    fprintf('\tPerc OPS: %03f\n', median(results(:, toPrint+4)));
end