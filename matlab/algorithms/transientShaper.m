function [fastEnv, slowEnv, attackEnv, sustainEnv] = transientShaper(...
    x, fs, attackFastMs, attackSlowMs, releaseMs)

    % params
    gAttFast = exp(-1/(fs*attackFastMs/1000));
    gAttSlow = exp(-1/(fs*attackSlowMs/1000));
    gRelease = exp(-1/(fs*releaseMs/1000));

    fbFast = 0; % feedback terms
    fbSlow = 0;

    N = length(x);

    fastEnv = zeros(N, 1);
    slowEnv = zeros(N, 1);

    xPow = zeros(N, 1);
    powerMemoryMs = 1;
    gPowMem = exp(-1/(fs*powerMemoryMs/1000));
    fbPowMem = 0; % feedback term

    % signal power
    for n = 1:N
        xPow(n, 1) = (1 - gPowMem)* x(n) * x(n) + gPowMem*fbPowMem;
        fbPowMem = xPow(n, 1);
    end

    % derivative of signal power with simple 1-sample differentiator
    xDerivativePower = zeros(N, 1);

    xDerivativePower(1, 1) = xPow(1, 1);

    for n = 2:N
        xDerivativePower(n, 1) = xPow(n, 1) - xPow(n-1, 1);
    end

    attackEnv = zeros(N, 1);

    for n = 1:N
        if fbFast > xDerivativePower(n, 1)
            fastEnv(n, 1) = (1 - gRelease) * xDerivativePower(n, 1) +...
                gRelease * fbFast;
        else
            fastEnv(n, 1) = (1 - gAttFast) * xDerivativePower(n, 1) +...
                gAttFast * fbFast;
        end
        fbFast = fastEnv(n, 1);

        if fbSlow > xDerivativePower(n, 1)
            slowEnv(n, 1) = (1 - gRelease) * xDerivativePower(n, 1) +...
                gRelease * fbSlow;
        else
            slowEnv(n, 1) = (1 - gAttSlow) * xDerivativePower(n, 1) +...
                gAttSlow * fbSlow;
        end
        fbSlow = slowEnv(n, 1);

        attackEnv(n, 1) = fastEnv(n, 1) - slowEnv(n, 1);
    end
    
    attackEnv = attackEnv/max(attackEnv);
    sustainEnv = 1 - attackEnv;
end