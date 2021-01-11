% include vendored PEASS code
addpath(genpath('vendor/PEASS-Software-v2.0.1'));

files = dir('data_chunked/*.wav');
resultSize = floor(size(files, 1)/3);

% results are stored indexed as follows
% 1 = Overall Perceptual Score
% 2 = Target-related Perceptual Score
% 3 = Interference-related Perceptual Score
% 4 = Artifact-related Perceptual Score

resultsFH = zeros(resultSize, 4);
resultsFP = zeros(resultSize, 4);
resultsDH = zeros(resultSize, 4);
resultsDP = zeros(resultSize, 4);

options.destDir = '/tmp/';
options.segmentationFactor = 1;

findex = 1;

for file = files'
    fname = sprintf('%s/%s', file.folder, file.name);
    
    if contains(fname, "mix")
        HPSS(fname, 'fitzgerald', 'mask', 'soft');
        HPSS(fname, 'driedger', 'mask', 'hard');
    
        % then evaluate it
        splt = split(file.name,"_");
        prefix = splt{1};
        
        harmOriginalFiles = {...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix);...
            sprintf('%s/%s_percussive.wav', file.folder, prefix)};

        percOriginalFiles = {...
            sprintf('%s/%s_percussive.wav', file.folder, prefix);...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix)};

        fHarmEstimateFile = sprintf('fitzgerald/%s_harmonic.wav', prefix);
        dHarmEstimateFile = sprintf('driedger/%s_harmonic.wav', prefix);
        fPercEstimateFile = sprintf('fitzgerald/%s_percussive.wav', prefix);
        dPercEstimateFile = sprintf('driedger/%s_percussive.wav', prefix);
        
        resFH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            fHarmEstimateFile,options);
    
        resDH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            dHarmEstimateFile,options);

        resFP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            fPercEstimateFile,options);

        resDP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            dPercEstimateFile,options);
        
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
        
        findex = findex + 1;
    end
end

fprintf('*************************\n');
fprintf('****  FINAL RESULTS  ****\n');
fprintf('*************************\n');
    
fprintf('Fitzgerald (soft mask), harmonic\n');
fprintf("%s\n", mat2str(resultsFH));

fprintf('Fitzgerald (soft mask), percussive\n');
fprintf("%s\n", mat2str(resultsFP));

fprintf('Driedger (hard mask), harmonic\n');
fprintf("%s\n", mat2str(resultsDH));

fprintf('Driedger (hard mask), percussive\n');
fprintf("%s\n", mat2str(resultsDP));