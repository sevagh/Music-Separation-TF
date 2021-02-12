function multibandTransientShaper(path)
    [x, fs] = audioread(path);

    attackFastMs = 1;
    attackSlowMs = 15;
    releaseMs = 20;
    
    [fast, slow, attack, sustain] = transientShaper(x, fs,...
        attackFastMs, attackSlowMs, releaseMs);
    
    yUnbandedEnhanced = x .* attack;
    yUnbandedSuppressed = x .* sustain;
    
    audiowrite("unbanded_enhanced.wav", yUnbandedEnhanced, fs);
    audiowrite("unbanded_suppressed.wav", yUnbandedSuppressed, fs);
end
