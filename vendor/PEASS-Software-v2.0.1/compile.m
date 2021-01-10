function compile
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version history
%  - Version 2.0, January 2013: added _USE_MATH_DEFINES in haircell.c
%  - Version 2.0, October 2011: added _USE_MATH_DEFINES in adapt.c
%  - Version 1.1, September 2011: added compilation for haircell and
%  adaptation MEX files
%  - Version 1.0, June 2010: first release
% Copyright 2010-2011 Valentin Emiya and Emmanuel Vincent (INRIA).
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove syntax errors in adapt.c
fid=fopen('adapt.c','r');
txt=fscanf(fid,'%c');
fclose(fid);
pos=strfind(txt,'// ');
while ~isempty(pos),
    b=pos(1);
    e=strfind(txt(b+1:end),char(10));
    txt=[txt(1:b-1) txt(b+e(1):end)];
    pos=strfind(txt,'// ');
end
pos=strfind(txt,'<math.h>');
txt=[txt(1:pos-10) '#define _USE_MATH_DEFINES' char(10) txt(pos-9:end)];
fid=fopen('adapt.c','w');
fprintf(fid,'%c',txt);
fclose(fid);

% Remove syntax errors in haircell.c
fid=fopen('haircell.c','r');
txt=fscanf(fid,'%c');
fclose(fid);
pos=strfind(txt,'<math.h>');
txt=[txt(1:pos-10) '#define _USE_MATH_DEFINES' char(10) txt(pos-9:end)];
fid=fopen('haircell.c','w');
fprintf(fid,'%c',txt);
fclose(fid);

% Compile
mex toeplitzC.c
mex haircell.c
mex adapt.c
cd gammatone
mex Gfb_Analyzer_fprocess.c
cd ..

return