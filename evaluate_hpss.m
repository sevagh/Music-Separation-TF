% include vendored PEASS code
addpath(genpath('vendor/PEASS-Software-v2.0.1'));

files = dir('data-hpss/*.wav');
resultSize = floor(size(files, 1)/3);

resultsIDH = zeros(resultSize, 4);

resultsIDP = zeros(resultSize, 4);
resultsID_CQTP = zeros(resultSize, 4);
resultsID_WSTFTP = zeros(resultSize, 4);

options.destDir = '/tmp/';
options.segmentationFactor = 1;

findex = 1;

for file = files'
    fname = sprintf('%s/%s', file.folder, file.name);
    
    if contains(fname, "mix")
        display(fname)
        Driedger_Iterative(fname, 'results/id', "LowResSTFT","linear");
        Driedger_Iterative(fname, 'results/id-cqt', "LowResSTFT","cqt");
        Driedger_Iterative(fname, 'results/id-wstft', "LowResSTFT","linear");
    
        % then evaluate it
        splt = split(file.name,"_");
        prefix = splt{1};
        
        harmOriginalFiles = {...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix);...
            sprintf('%s/%s_percussive.wav', file.folder, prefix)};

        percOriginalFiles = {...
            sprintf('%s/%s_percussive.wav', file.folder, prefix);...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix)};

        % 2 pass driedger + variants
        idHarmEstimateFile = sprintf('results/id/%s_harmonic.wav', prefix);
        idPercEstimateFile = sprintf('results/id/%s_percussive.wav', prefix);
        id_cqtPercEstimateFile = sprintf('results/id-cqt/%s_percussive.wav', prefix);
        id_wstftPercEstimateFile = sprintf('results/id-wstft/%s_percussive.wav', prefix);
        
        resIDH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            idHarmEstimateFile, options);
        resIDP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            idPercEstimateFile,options);
        resID_CQTP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            id_cqtPercEstimateFile,options);
        resID_WSTFTP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            id_wstftPercEstimateFile,options);
        
        resultsIDH(findex, 1) = resIDH.OPS;
        resultsIDH(findex, 2) = resIDH.TPS;
        resultsIDH(findex, 3) = resIDH.IPS;
        resultsIDH(findex, 4) = resIDH.APS;
        
        resultsIDP(findex, 1) = resIDP.OPS;
        resultsIDP(findex, 2) = resIDP.TPS;
        resultsIDP(findex, 3) = resIDP.IPS;
        resultsIDP(findex, 4) = resIDP.APS;
        
        resultsID_CQTP(findex, 1) = resID_CQTP.OPS;
        resultsID_CQTP(findex, 2) = resID_CQTP.TPS;
        resultsID_CQTP(findex, 3) = resID_CQTP.IPS;
        resultsID_CQTP(findex, 4) = resID_CQTP.APS;
        
        resultsID_WSTFTP(findex, 1) = resID_WSTFTP.OPS;
        resultsID_WSTFTP(findex, 2) = resID_WSTFTP.TPS;
        resultsID_WSTFTP(findex, 3) = resID_WSTFTP.IPS;
        resultsID_WSTFTP(findex, 4) = resID_WSTFTP.APS;
        
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
    
fprintf('Iterative Driedger, harmonic median score\n')
fprintf('\tOPS: %03f\n', median(resultsIDH(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsIDH(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsIDH(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsIDH(:, 4)));

fprintf('Iterative Driedger, percussive median score\n');
fprintf('\tOPS: %03f\n', median(resultsIDP(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsIDP(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsIDP(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsIDP(:, 4)));

fprintf('Iterative Driedger + CQT, percussive median score\n');
fprintf('\tOPS: %03f\n', median(resultsID_CQTP(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsID_CQTP(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsID_CQTP(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsID_CQTP(:, 4)));

fprintf('Iterative Driedger + WSTFT, percussive median score\n');
fprintf('\tOPS: %03f\n', median(resultsID_WSTFTP(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsID_WSTFTP(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsID_WSTFTP(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsID_WSTFTP(:, 4)));
