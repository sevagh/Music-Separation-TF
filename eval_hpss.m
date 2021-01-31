% include vendored PEASS code
addpath(genpath('vendor/PEASS-Software-v2.0.1'));

files = dir('data-hpss/*.wav');

resultSize = floor(size(files, 1)/3);

resultsID = zeros(resultSize, 8);
resultsID_CQTLo = zeros(resultSize, 8);
resultsID_CQTHi = zeros(resultSize, 8);
resultsID_CQT = zeros(resultSize, 8);
resultsF = zeros(resultSize, 8);
resultsD = zeros(resultSize, 8);
resultsF_CQT = zeros(resultSize, 8);
resultsD_CQT = zeros(resultSize, 8);

options.destDir = '/tmp/';
options.segmentationFactor = 1;

findex = 1;

for file = files'
    fname = sprintf('%s/%s', file.folder, file.name);
    
    if contains(fname, "mix")
        display(fname)
        Driedger_Iterative(fname, 'results/id');
        Driedger_Iterative(fname, 'results/id-cqt1', "HiResSTFT", "cqt");
        Driedger_Iterative(fname, 'results/id-cqt2', "LoResSTFT", "cqt");
        Driedger_Iterative(fname, 'results/id-cqt3', "HiResSTFT", "cqt", "LoResSTFT", "cqt");
        HPSS_1pass(fname, 'results/1pass-hpss-d', "mask", "hard");
        HPSS_1pass(fname, 'results/1pass-hpss-f', "mask", "soft");
        HPSS_1pass(fname, 'results/1pass-hpss-d-cqt', "mask", "hard", "STFT", "cqt");
        HPSS_1pass(fname, 'results/1pass-hpss-f-cqt', "mask", "soft", "STFT", "cqt");
    
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
        id_cqt1HarmEstimateFile = sprintf('results/id-cqt1/%s_harmonic.wav', prefix);
        id_cqt1PercEstimateFile = sprintf('results/id-cqt1/%s_percussive.wav', prefix);
        id_cqt2HarmEstimateFile = sprintf('results/id-cqt2/%s_harmonic.wav', prefix);
        id_cqt2PercEstimateFile = sprintf('results/id-cqt2/%s_percussive.wav', prefix);
        id_cqt3HarmEstimateFile = sprintf('results/id-cqt3/%s_harmonic.wav', prefix);
        id_cqt3PercEstimateFile = sprintf('results/id-cqt3/%s_percussive.wav', prefix);
        dHarmEstimateFile = sprintf('results/1pass-hpss-d/%s_harmonic.wav', prefix);
        dPercEstimateFile = sprintf('results/1pass-hpss-d/%s_percussive.wav', prefix);
        d_cqtHarmEstimateFile = sprintf('results/1pass-hpss-d-cqt/%s_harmonic.wav', prefix);
        d_cqtPercEstimateFile = sprintf('results/1pass-hpss-d-cqt/%s_percussive.wav', prefix);
        fHarmEstimateFile = sprintf('results/1pass-hpss-f/%s_harmonic.wav', prefix);
        fPercEstimateFile = sprintf('results/1pass-hpss-f/%s_percussive.wav', prefix);
        f_cqtHarmEstimateFile = sprintf('results/1pass-hpss-f-cqt/%s_harmonic.wav', prefix);
        f_cqtPercEstimateFile = sprintf('results/1pass-hpss-f-cqt/%s_percussive.wav', prefix);
        
        resIDH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            idHarmEstimateFile, options);
        resIDP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            idPercEstimateFile,options);
        resID_CQT1H = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            id_cqt1HarmEstimateFile,options);
        resID_CQT1P = PEASS_ObjectiveMeasure(percOriginalFiles,...
            id_cqt1PercEstimateFile,options);
        resID_CQT2H = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            id_cqt2HarmEstimateFile,options);
        resID_CQT2P = PEASS_ObjectiveMeasure(percOriginalFiles,...
            id_cqt2PercEstimateFile,options);
        resID_CQT3H = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            id_cqt3HarmEstimateFile,options);
        resID_CQT3P = PEASS_ObjectiveMeasure(percOriginalFiles,...
            id_cqt3PercEstimateFile,options);
        resDH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            dHarmEstimateFile,options);
        resDP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            dPercEstimateFile,options);
        resFH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            fHarmEstimateFile,options);
        resFP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            fPercEstimateFile,options);
        resD_CQTH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            d_cqtHarmEstimateFile,options);
        resD_CQTP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            d_cqtPercEstimateFile,options);
        resF_CQTH = PEASS_ObjectiveMeasure(harmOriginalFiles,...
            f_cqtHarmEstimateFile,options);
        resF_CQTP = PEASS_ObjectiveMeasure(percOriginalFiles,...
            f_cqtPercEstimateFile,options);
        
        resultsID(findex, 1) = resIDH.OPS;
        resultsID(findex, 2) = resIDH.TPS;
        resultsID(findex, 3) = resIDH.IPS;
        resultsID(findex, 4) = resIDH.APS;
        resultsID(findex, 5) = resIDP.OPS;
        resultsID(findex, 6) = resIDP.TPS;
        resultsID(findex, 7) = resIDP.IPS;
        resultsID(findex, 8) = resIDP.APS;
        
        resultsID_CQTHi(findex, 1) = resID_CQT1H.OPS;
        resultsID_CQTHi(findex, 2) = resID_CQT1H.TPS;
        resultsID_CQTHi(findex, 3) = resID_CQT1H.IPS;
        resultsID_CQTHi(findex, 4) = resID_CQT1H.APS;
        resultsID_CQTHi(findex, 5) = resID_CQT1P.OPS;
        resultsID_CQTHi(findex, 6) = resID_CQT1P.TPS;
        resultsID_CQTHi(findex, 7) = resID_CQT1P.IPS;
        resultsID_CQTHi(findex, 8) = resID_CQT1P.APS;
        
        resultsID_CQTLo(findex, 1) = resID_CQT2H.OPS;
        resultsID_CQTLo(findex, 2) = resID_CQT2H.TPS;
        resultsID_CQTLo(findex, 3) = resID_CQT2H.IPS;
        resultsID_CQTLo(findex, 4) = resID_CQT2H.APS;
        resultsID_CQTLo(findex, 5) = resID_CQT2P.OPS;
        resultsID_CQTLo(findex, 6) = resID_CQT2P.TPS;
        resultsID_CQTLo(findex, 7) = resID_CQT2P.IPS;
        resultsID_CQTLo(findex, 8) = resID_CQT2P.APS;
               
        resultsID_CQT(findex, 1) = resID_CQT3H.OPS;
        resultsID_CQT(findex, 2) = resID_CQT3H.TPS;
        resultsID_CQT(findex, 3) = resID_CQT3H.IPS;
        resultsID_CQT(findex, 4) = resID_CQT3H.APS;
        resultsID_CQT(findex, 5) = resID_CQT3P.OPS;
        resultsID_CQT(findex, 6) = resID_CQT3P.TPS;
        resultsID_CQT(findex, 7) = resID_CQT3P.IPS;
        resultsID_CQT(findex, 8) = resID_CQT3P.APS;
        
        resultsD(findex, 1) = resDH.OPS;
        resultsD(findex, 2) = resDH.TPS;
        resultsD(findex, 3) = resDH.IPS;
        resultsD(findex, 4) = resDH.APS;
        resultsD(findex, 5) = resDP.OPS;
        resultsD(findex, 6) = resDP.TPS;
        resultsD(findex, 7) = resDP.IPS;
        resultsD(findex, 8) = resDP.APS;
        
        resultsF(findex, 1) = resFH.OPS;
        resultsF(findex, 2) = resFH.TPS;
        resultsF(findex, 3) = resFH.IPS;
        resultsF(findex, 4) = resFH.APS;
        resultsF(findex, 5) = resFP.OPS;
        resultsF(findex, 6) = resFP.TPS;
        resultsF(findex, 7) = resFP.IPS;
        resultsF(findex, 8) = resFP.APS;
        
        resultsD_CQT(findex, 1) = resD_CQTH.OPS;
        resultsD_CQT(findex, 2) = resD_CQTH.TPS;
        resultsD_CQT(findex, 3) = resD_CQTH.IPS;
        resultsD_CQT(findex, 4) = resD_CQTH.APS;
        resultsD_CQT(findex, 5) = resD_CQTP.OPS;
        resultsD_CQT(findex, 6) = resD_CQTP.TPS;
        resultsD_CQT(findex, 7) = resD_CQTP.IPS;
        resultsD_CQT(findex, 8) = resD_CQTP.APS;
        
        resultsF_CQT(findex, 1) = resF_CQTH.OPS;
        resultsF_CQT(findex, 2) = resF_CQTH.TPS;
        resultsF_CQT(findex, 3) = resF_CQTH.IPS;
        resultsF_CQT(findex, 4) = resF_CQTH.APS;
        resultsF_CQT(findex, 5) = resF_CQTP.OPS;
        resultsF_CQT(findex, 6) = resF_CQTP.TPS;
        resultsF_CQT(findex, 7) = resF_CQTP.IPS;
        resultsF_CQT(findex, 8) = resF_CQTP.APS;
        
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
    
fprintf('Iterative Driedger (default settings), median scores\n')
fprintf('\tHarm OPS: %03f\n', median(resultsID(:, 1)));
fprintf('\tHarm TPS: %03f\n', median(resultsID(:, 2)));
fprintf('\tHarm IPS: %03f\n', median(resultsID(:, 3)));
fprintf('\tHarm APS: %03f\n', median(resultsID(:, 4)));
fprintf('\tPerc OPS: %03f\n', median(resultsID(:, 5)));
fprintf('\tPerc TPS: %03f\n', median(resultsID(:, 6)));
fprintf('\tPerc IPS: %03f\n', median(resultsID(:, 7)));
fprintf('\tPerc APS: %03f\n', median(resultsID(:, 8)));

fprintf('Iterative Driedger, high-res CQT, median scores\n')
fprintf('\tHarm OPS: %03f\n', median(resultsID_CQTHi(:, 1)));
fprintf('\tHarm TPS: %03f\n', median(resultsID_CQTHi(:, 2)));
fprintf('\tHarm IPS: %03f\n', median(resultsID_CQTHi(:, 3)));
fprintf('\tHarm APS: %03f\n', median(resultsID_CQTHi(:, 4)));
fprintf('\tPerc OPS: %03f\n', median(resultsID_CQTHi(:, 5)));
fprintf('\tPerc TPS: %03f\n', median(resultsID_CQTHi(:, 6)));
fprintf('\tPerc IPS: %03f\n', median(resultsID_CQTHi(:, 7)));
fprintf('\tPerc APS: %03f\n', median(resultsID_CQTHi(:, 8)));

fprintf('Iterative Driedger, low-res CQT, median scores\n')
fprintf('\tHarm OPS: %03f\n', median(resultsID_CQTLo(:, 1)));
fprintf('\tHarm TPS: %03f\n', median(resultsID_CQTLo(:, 2)));
fprintf('\tHarm IPS: %03f\n', median(resultsID_CQTLo(:, 3)));
fprintf('\tHarm APS: %03f\n', median(resultsID_CQTLo(:, 4)));
fprintf('\tPerc OPS: %03f\n', median(resultsID_CQTLo(:, 5)));
fprintf('\tPerc TPS: %03f\n', median(resultsID_CQTLo(:, 6)));
fprintf('\tPerc IPS: %03f\n', median(resultsID_CQTLo(:, 7)));
fprintf('\tPerc APS: %03f\n', median(resultsID_CQTLo(:, 8)));

fprintf('Iterative Driedger, both CQT, median scores\n')
fprintf('\tHarm OPS: %03f\n', median(resultsID_CQT(:, 1)));
fprintf('\tHarm TPS: %03f\n', median(resultsID_CQT(:, 2)));
fprintf('\tHarm IPS: %03f\n', median(resultsID_CQT(:, 3)));
fprintf('\tHarm APS: %03f\n', median(resultsID_CQT(:, 4)));
fprintf('\tPerc OPS: %03f\n', median(resultsID_CQT(:, 5)));
fprintf('\tPerc TPS: %03f\n', median(resultsID_CQT(:, 6)));
fprintf('\tPerc IPS: %03f\n', median(resultsID_CQT(:, 7)));
fprintf('\tPerc APS: %03f\n', median(resultsID_CQT(:, 8)));

fprintf('1-pass Driedger (default), median scores\n')
fprintf('\tHarm OPS: %03f\n', median(resultsD(:, 1)));
fprintf('\tHarm TPS: %03f\n', median(resultsD(:, 2)));
fprintf('\tHarm IPS: %03f\n', median(resultsD(:, 3)));
fprintf('\tHarm APS: %03f\n', median(resultsD(:, 4)));
fprintf('\tPerc OPS: %03f\n', median(resultsD(:, 5)));
fprintf('\tPerc TPS: %03f\n', median(resultsD(:, 6)));
fprintf('\tPerc IPS: %03f\n', median(resultsD(:, 7)));
fprintf('\tPerc APS: %03f\n', median(resultsD(:, 8)));

fprintf('1-pass Driedger, CQT, median scores\n')
fprintf('\tHarm OPS: %03f\n', median(resultsD_CQT(:, 1)));
fprintf('\tHarm TPS: %03f\n', median(resultsD_CQT(:, 2)));
fprintf('\tHarm IPS: %03f\n', median(resultsD_CQT(:, 3)));
fprintf('\tHarm APS: %03f\n', median(resultsD_CQT(:, 4)));
fprintf('\tPerc OPS: %03f\n', median(resultsD_CQT(:, 5)));
fprintf('\tPerc TPS: %03f\n', median(resultsD_CQT(:, 6)));
fprintf('\tPerc IPS: %03f\n', median(resultsD_CQT(:, 7)));
fprintf('\tPerc APS: %03f\n', median(resultsD_CQT(:, 8)));

fprintf('1-pass Fitzgerald (default), median scores\n')
fprintf('\tHarm OPS: %03f\n', median(resultsF(:, 1)));
fprintf('\tHarm TPS: %03f\n', median(resultsF(:, 2)));
fprintf('\tHarm IPS: %03f\n', median(resultsF(:, 3)));
fprintf('\tHarm APS: %03f\n', median(resultsF(:, 4)));
fprintf('\tPerc OPS: %03f\n', median(resultsF(:, 5)));
fprintf('\tPerc TPS: %03f\n', median(resultsF(:, 6)));
fprintf('\tPerc IPS: %03f\n', median(resultsF(:, 7)));
fprintf('\tPerc APS: %03f\n', median(resultsF(:, 8)));

fprintf('1-pass Fitzgerald, CQT, median scores\n')
fprintf('\tHarm OPS: %03f\n', median(resultsF_CQT(:, 1)));
fprintf('\tHarm TPS: %03f\n', median(resultsF_CQT(:, 2)));
fprintf('\tHarm IPS: %03f\n', median(resultsF_CQT(:, 3)));
fprintf('\tHarm APS: %03f\n', median(resultsF_CQT(:, 4)));
fprintf('\tPerc OPS: %03f\n', median(resultsF_CQT(:, 5)));
fprintf('\tPerc TPS: %03f\n', median(resultsF_CQT(:, 6)));
fprintf('\tPerc IPS: %03f\n', median(resultsF_CQT(:, 7)));
fprintf('\tPerc APS: %03f\n', median(resultsF_CQT(:, 8)));