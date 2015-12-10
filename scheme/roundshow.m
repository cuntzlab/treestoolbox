% ROUNDSHOW a 3D round show of a plot.
% (scheme package)
%
% roundshow (pause)
% -----------------
%
% A 3D round show, simply changes the view in regular intervals.
%
% Input
% -----
% - pause    ::value: inverse speed in seconds
%     {DEFAULT: 0.02 sec, fast == 0}
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
% Copyright (C) 2009 - 2016  Hermann Cuntz

function roundshow (speed)

if (nargin < 1) || isempty (speed)
    % {DEFAULT: 0.02 sec}
    speed        = 0.02;
end

for ward         = 0 : 5 : 360
    view         ([(ward - 37.5) 30]);
    axis         vis3d
    if speed     ~= 0
        pause    (speed);
    end
    drawnow;
end