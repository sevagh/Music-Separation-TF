files = dir('data_chunked/*.wav');
for file = files'
    fname = sprintf('%s/%s', file.folder, file.name);
    if contains(fname, "mix")
        HPSS(fname, 'fitzgerald', 'mask', 'soft');
        HPSS(fname, 'driedger', 'mask', 'hard');
    end
    % Do some stuff
end

for i = 4:4
    prefix = sprintf("%02d000", i);
    
    %%%%%%%%%%%%
    % Set inputs
    %%%%%%%%%%%%
    harmOriginalFiles = {...
        sprintf('data_chunked/%s_harmonic.wav', prefix);...
        sprintf('data_chunked/%s_percussive.wav', prefix)};
    
    percOriginalFiles = {...
        sprintf('data_chunked/%s_percussive.wav', prefix);...
        sprintf('data_chunked/%s_harmonic.wav', prefix)};
    
    fHarmEstimateFile = sprintf('fitzgerald/%s_mix_harm_sep.wav', prefix);
    dHarmEstimateFile = sprintf('driedger/%s_mix_harm_sep.wav', prefix);
    fPercEstimateFile = sprintf('fitzgerald/%s_mix_perc_sep.wav', prefix);
    dPercEstimateFile = sprintf('driedger/%s_mix_perc_sep.wav', prefix);

    %%%%%%%%%%%%%
    % Set options
    %%%%%%%%%%%%%
    options.destDir = '/tmp/';
    options.segmentationFactor = 1; % increase this integer if you experienced "out of memory" problems

    %%%%%%%%%%%%%%%%%%%%
    % Call main function
    %%%%%%%%%%%%%%%%%%%%
    resFH = PEASS_ObjectiveMeasure(harmOriginalFiles,fHarmEstimateFile,...
        options);
    
    resDH = PEASS_ObjectiveMeasure(harmOriginalFiles,dHarmEstimateFile,...
        options);
    
    resFP = PEASS_ObjectiveMeasure(percOriginalFiles,fPercEstimateFile,...
        options);
    
    resDP = PEASS_ObjectiveMeasure(percOriginalFiles,dPercEstimateFile,...
        options);
    
    %%%%%%%%%%%%%%%%%
    % Display results
    %%%%%%%%%%%%%%%%%

    fprintf('*************************\n');
    fprintf('****  FINAL RESULTS  ****\n');
    fprintf('*************************\n');
    
    fprintf('Fitzgerald (soft mask), harmonic\n');
    fprintf(' - Overall Perceptual Score: OPS = %.f/100\n',resFH.OPS)
    fprintf(' - Target-related Perceptual Score: TPS = %.f/100\n',resFH.TPS)
    fprintf(' - Interference-related Perceptual Score: IPS = %.f/100\n',resFH.IPS)
    fprintf(' - Artifact-related Perceptual Score: APS = %.f/100\n',resFH.APS);
    
    fprintf('Fitzgerald (soft mask), percussive\n');
    fprintf(' - Overall Perceptual Score: OPS = %.f/100\n',resFP.OPS)
    fprintf(' - Target-related Perceptual Score: TPS = %.f/100\n',resFP.TPS)
    fprintf(' - Interference-related Perceptual Score: IPS = %.f/100\n',resFP.IPS)
    fprintf(' - Artifact-related Perceptual Score: APS = %.f/100\n',resFP.APS);
    
    fprintf('Driedger (hard mask), harmonic\n');
    fprintf(' - Overall Perceptual Score: OPS = %.f/100\n',resDH.OPS)
    fprintf(' - Target-related Perceptual Score: TPS = %.f/100\n',resDH.TPS)
    fprintf(' - Interference-related Perceptual Score: IPS = %.f/100\n',resDH.IPS)
    fprintf(' - Artifact-related Perceptual Score: APS = %.f/100\n',resDH.APS);
    
    fprintf('Driedger (hard mask), percussive\n');
    fprintf(' - Overall Perceptual Score: OPS = %.f/100\n',resDP.OPS)
    fprintf(' - Target-related Perceptual Score: TPS = %.f/100\n',resDP.TPS)
    fprintf(' - Interference-related Perceptual Score: IPS = %.f/100\n',resDP.IPS)
    fprintf(' - Artifact-related Perceptual Score: APS = %.f/100\n',resDP.APS);
end