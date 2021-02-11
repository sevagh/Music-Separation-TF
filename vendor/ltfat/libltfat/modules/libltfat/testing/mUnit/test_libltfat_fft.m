function test_failed = test_libltfat_fft(varargin)
test_failed = 0;

fprintf(' ===============  %s ================ \n',upper(mfilename));

definput.flags.complexity={'double','single'};
[flags]=ltfatarghelper({},definput,varargin);
dataPtr = [flags.complexity, 'Ptr'];

[~,~,enuminfo]=libltfatprotofile;
phaseconv = enuminfo.ltfat_phaseconvention;

fftwflags = struct('FFTW_MEASURE',0,'FFTW_ESTIMATE',64,'FFTW_PATIENT',32,'FFTW_DESTROY_INPUT',1,...
    'FFTW_UNALIGNED',2,'FFTW_EXHAUSTIVE',8,'FFTW_PRESERVE_INPUT',16);

Larr  = [351 350   9   1];
Warr  = [  10       3   3   1];

for idx = 1:numel(Larr)
    L = Larr(idx);
    W = Warr(idx);

    f = randn(L,W,flags.complexity) + 1i*randn(L,W,flags.complexity);   
    fin = complex2interleaved(f);
    fPtr = libpointer(dataPtr,fin);

    c = cast(randn(L,W)+1i*randn(L,W),flags.complexity);
    cout = complex2interleaved(c);
    coutPtr = libpointer(dataPtr,cout);

    truec = fft(f);

    funname = makelibraryname('fft',flags.complexity,0);
    status = calllib('libltfat',funname,fPtr,L,W,coutPtr);

    res = norm(truec - interleaved2complex(coutPtr.Value),'fro');
    [test_failed,fail]=ltfatdiditfail(res+status,test_failed);
    fprintf(['FFT   L:%3i, W:%3i, %s %s %s\n'],L,W,flags.complexity,ltfatstatusstring(status),fail);

    % With plan
    c = cast(randn(L,W)+1i*randn(L,W),flags.complexity);
    cout = complex2interleaved(c);
    coutPtr = libpointer(dataPtr,cout);

    plan = libpointer();
    funname = makelibraryname('fft_init',flags.complexity,0);
    statusInit = calllib('libltfat',funname,L,W,fPtr,coutPtr, fftwflags.FFTW_MEASURE, plan);

    funname = makelibraryname('fft_execute',flags.complexity,0);
 
    statusExecute = calllib('libltfat',funname,plan);


    res = norm(truec - interleaved2complex(coutPtr.Value),'fro');
    [test_failed,fail]=ltfatdiditfail(res+statusInit,test_failed);
    fprintf(['FFT L:%3i, W:%3i, %s %s %s\n'],L,W,flags.complexity,ltfatstatusstring(status),fail);

    c = cast(randn(L,W)+1i*randn(L,W),flags.complexity);
    cout = complex2interleaved(c);
    coutPtr = libpointer(dataPtr,cout);

    funname = makelibraryname('fft_execute_newarray',flags.complexity,0);
    statusExecute = calllib('libltfat',funname,plan,fPtr,coutPtr);

    res = norm(truec - interleaved2complex(coutPtr.Value),'fro');
    [test_failed,fail]=ltfatdiditfail(res+statusInit,test_failed);
    fprintf(['FFT L:%3i, W:%3i, %s %s %s\n'],L,W,flags.complexity,ltfatstatusstring(status),fail);        

    funname = makelibraryname('fft_done',flags.complexity,0);
    statusDone = calllib('libltfat',funname,plan);


    %%%%%% Inplace
    c = f;
    cout = complex2interleaved(c);
    coutPtr = libpointer(dataPtr,cout);

    plan = libpointer();
    funname = makelibraryname('fft_init',flags.complexity,0);
    statusInit = calllib('libltfat',funname,L,W, coutPtr, coutPtr, fftwflags.FFTW_MEASURE, plan);

    funname = makelibraryname('fft_execute',flags.complexity,0);
    statusExecute = calllib('libltfat',funname,plan);

    res = norm(truec - interleaved2complex(coutPtr.Value),'fro');
    [test_failed,fail]=ltfatdiditfail(res+statusInit,test_failed);
    fprintf(['FFT L:%3i, W:%3i, %s %s %s\n'],L,W,flags.complexity,ltfatstatusstring(status),fail);

    c = f;
    cout = complex2interleaved(c);
    coutPtr = libpointer(dataPtr,cout);

    funname = makelibraryname('fft_execute_newarray',flags.complexity,0);
    statusExecute = calllib('libltfat',funname,plan,coutPtr,coutPtr);

    res = norm(truec - interleaved2complex(coutPtr.Value),'fro');
    [test_failed,fail]=ltfatdiditfail(res+statusInit,test_failed);
    fprintf(['FFT L:%3i, W:%3i, %s %s %s\n'],L,W,flags.complexity,ltfatstatusstring(status),fail);        

    funname = makelibraryname('fft_done',flags.complexity,0);
    statusDone = calllib('libltfat',funname,plan);
end



%
%   Url: http://ltfat.github.io/doc/libltfat/modules/libltfat/testing/mUnit/test_libltfat_fft.html

% Copyright (C) 2005-2018 Peter L. Soendergaard <peter@sonderport.dk> and others.
% This file is part of LTFAT version 2.4.0
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

