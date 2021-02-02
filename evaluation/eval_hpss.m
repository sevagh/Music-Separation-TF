addpath(genpath('../vendor/PEASS-Software-v2.0.1'));
addpath(genpath('../matlab-algorithms'));

files = dir('../data/data-hpss/*.wav');
resultsDir = '../evaluation/results-hpss';

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
    {'id', @(fname, dest) Driedger_Iterative(fname, dest)}...
    ...{'id-cqt1', @(fname, dest) Driedger_Iterative(fname, dest, "HiResSTFT", "cqt")}...
    ...{'id-cqt2', @(fname, dest) Driedger_Iterative(fname, dest, "LoResSTFT", "cqt")}...
    ...{'id-cqt3', @(fname, dest) Driedger_Iterative(fname, dest, "LoResSTFT", "cqt", "HiResSTFT", "cqt")}...
    {'hybrid', @(fname, dest) HarmonicPercussiveVocal(fname, dest)}...
};

display(size(testCases))
if size(testCases, 2) < size(testCases, 1)
    testCases = testCases';
end
display(size(testCases))

resultSize = floor(size(files, 1)/3);
results = zeros(size(testCases, 2), resultSize, 24);

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
            results(testcase, findex, 5) = resH.ISR;
            results(testcase, findex, 6) = resH.SIR;
            results(testcase, findex, 7) = resH.SAR;
            results(testcase, findex, 8) = resH.SDR;
            results(testcase, findex, 9) = resH.qTarget;
            results(testcase, findex, 10) = resH.qInterf;
            results(testcase, findex, 11) = resH.qArtif;
            results(testcase, findex, 12) = resH.qGlobal;
            
            results(testcase, findex, 13) = resP.OPS;
            results(testcase, findex, 14) = resP.TPS;
            results(testcase, findex, 15) = resP.IPS;
            results(testcase, findex, 16) = resP.APS;
            results(testcase, findex, 17) = resP.ISR;
            results(testcase, findex, 18) = resP.SIR;
            results(testcase, findex, 19) = resP.SAR;
            results(testcase, findex, 20) = resP.SDR;
            results(testcase, findex, 21) = resP.qTarget;
            results(testcase, findex, 22) = resP.qInterf;
            results(testcase, findex, 23) = resP.qArtif;
            results(testcase, findex, 24) = resP.qGlobal;
            
        end
        findex = findex + 1;
    end
end

fprintf('*************************\n');
fprintf('****  FINAL RESULTS  ****\n');
fprintf('*************************\n');

for testcase = 1:size(testCases, 2)
    fprintf('%s, median scores\n', testCases{testcase}{1});
    fprintf('\tOPS: %03f\t%03f\n', median(results(testcase, :, 1)), median(results(testcase, :, 13)));
    fprintf('\tTPS: %03f\t%03f\n', median(results(testcase, :, 2)), median(results(testcase, :, 14)));
    fprintf('\tIPS: %03f\t%03f\n', median(results(testcase, :, 3)), median(results(testcase, :, 15)));
    fprintf('\tAPS: %03f\t%03f\n', median(results(testcase, :, 4)), median(results(testcase, :, 16)));  
    fprintf('\tISR: %03f\t%03f\n', median(results(testcase, :, 5)), median(results(testcase, :, 17)));
    fprintf('\tSIR: %03f\t%03f\n', median(results(testcase, :, 6)), median(results(testcase, :, 18)));
    fprintf('\tSAR: %03f\t%03f\n', median(results(testcase, :, 7)), median(results(testcase, :, 19)));
    fprintf('\tSDR: %03f\t%03f\n', median(results(testcase, :, 8)), median(results(testcase, :, 20)));
    fprintf('\tqTarget: %03f\t%03f\n', median(results(testcase, :, 9)), median(results(testcase, :, 21)));
    fprintf('\tqInterf: %03f\t%03f\n', median(results(testcase, :, 10)), median(results(testcase, :, 22)));
    fprintf('\tqArtif: %03f\t%03f\n', median(results(testcase, :, 11)), median(results(testcase, :, 23)));
    fprintf('\tqGlobal: %03f\t%03f\n', median(results(testcase, :, 12)), median(results(testcase, :, 24))); 
end