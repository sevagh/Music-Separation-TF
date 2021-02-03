function tf_viz(path)
addpath(genpath('../vendor/WarpTB'));
addpath(genpath('../matlab-algorithms'));

[x, fs] = audioread(path);

smallWin = 256;
bigWin = 16384;

figure;
spectrogram(x, smallWin, smallWin/2, smallWin*2, fs, "yaxis");
title('STFT, low frequency resolution, ', path);

figure;
spectrogram(x, bigWin, bigWin/2, bigWin*2, fs, "yaxis");
title('STFT, high frequency resolution, ', path);

figure;
cqt(x,'SamplingFrequency', fs, 'BinsPerOctave', 12);
title('CQT, low frequency resolution, ', path);

figure;
cqt(x,'SamplingFrequency', fs, 'BinsPerOctave', 96);
title('CQT, high frequency resolution ', path);

end