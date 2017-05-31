% ROUNDSHOW a 3D round show of a plot.
% (scheme package)
%
% Roundshow (pause)
% -----------------
%
% A 3D round show, simply changes the view in regular intervals.
%
% Input
% -----
% - pause    ::value: inverse speed in seconds
%     {DEFAULT: 0.02 sec, fast == 0}
% - options  ::string:
%     '-p'   print
%     {DEFAULT ''}
%
% Output
% ------
% none
%
% Example
% -------
% plot_tree    (sample_tree);
% roundshow;
%
% See also
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2017  Hermann Cuntz

function roundshow (speed, options)

if (nargin < 1) || isempty (speed)
    % {DEFAULT: 0.02 sec}
    speed        = 0.02;
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: none}
    options      = '';
end

for counter         = 0 : 5 : 360
    view         ([(counter - 37.5) 30]);
    axis         vis3d
    if speed     ~= 0
        pause    (speed);
    end
    drawnow;
    if strfind   (options, '-p')
        tprint   ( ...
            sprintf ('roundshow%0.3d.png', counter), ...
            '-HR-png', [], '-a');
    end
end