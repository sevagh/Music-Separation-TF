% include vendored PEASS code
addpath(genpath('vendor/PEASS-Software-v2.0.1'));

files = dir('data-hpv/*.wav');
resultSize = floor(size(files, 1)/4);

resultsMFH = zeros(resultSize, 4);

resultsMFP = zeros(resultSize, 4);
resultsMFV = zeros(resultSize, 4);

resultsMF_CQTP = zeros(resultSize, 4);
resultsMF_CQTV = zeros(resultSize, 4);

resultsMF_WSTFTP = zeros(resultSize, 4);
resultsMF_WSTFTV = zeros(resultSize, 4);

options.destDir = '/tmp/';
options.segmentationFactor = 1;

findex = 1;

for file = files'
    fname = sprintf('%s/%s', file.folder, file.name);
    
    if contains(fname, "mix")
        display(fname)
        HPVSS_Multipass_Fitzgerald(fname, 'results/mf', "LowResSTFT", "linear");
        HPVSS_Multipass_Fitzgerald(fname, 'results/mf-cqt', "LowResSTFT", "cqt");
        HPVSS_Multipass_Fitzgerald(fname, 'results/mf-wstft', "LowResSTFT", "linear");
    
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

        vocalOriginalFiles = {...
            sprintf('%s/%s_vocal.wav', file.folder, prefix);...
            sprintf('%s/%s_percussive.wav', file.folder, prefix);...
            sprintf('%s/%s_harmonic.wav', file.folder, prefix)};

        % 2 pass fitzgerald + variant
        mfHarmEstimateFile = sprintf('results/mf/%s_harmonic.wav', prefix);
        mfPercEstimateFile = sprintf('results/mf/%s_percussive.wav', prefix);
        mfVocalEstimateFile = sprintf('results/mf/%s_vocal.wav', prefix);
        
        mf_cqtPercEstimateFile = sprintf('results/mf-cqt/%s_percussive.wav', prefix);
        mf_cqtVocalEstimateFile = sprintf('results/mf-cqt/%s_vocal.wav', prefix);
        
        mf_wstftPercEstimateFile = sprintf('results/mf-wstft/%s_percussive.wav', prefix);
        mf_wstftVocalEstimateFile = sprintf('results/mf-wsftf/%s_vocal.wav', prefix);
        
        resMFH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            mfHarmEstimateFile, options);
        resMFP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            mfPercEstimateFile,options);
        resMFV = PEASS_ObjectiveMeasure(vocalOriginalFiles,...
            mfVocalEstimateFile, options);
        
        resMF_CQTP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            mf_cqtPercEstimateFile,options);
        resMF_CQTV = PEASS_ObjectiveMeasure(vocalOriginalFiles,...
            mf_cqtVocalEstimateFile, options);
        
        resMF_WSTFTP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            mf_wstftPercEstimateFile,options);
        resMF_WSTFTV = PEASS_ObjectiveMeasure(vocalOriginalFiles,...
            mf_wstftVocalEstimateFile, options);
        
        resultsMFH(findex, 1) = resMFH.OPS;
        resultsMFH(findex, 2) = resMFH.TPS;
        resultsMFH(findex, 3) = resMFH.IPS;
        resultsMFH(findex, 4) = resMFH.APS;
        
        resultsMFP(findex, 1) = resMFP.OPS;
        resultsMFP(findex, 2) = resMFP.TPS;
        resultsMFP(findex, 3) = resMFP.IPS;
        resultsMFP(findex, 4) = resMFP.APS;
        
        resultsMFV(findex, 1) = resMFV.OPS;
        resultsMFV(findex, 2) = resMFV.TPS;
        resultsMFV(findex, 3) = resMFV.IPS;
        resultsMFV(findex, 4) = resMFV.APS;
        
        resultsMF_CQTP(findex, 1) = resMF_CQTTP.OPS;
        resultsMF_CQTP(findex, 2) = resMF_CQTP.TPS;
        resultsMF_CQTP(findex, 3) = resMF_CQTP.IPS;
        resultsMF_CQTP(findex, 4) = resMF_CQTP.APS;
        
        resultsMF_CQTV(findex, 1) = resMF_CQTV.OPS;
        resultsMF_CQTV(findex, 2) = resMF_CQTV.TPS;
        resultsMF_CQTV(findex, 3) = resMF_CQTV.IPS;
        resultsMF_CQTV(findex, 4) = resMF_CQTV.APS;
        
        resultsMF_WSTFTP(findex, 1) = resMF_WSTFTP.OPS;
        resultsMF_WSTFTP(findex, 2) = resMF_WSTFTP.TPS;
        resultsMF_WSTFTP(findex, 3) = resMF_WSTFTP.IPS;
        resultsMF_WSTFTP(findex, 4) = resMF_WSTFTP.APS;
        
        resultsMF_WSTFTV(findex, 1) = resMF_WSTFTV.OPS;
        resultsMF_WSTFTV(findex, 2) = resMF_WSTFTV.TPS;
        resultsMF_WSTFTV(findex, 3) = resMF_WSTFTV.IPS;
        resultsMF_WSTFTV(findex, 4) = resMF_WSTFTV.APS;
        
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
    
fprintf('Multipass Fitzgerald, harmonic median score\n')
fprintf('\tOPS: %03f\n', median(resultsMFH(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsMFH(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsMFH(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsMFH(:, 4)));

fprintf('Multipass Fitzgerald, percussive median score\n');
fprintf('\tOPS: %03f\n', median(resultsMFP(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsMFP(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsMFP(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsMFP(:, 4)));

fprintf('Multipass Fitzgerald + CQT, percussive median score\n');
fprintf('\tOPS: %03f\n', median(resultsMF_CQTP(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsMF_CQTP(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsMF_CQTP(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsMF_CQTP(:, 4)));

fprintf('Multipass Fitzgerald + WSTFT, percussive median score\n');
fprintf('\tOPS: %03f\n', median(resultsMF_WSTFTP(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsMF_WSTFTP(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsMF_WSTFTP(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsMF_WSTFTP(:, 4)));

fprintf('Multipass Fitzgerald, vocal median score\n');
fprintf('\tOPS: %03f\n', median(resultsMFV(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsMFV(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsMFV(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsMFV(:, 4)));

fprintf('Multipass Fitzgerald + CQT, vocal median score\n');
fprintf('\tOPS: %03f\n', median(resultsMF_CQTV(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsMF_CQTV(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsMF_CQTV(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsMF_CQTV(:, 4)));

fprintf('Multipass Fitzgerald + WSTFT, vocal median score\n');
fprintf('\tOPS: %03f\n', median(resultsMF_WSTFTV(:, 1)));
fprintf('\tTPS: %03f\n', median(resultsMF_WSTFTV(:, 2)));
fprintf('\tIPS: %03f\n', median(resultsMF_WSTFTV(:, 3)));
fprintf('\tAPS: %03f\n', median(resultsMF_WSTFTV(:, 4)));