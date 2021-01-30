function varargout = phaseplot(f, varargin)  % Plot phase portrait.
%PHASEPLOT   Phase (= argument) plot of a complex function.
%   PHASEPLOT(F), where F is a function handle or a CHEBFUN2 defining a
%   complex function, draws a phase plot of F(Z) in the complex plane.
%   As arg(f(z)) ranges over [0,2pi] the colors run
%   red -> yellow -> green -> cyan -> blue -> magenta -> red.
%   
%   If HOLD is ON, the existing axes are used.  If HOLD is OFF, the axes
%   are taken as the domain of F if it is a CHEBFUN2, otherwise [-1 1 -1 1].
%   PHASEPLOT(F, [A B C D]) uses the axes [A B C D].
%
%   PHASEPLOT(F, 'CLASSIC') uses the color scheme from [1] rather than
%   a somewhat smoothed variant.
%
% Examples:
%   
%   phaseplot(@(z) z.^2)
%   phaseplot(@(z) exp(1./z.^2))
%   phaseplot(@(z) besselj(6,z),[-12 12 -5 5])
%   phaseplot(cheb.gallery2('airycomplex'))
%
%   plot(chebfun('exp(1i*s)',[-pi,pi]),'k')
%   axis([-2 2 -2 2]), axis square, hold on
%   r = padeapprox(@(z) -sqrt(1-z.^3),24,24); phaseplot(r)
%
%   Z = rand(1000,1) + 1i*rand(1000,1);
%   plot(Z,'.k','markersize',4)
%   axis([-1 2 -1.5 1.5]), axis square, hold on
%   F = sqrt(Z.*(1-Z)); [r,pol] = aaa(F,Z); phaseplot(r)
%
% Reference:
%
%   [1] E. Wegert, Visual Complex Functions: An Introduction with Phase
%   Portraits, Springer Basel, 2012.
%
% See also CHEBFUN2/PLOT.

% Copyright 2020 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

%% Parse inputs

classic = 0;                      % default: smoothed colors
j = 1;
while ( j < nargin )
    j = j+1;
    v = varargin{j-1};
    if ~ischar(v)                
        ax = v;                   % user specifies axes
    elseif strcmp(v, 'classic')
        classic = 1;              % user requests classic color scheme
    else
        error('PHASEPLOT:inputs', 'Unrecognized input')
    end
end

%% Determine axes

if ~exist( 'ax' )
    if ( ishold )
        ax = axis;
    elseif ( isa(f, 'chebfun2') )
        ax = f.domain;
    else 
        ax = [-1 1 -1 1];
    end
end

%% Produce the phase plot

x = linspace(ax(1), ax(2), 500);
y = linspace(ax(3), ax(4), 500);
[xx,yy] = meshgrid(x, y);
zz = xx + 1i*yy;
if ( classic )
    phi = @(t) t;
else
    phi = @(t) t - .5*cos(1.5*t).^3.*sin(1.5*t);
end
h = surf(real(zz), imag(zz), -ones(size(zz)), phi(angle(-f(zz))));
set(h, 'EdgeColor','none');
caxis([-pi pi])
colormap hsv(600)
view(0,90)
if ( ~ishold )
    axis(ax)
    if ( ax(2)-ax(1) == ax(4)-ax(3) )
        axis square
    else
        axis equal
    end
end
if ( ~classic )
    alpha .8           % transparency makes it less harsh
end
if ( nargout > 0 )
    varargout = {h};
end

