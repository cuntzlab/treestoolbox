% SCALEBAR   Add a scalebar to an axis.
% (scheme package)
%
% HP = scalebar (unit, pos)
% -------------------------
%
% Adds a scalebar to the axis.
%
% Input
% -----
% - unit     ::string: {DEFAULT: micrometer, '\mum'}
% - pos      ::string: position {DEFAULT: southwest '-sw'}
%     '-sw'  : southwest
%     '-se'  : southeast
%     '-nw'  : northwest
%     '-ne'  : northeast
%
% Output
% ------
%
% HP         ::handles: HP links to the graphical objects
%
% Example
% -------
% plot_tree    (sample_tree);
% axis         off;
% scalebar;
%
% See also start_trees
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function HP  = scalebar (unit, pos)

if (nargin < 1) || isempty (unit)
    % {DEFAULT: micrometer unit}
    unit     = '\mum';
end

if (nargin < 2) || isempty (pos)
    % {DEFAULT: position southwest}
    pos      = '-sw'; 
end

dx           = xlim;
ddx          = (dx (2) - dx (1)) / 5;
rddx         = (10 ^ (floor (log10 (ddx))));
ddx          = round (ddx ./ rddx) .* rddx;
if     strcmp (pos, '-sw')
    ddx2     =             0.05 .* (dx (2) - dx (1)) + dx (1);
    dy       = ylim; ddy = 0.05 .* (dy (2) - dy (1)) + dy (1);
    ddy3     =             0.07 .* (dy (2) - dy (1)) + dy (1);
    HPL      = line        ([ddx2 (ddx2 + ddx)], [ddy ddy]);
    HPT      = text        (ddx2,       ddy3, [(num2str (ddx)) ' ' unit]);
elseif strcmp (pos, '-se')
    ddx2     =             0.95 .* (dx (2) - dx (1)) + dx (1);
    dy       = ylim; ddy = 0.05 .* (dy (2) - dy (1)) + dy (1);
    ddy3     =             0.07 .* (dy (2) - dy (1)) + dy (1);
    HPL      = line        ([ddx2 (ddx2 - ddx)], [ddy ddy]);
    HPT      = text        (ddx2 - ddx, ddy3, [(num2str (ddx)) ' ' unit]);
elseif strcmp (pos, '-ne')
    ddx2     =             0.95 .* (dx (2) - dx (1)) + dx (1);
    dy       = ylim; ddy = 0.90 .* (dy (2) - dy (1)) + dy (1);
    ddy3     =             0.92 .* (dy (2) - dy (1)) + dy (1);
    HPL      = line        ([ddx2 (ddx2 - ddx)], [ddy ddy]);
    HPT      = text        (ddx2 - ddx, ddy3, [(num2str (ddx)) ' ' unit]);
elseif strcmp (pos, '-nw')
    ddx2     =             0.05 .* (dx (2) - dx (1)) + dx (1);
    dy       = ylim; ddy = 0.90 .* (dy (2) - dy (1)) + dy (1);
    ddy3     =             0.92 .* (dy (2) - dy (1)) + dy (1);
    HPL      = line        ([ddx2 (ddx2 + ddx)], [ddy ddy]);
    HPT      = text        (ddx2,       ddy3, [(num2str (ddx)) ' ' unit]);
end
set          (HPL, ...
    'color',                   [0 0 0], ...
    'linewidth',               2);
set          (HPT, ...
    'fontsize',                12, ...
    'verticalAlignment',       'bottom');
HP           = [HPL; HPT];



