% include vendored PEASS code
addpath(genpath('vendor/PEASS-Software-v2.0.1'));

files = dir('data-hpss/*.wav');
resultsDir = 'results-hpss';

testCases = {...
    ...{'1pass-hpss-d-128', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFTWindowSize", 128)}...
    ...{'1pass-hpss-d-256', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFTWindowSize", 256)}...
    ...{'1pass-hpss-d-1024', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFTWindowSize", 1024)}...
    ...{'1pass-hpss-d-4096', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFTWindowSize", 4096)}...
    ...{'1pass-hpss-d-16384', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFTWindowSize", 16384)}...
    ...{'1pass-hpss-f-128', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFTWindowSize", 128)}...
    ...{'1pass-hpss-f-256', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFTWindowSize", 256)}...
    ...{'1pass-hpss-f-1024', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFTWindowSize", 1024)}...
    ...{'1pass-hpss-f-4096', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFTWindowSize", 4096)}...
    ...{'1pass-hpss-f-16384', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFTWindowSize", 16384)}...
    ...{'1pass-hpss-d-cqt-24', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFT", "cqt", "CQTBinsPerOctave", 24)}...
    ...{'1pass-hpss-d-cqt-48', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFT", "cqt", "CQTBinsPerOctave", 48)}...
    ...{'1pass-hpss-d-cqt-96', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "hard", "STFT", "cqt", "CQTBinsPerOctave", 96)}...
    ...{'1pass-hpss-f-cqt-24', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFT", "cqt", "CQTBinsPerOctave", 24)}...
    ...{'1pass-hpss-f-cqt-48', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFT", "cqt", "CQTBinsPerOctave", 48)}...
    ...{'1pass-hpss-f-cqt-96', @(fname, dest) HPSS_1pass(fname, dest, "Mask", "soft", "STFT", "cqt", "CQTBinsPerOctave", 96)}...
    ...{'id', @(fname, dest) Driedger_Iterative(fname, dest)}...
    ...{'id-cqt1', @(fname, dest) Driedger_Iterative(fname, dest, "HiResSTFT", "cqt")}...
    ...{'id-cqt2', @(fname, dest) Driedger_Iterative(fname, dest, "LoResSTFT", "cqt")}...
    ...{'id-cqt3', @(fname, dest) Driedger_Iterative(fname, dest, "LoResSTFT", "cqt", "HiResSTFT", "cqt")}...
    {'hybrid', @(fname, dest) HPSS_hybrid(fname, dest)}...
};

resultSize = floor(size(files, 1)/3);
%results = zeros(size(testCases, 2), resultSize, 8);
results = zeros(size(testCases, 2), 1, 8);

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
        for testcase = 1:size(testCases, 2)
            tname = testCases{testcase}{1};
            tfunc = testCases{testcase}{2};
            
            destloc = sprintf('%s/%s', resultsDir, tname); 
            fprintf('Executing %s\n', tname);
            tfunc(fname, destloc); % execute the test case

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
        
        % uncomment this block to limit testing to a single file
        if findex >= 2
            break
        end
    end
end

fprintf('*************************\n');
fprintf('****  FINAL RESULTS  ****\n');
fprintf('*************************\n');

for testcase = 1:size(testCases, 2)
    fprintf('%s, median scores\n', testCases{testcase}{1});
    fprintf('\tOPS: %03f\t%03f\n', median(results(testcase, :, 1)), median(results(testcase, :, 5)));
    fprintf('\tTPS: %03f\t%03f\n', median(results(testcase, :, 2)), median(results(testcase, :, 6)));
    fprintf('\tIPS: %03f\t%03f\n', median(results(testcase, :, 3)), median(results(testcase, :, 7)));
    fprintf('\tAPS: %03f\t%03f\n', median(results(testcase, :, 4)), median(results(testcase, :, 8)));  
end