% include vendored PEASS code
addpath(genpath('vendor/PEASS-Software-v2.0.1'));

files = dir('data-vocal/*.wav');
resultsDir = 'results-vocal';

resultSize = floor(size(files, 1)/4);
results = zeros(16, resultSize, 12);

testNames = {...
    'mf'...
    'mf-cqt1'...
    'mf-cqt2'...
    'mf-cqt3'...
};

testFuncs = {...
    @(fname, dest) Fitzgerald_Multipass(fname, dest)...
    @(fname, dest) Fitzgerald_Multipass(fname, dest, "HiResSTFT", "cqt")...
    @(fname, dest) Fitzgerald_Multipass(fname, dest, "LoResSTFT", "cqt")...
    @(fname, dest) Fitzgerald_Multipass(fname, dest, "HiResSTFT", "cqt", "LoResSTFT", "cqt")...
};

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
        
        for testcase = 1:4
            tname = testNames{testcase};
            tfunc = testFuncs{testcase};
            
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
            results(testcase, findex, 5) = resP.OPS;
            results(testcase, findex, 6) = resP.TPS;
            results(testcase, findex, 7) = resP.IPS;
            results(testcase, findex, 8) = resP.APS;
            results(testcase, findex, 9) = resV.OPS;
            results(testcase, findex, 10) = resV.TPS;
            results(testcase, findex, 11) = resV.IPS;
            results(testcase, findex, 12) = resV.APS;
        end
        findex = findex + 1;
    end
end

fprintf('*************************\n');
fprintf('****  FINAL RESULTS  ****\n');
fprintf('*************************\n');

for testcase = 1:4
    tname = testNames{testcase};
    
    fprintf('%s, median scores\n', tname)
    fprintf('\tHarm OPS: %03f\n', median(results(testcase, :, 1)));
    fprintf('\tPerc OPS: %03f\n', median(results(testcase, :, 5)));
    fprintf('\tVocal OPS: %03f\n', median(results(testcase, :, 9)));
end