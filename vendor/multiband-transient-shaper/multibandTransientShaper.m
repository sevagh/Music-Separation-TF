function multibandTransientShaper(path)
    [x, fs] = audioread(path);
    
    b = hz2bark([20, 20000]);
    barkVect = linspace(b(1), b(2), 24);
    hzVect = bark2hz(barkVect);

    yEnhanced = zeros(size(x));
    ySuppressed = zeros(size(x));

    attackFastMs = 1;
    attackSlowMs = 15;
    releaseMs = 20;

    for bands = 1:1:size(hzVect, 2)-1
        bandEdges = hzVect(bands:bands+1);
        fprintf("band %f - %f Hz\n", bandEdges(1), bandEdges(2));
        
        y = bandpass(x, bandEdges, fs);
       
        [fast, slow, attack, sustain] = transientShaper(y, fs,...
            attackFastMs, attackSlowMs, releaseMs);

        yTransientEnhanced = y .* attack;
        yTransientSuppressed = y .* sustain;

        yEnhanced = yEnhanced + yTransientEnhanced;
        ySuppressed = ySuppressed + yTransientSuppressed;
    end
    
    yEnhanced = yEnhanced/max(abs(yEnhanced));
    ySuppressed = ySuppressed/max(abs(ySuppressed));

    audiowrite('enhanced.wav', yEnhanced, fs);
    audiowrite('suppressed.wav', ySuppressed, fs);
end
