%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    WarpTB                               %
% MATLAB toolbox for frequency-warped signal processing   % 
% 
% Practically any signal processing algorithm can be
% warped by replacing all the unit delay elements by 
% first order allpass blocks. Frequency-warping changes 
% the frequency resolution of the system. Using a
% suitable value for a warping coefficient LAMBDA, the
% frequency-resolution of the system approximates 
% closely the frequency resolution of human auditory 
% system. This makes frequency-warped signal processing
% techniques beneficial in many speech and audio 
% signal processing applications. 
% 
% WarpTB consists of a basic toolkit and a set of optional
% examples and sub-toolkits for specific 
% applications. 
% 
% The toolbox is free and it is available at
% http://www.acoustics.hut.fi/software/warp
%
% Copyright: Aki Härmä and Matti Karjalainen,
% Helsinki University of Technology, Laboratory of
% Acoustics and Audio Signal Processing, Espoo, Finland.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WarpTB: Basic tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ap_delay      - A first order allpass filter
% wautoc        - Warped autocorrelation function
% wfilter       - Real-valued implementation of warped 
%                 FIR/IIR filters 
% wlpc          - Warped linear prediction coefficients 
%                 using autocorrelation method
% warp_impres   - Computation of a warped impulse response
% longchain     - Computation of a warped signal
% barkwarp      - Optimal auditory warping coefficient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WarpTB: examples directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BinAural: Binaural filtering
%               - hrtfwarp script designs and compares
%                 different implementations for HRTF (Head 
%                 Related Transfer Function) filters. The 
%                 script produces Fig. 25 of [1].
% 
% WGmesh: Digital Waveguide mesh simulations
%               - ir_warp_still produces Figs. 26-27 of [1]
%               - ir_warp_anim  shows an animation related
%                 to the same problem.
%               - membrane_warp produces Fig. 28 of [1].
%
% WLP: Warped Linear Prediction
%               - wlpdemo1 is a simple demonstration
%                 on the usage of warped linear prediction.
%               - wlpdemo2 is another WLP demonstration which 
%                 produces Figs. 19 of [1].
%
% WarpFB: Warped FFT and warped filterbank
%               - wfbdemo1 is a simple illustration of the
%                 performance of warped FFT in computing an
%                 auditory spectrogram for a harmonic signal.
%               - wfbdemo2 designs a 23 channel warped 
%                 filterbank of fifth order Butterworh filters.
%
% WarpSig       - basicdemo1 illustrates the frequency-warping
%                 effect occurring in a chain of first order
%                 allpass elements. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1] A. Härmä, M. Karjalainen, L. Savioja, V. Välimäki, 
% U. K. Laine, and J. Huopaniemi, 'Frequency-Warped Signal 
% Processing for Audio Applications', J. Aud. Eng. Soc., 
% November 2000.
