function Gfb_plot(figure_number, axis_vector, title_string, ...
		  xaxis_label, yaxis_label, domain, value)
% function Gfb_plot(figure_number, axis_vector, title_string, ...
%                   xaxis_labal, yaxis_label, domain, value)
%
% creates plots with labeled axes and defined axis limits
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006

% filename : Gfb_plot.m

    figure(figure_number);
    plot(domain, value);
    axis(axis_vector);
    title(title_string);
    xlabel(xaxis_label);
    ylabel(yaxis_label);



%%-----------------------------------------------------------------------------
%%
%%   Copyright (C) 2002 2006  AG Medizinische Physik,
%%                        Universitaet Oldenburg, Germany
%%                        http://www.physik.uni-oldenburg.de/docs/medi
%%
%%   Permission to use, copy, and distribute this software/file and its
%%   documentation for any purpose without permission by UNIVERSITAET OLDENBURG
%%   is not granted.
%%   
%%   Permission to use this software for academic purposes is generally
%%   granted.
%%
%%   Permission to modify the software is granted, but not the right to
%%   distribute the modified code.
%%
%%   This software is provided "as is" without expressed or implied warranty.
%%
%%   Author: Tobias Herzke
%%
%%-----------------------------------------------------------------------------
