function multibandTransientShaperSimpleWithPlots(path)
    [x, fs] = audioread(path);
    
    b = hz2bark([20, 20000]);
    barkVect = linspace(b(1), b(2), 5);
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
        
        figure;
        subplot(2,1,1);
        plot(fast);
        hold on;
        plot(slow);
        plot(fast - slow);
        legend('fast', 'slow', 'difference');
        title("Envelopes");
        
        subplot(2,1,2);
        plot(attack);
        hold on;
        plot(sustain);
        legend('attack', 'sustain');
        title("Gain curves");
        sgtitle(sprintf("Transient shaping, band %f-%f Hz", bandEdges(1),...
            bandEdges(2)));
        
        yTransientEnhanced = y .* attack;
        yTransientSuppressed = y .* sustain;
        
        figure;
        subplot(3,1,1);
        plot(y);
        ylim([-1 1]);
        title("Bandpassed waveform");
        subplot(3,1,2);
        plot(yTransientEnhanced);
        ylim([-1 1]);
        title("Transient enhanced");
        subplot(3,1,3);
        plot(yTransientSuppressed);
        ylim([-1 1]);
        title("Transient suppressed");
        
        sgtitle(sprintf("Waveforms, band %f-%f Hz", bandEdges(1),...
            bandEdges(2)));
        
        yEnhanced = yEnhanced + yTransientEnhanced;
        ySuppressed = ySuppressed + yTransientSuppressed;
    end
    
    yEnhanced = yEnhanced/max(abs(yEnhanced));
    ySuppressed = ySuppressed/max(abs(ySuppressed));
    
    figure;
    subplot(3,1,1);
    plot(x);
    ylim([-1 1]);
    title("Original waveform");
    subplot(3,1,2);
    plot(yEnhanced);
    ylim([-1 1]);
    title("Transient enhanced");
    subplot(3,1,3);
    plot(ySuppressed);
    ylim([-1 1]);
    title("Transient suppressed");
    sgtitle("Waveforms, bandwise transient shaping");
    
    [fast, slow, attack, sustain] = transientShaper(x, fs,...
            attackFastMs, attackSlowMs, releaseMs);
        
    figure;
    subplot(2,1,1);
    plot(fast);
    hold on;
    plot(slow);
    plot(fast-slow);
    legend('fast', 'slow', 'difference');
    title("Envelopes");

    subplot(2,1,2);
    plot(attack);
    hold on;
    plot(sustain);
    legend('attack', 'sustain');
    title("Gain curves");
    sgtitle("Transient shaping, full spectrum");

    yUnbandedEnhanced = x .* attack;
    yUnbandedSuppressed = x .* sustain;

    figure;
    subplot(3,1,1);
    plot(x);
    ylim([-1 1]);
    title("Original waveform");
    subplot(3,1,2);
    plot(yUnbandedEnhanced);
    ylim([-1 1]);
    title("Transient enhanced");
    subplot(3,1,3);
    plot(yUnbandedSuppressed);
    ylim([-1 1]);
    title("Transient suppressed");

    sgtitle("Waveforms, unbanded transient shaping");
end
