% include vendored PEASS code
addpath(genpath('vendor/PEASS-Software-v2.0.1'));

files = dir('data-vocal/*.wav');
resultsDir = 'results-vocal';

testCases = {...
    {'mf', @(fname, dest) Fitzgerald_Multipass(fname, dest)}...
    ...{'mf-cqt1', @(fname, dest) Fitzgerald_Multipass(fname, dest, "HiResSTFT", "cqt")}...
    {'mf-cqt2', @(fname, dest) Fitzgerald_Multipass(fname, dest, "LoResSTFT", "cqt")}...
    ...{'mf-cqt3', @(fname, dest) Fitzgerald_Multipass(fname, dest, "HiResSTFT", "cqt", "LoResSTFT", "cqt")}...
    {'hybrid', @(fname, dest) HarmonicPercussiveVocal(fname, dest)}...
};

resultSize = floor(size(files, 1)/4);
results = zeros(size(testCases, 2), resultSize, 36);

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
            sprintf('%s/%s_percussive.wav', file.folder, prefix);...
            sprintf('%s/%s_vocal.wav', file.folder, prefix)};

        percOriginalFiles = {...
            sprintf('%s/%s_percussive.wav', file.folder, prefix);...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix);...
            sprintf('%s/%s_vocal.wav', file.folder, prefix)};
        
        vocalOriginalFiles = {
            sprintf('%s/%s_vocal.wav', file.folder, prefix);...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix);...
            sprintf('%s/%s_percussive.wav', file.folder, prefix)};
        
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
            resV = PEASS_ObjectiveMeasure(vocalOriginalFiles,...
                sprintf('%s/%s_vocal.wav', destloc, prefix), options);
            
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
            
            results(testcase, findex, 25) = resV.OPS;
            results(testcase, findex, 26) = resV.TPS;
            results(testcase, findex, 27) = resV.IPS;
            results(testcase, findex, 28) = resV.APS;
            results(testcase, findex, 29) = resV.ISR;
            results(testcase, findex, 30) = resV.SIR;
            results(testcase, findex, 31) = resV.SAR;
            results(testcase, findex, 32) = resV.SDR;
            results(testcase, findex, 33) = resV.qTarget;
            results(testcase, findex, 34) = resV.qInterf;
            results(testcase, findex, 35) = resV.qArtif;
            results(testcase, findex, 36) = resV.qGlobal;
        end
        findex = findex + 1;
    end
end

fprintf('*************************\n');
fprintf('****  FINAL RESULTS  ****\n');
fprintf('*************************\n');

for testcase = 1:size(testCases, 2)
    fprintf('%s, median scores\n', testCases{testcase}{1});
    fprintf('\tOPS: %03f\t%03f\t%03f\n', median(results(testcase, :, 1)), median(results(testcase, :, 13)), median(results(testcase, :, 25)));
    fprintf('\tTPS: %03f\t%03f\t%03f\n', median(results(testcase, :, 2)), median(results(testcase, :, 14)), median(results(testcase, :, 26)));
    fprintf('\tIPS: %03f\t%03f\t%03f\n', median(results(testcase, :, 3)), median(results(testcase, :, 15)), median(results(testcase, :, 27)));
    fprintf('\tAPS: %03f\t%03f\t%03f\n', median(results(testcase, :, 4)), median(results(testcase, :, 16)), median(results(testcase, :, 28))); 
    fprintf('\tISR: %03f\t%03f\t%03f\n', median(results(testcase, :, 5)), median(results(testcase, :, 17)), median(results(testcase, :, 29)));
    fprintf('\tSIR: %03f\t%03f\t%03f\n', median(results(testcase, :, 6)), median(results(testcase, :, 18)), median(results(testcase, :, 30)));
    fprintf('\tSAR: %03f\t%03f\t%03f\n', median(results(testcase, :, 7)), median(results(testcase, :, 19)), median(results(testcase, :, 31)));
    fprintf('\tSDR: %03f\t%03f\t%03f\n', median(results(testcase, :, 8)), median(results(testcase, :, 20)), median(results(testcase, :, 32)));
    fprintf('\tqTarget: %03f\t%0f\t%03f\n', median(results(testcase, :, 9)), median(results(testcase, :, 21)), median(results(testcase, :, 33)));
    fprintf('\tqInterf: %03f\t%03f\t%03f\n', median(results(testcase, :, 10)), median(results(testcase, :, 22)), median(results(testcase, :, 34)));
    fprintf('\tqArtif: %03f\t%03f\t%03f\n', median(results(testcase, :, 11)), median(results(testcase, :, 23)), median(results(testcase, :, 35)));
    fprintf('\tqGlobal: %03f\t%03f\t%03f\n', median(results(testcase, :, 12)), median(results(testcase, :, 24)), median(results(testcase, :, 36))); 
end