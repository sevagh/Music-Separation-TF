% include vendored PEASS code
addpath(genpath('vendor/PEASS-Software-v2.0.1'));

files = dir('data/*.wav');
resultSize = floor(size(files, 1)/3);

resultsFH = zeros(resultSize, 4);
resultsFP = zeros(resultSize, 4);
resultsDH = zeros(resultSize, 4);
resultsDP = zeros(resultSize, 4);
resultsIDH = zeros(resultSize, 4);
resultsIDP = zeros(resultSize, 4);
resultsCQTH = zeros(resultSize, 4);
resultsCQTP = zeros(resultSize, 4);

options.destDir = '/tmp/';
options.segmentationFactor = 1;

findex = 1;

for file = files'
    fname = sprintf('%s/%s', file.folder, file.name);
    
    if contains(fname, "mix")
        HPSS(fname, 'fitzgerald', 'mask', 'soft');
        HPSS(fname, 'driedger', 'mask', 'hard');
        HPSS_Iterative_Driedger(fname, 'iterative_driedger');
        HPSS_CQT(fname, 'cqt');
    
        % then evaluate it
        splt = split(file.name,"_");
        prefix = splt{1};
        
        harmOriginalFiles = {...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix);...
            sprintf('%s/%s_percussive.wav', file.folder, prefix)};

        percOriginalFiles = {...
            sprintf('%s/%s_percussive.wav', file.folder, prefix);...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix)};

        % 1 pass fitzgerald
        fHarmEstimateFile = sprintf('fitzgerald/%s_harmonic.wav', prefix);
        fPercEstimateFile = sprintf('fitzgerald/%s_percussive.wav', prefix);
        
        % 1 pass driedger
        dHarmEstimateFile = sprintf('driedger/%s_harmonic.wav', prefix);
        dPercEstimateFile = sprintf('driedger/%s_percussive.wav', prefix);
        
         % 2 pass driedger
        idHarmEstimateFile = sprintf('iterative_driedger/%s_harmonic.wav', prefix);
        idPercEstimateFile = sprintf('iterative_driedger/%s_percussive.wav', prefix);
        
        % cqt
        cqtHarmEstimateFile = sprintf('cqt/%s_harmonic.wav', prefix);
        cqtPercEstimateFile = sprintf('cqt/%s_percussive.wav', prefix);
        
        resFH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            fHarmEstimateFile,options);
        resFP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            fPercEstimateFile,options);
        
        resDH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            dHarmEstimateFile,options);
        resDP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            dPercEstimateFile,options);
        
        resIDH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            idHarmEstimateFile,options);
        resIDP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            idPercEstimateFile,options);
        
        resCQTH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            cqtHarmEstimateFile,options);
        resCQTP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            cqtPercEstimateFile,options);
        
        resultsFH(findex, 1) = resFH.OPS;
        resultsFH(findex, 2) = resFH.TPS;
        resultsFH(findex, 3) = resFH.IPS;
        resultsFH(findex, 4) = resFH.APS;
        
        resultsFP(findex, 1) = resFP.OPS;
        resultsFP(findex, 2) = resFP.TPS;
        resultsFP(findex, 3) = resFP.IPS;
        resultsFP(findex, 4) = resFP.APS;
        
        resultsDH(findex, 1) = resDH.OPS;
        resultsDH(findex, 2) = resDH.TPS;
        resultsDH(findex, 3) = resDH.IPS;
        resultsDH(findex, 4) = resDH.APS;
        
        resultsDP(findex, 1) = resDP.OPS;
        resultsDP(findex, 2) = resDP.TPS;
        resultsDP(findex, 3) = resDP.IPS;
        resultsDP(findex, 4) = resDP.APS;
        
        resultsIDH(findex, 1) = resIDH.OPS;
        resultsIDH(findex, 2) = resIDH.TPS;
        resultsIDH(findex, 3) = resIDH.IPS;
        resultsIDH(findex, 4) = resIDH.APS;
        
        resultsIDP(findex, 1) = resIDP.OPS;
        resultsIDP(findex, 2) = resIDP.TPS;
        resultsIDP(findex, 3) = resIDP.IPS;
        resultsIDP(findex, 4) = resIDP.APS;
        
        resultsCQTH(findex, 1) = resCQTH.OPS;
        resultsCQTH(findex, 2) = resCQTH.TPS;
        resultsCQTH(findex, 3) = resCQTH.IPS;
        resultsCQTH(findex, 4) = resCQTH.APS;
        
        resultsCQTP(findex, 1) = resCQTP.OPS;
        resultsCQTP(findex, 2) = resCQTP.TPS;
        resultsCQTP(findex, 3) = resCQTP.IPS;
        resultsCQTP(findex, 4) = resCQTP.APS;
        
        findex = findex + 1;
    end
end

% results are stored indexed as follows
% 1 = Overall Perceptual Score
% 2 = Target-related Perceptual Score
% 3 = Interference-related Perceptual Score
% 4 = Artifact-related Perceptual Score

% median scores
fprintf('*************************\n');
fprintf('****  FINAL RESULTS  ****\n');
fprintf('*************************\n');
    
fprintf('Fitzgerald (soft mask), harmonic\n')
fprintf('\tOPS: %03f\n', median(resultsFH(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsFH(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsFH(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsFH(:, 4)));

fprintf('Fitzgerald (soft mask), percussive, median score\n');
fprintf('\tOPS: %03f\n', median(resultsFP(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsFP(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsFP(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsFP(:, 4)));

fprintf('Driedger (hard mask), harmonic, median score\n');
fprintf('\tOPS: %03f\n', median(resultsDH(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsDH(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsDH(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsDH(:, 4)));

fprintf('Driedger (hard mask), percussive, median score\n');
fprintf('\tOPS: %03f\n', median(resultsDP(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsDP(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsDP(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsDP(:, 4)));

fprintf('Iterative Driedger (hard mask), harmonic, median score\n');
fprintf('\tOPS: %03f\n', median(resultsIDH(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsIDH(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsIDH(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsIDH(:, 4)));

fprintf('Iterative Driedger (hard mask), percussive, median score\n');
fprintf('\tOPS: %03f\n', median(resultsIDP(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsIDP(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsIDP(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsIDP(:, 4)));

fprintf('CQT, harmonic, median score\n');
fprintf('\tOPS: %03f\n', median(resultsCQTH(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsCQTH(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsCQTH(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsCQTH(:, 4)));

fprintf('CQT, percussive, median score\n');
fprintf('\tOPS: %03f\n', median(resultsCQTP(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsCQTP(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsCQTP(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsCQTP(:, 4)));