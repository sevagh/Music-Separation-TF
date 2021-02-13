function eval_vocal(contender)
[mypath, ~, ~] = fileparts(mfilename('fullpath'));
fprintf("MY PATH: %s\n", mypath);
files = dir(fullfile(mypath, '../data/data-vocal/*.wav'));
resultsDir = fullfile(mypath, './results-vocal');

if not(isfolder(resultsDir))
    mkdir(resultsDir)
end

display(contender);
run(contender); % load testCases from contender file

display(size(testCases))
if size(testCases, 2) < size(testCases, 1)
    testCases = testCases';
end
display(size(testCases))

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
            
            if not(isfolder(destloc))
                mkdir(destloc)
            end

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

s = struct();

for testcase = 1:size(testCases, 2)
    tname = matlab.lang.makeValidName(testCases{testcase}{1});
    
    s.harmonic_peass.(tname).OPS = median(results(testcase, :, 1));
    s.harmonic_peass.(tname).TPS = median(results(testcase, :, 2));
    s.harmonic_peass.(tname).IPS = median(results(testcase, :, 3));
    s.harmonic_peass.(tname).APS = median(results(testcase, :, 4));
    
    s.harmonic_bss.(tname).ISR = median(results(testcase, :, 5));
    s.harmonic_bss.(tname).SIR = median(results(testcase, :, 6));
    s.harmonic_bss.(tname).SAR = median(results(testcase, :, 7));
    s.harmonic_bss.(tname).SDR = median(results(testcase, :, 8));
    
    s.harmonic_pemoq.(tname).qTarget = median(results(testcase, :, 9));
    s.harmonic_pemoq.(tname).qInterf = median(results(testcase, :, 10));
    s.harmonic_pemoq.(tname).qArtif = median(results(testcase, :, 11));
    s.harmonic_pemoq.(tname).qGlobal = median(results(testcase, :, 12));
    
    s.percussive_peass.(tname).OPS = median(results(testcase, :, 13));
    s.percussive_peass.(tname).TPS = median(results(testcase, :, 14));
    s.percussive_peass.(tname).IPS = median(results(testcase, :, 15));
    s.percussive_peass.(tname).APS = median(results(testcase, :, 16));
    
    s.percussive_bss.(tname).ISR = median(results(testcase, :, 17));
    s.percussive_bss.(tname).SIR = median(results(testcase, :, 18));
    s.percussive_bss.(tname).SAR = median(results(testcase, :, 19));
    s.percussive_bss.(tname).SDR = median(results(testcase, :, 20));

    s.percussive_pemoq.(tname).qTarget = median(results(testcase, :, 21));
    s.percussive_pemoq.(tname).qInterf = median(results(testcase, :, 22));
    s.percussive_pemoq.(tname).qArtif = median(results(testcase, :, 23));
    s.percussive_pemoq.(tname).qGlobal = median(results(testcase, :, 24));
    
    s.vocal_peass.(tname).OPS = median(results(testcase, :, 25));
    s.vocal_peass.(tname).TPS = median(results(testcase, :, 26));
    s.vocal_peass.(tname).IPS = median(results(testcase, :, 27));
    s.vocal_peass.(tname).APS = median(results(testcase, :, 28));
    
    s.vocal_bss.(tname).ISR = median(results(testcase, :, 29));
    s.vocal_bss.(tname).SIR = median(results(testcase, :, 30));
    s.vocal_bss.(tname).SAR = median(results(testcase, :, 31));
    s.vocal_bss.(tname).SDR = median(results(testcase, :, 32));

    s.vocal_pemoq.(tname).qTarget = median(results(testcase, :, 33));
    s.vocal_pemoq.(tname).qInterf = median(results(testcase, :, 34));
    s.vocal_pemoq.(tname).qArtif = median(results(testcase, :, 35));
    s.vocal_pemoq.(tname).qGlobal = median(results(testcase, :, 36));
end

fprintf("%s\n", jsonencode(s));

end
