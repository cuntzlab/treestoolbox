% CPOINTS   Returns points on a contour.
% (scheme package)
%
% [X, Y] = cpoints (c)
% --------------------
%
% Returns the point coordinates x and y from a contour c.  A contour is
% defined by:
% c = [contour1         x1 x2 x3 ... contour2         x1 x2 x3 ...;
%      #number_of_pairs y1 y2 y3 ... #number_of_pairs y1 y2 y3 ...]'
%
% Input
% -----
% - c        ::contour:   as obtained from contour function
%
% Output
% ------
% - X        ::vertical vector: horizontal coordinates of contour.
% - Y        ::vertical vector: vertical   coordinates of contour.
%
% Example
% -------
% c          = hull_tree (sample_tree, 5, [], [], [], '-2d');
% [X, Y]     = cpoints (c);
% plot       (X, Y, 'k.');
%
% See also hull_tree cplotter in_c rpoints_tree contourc
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [X, Y] = cpoints (c)

X            = [];
Y            = [];
iic          =  1;
while iic < size (c, 1)
    ic       = c (iic, 2);
    X        = [X; (c (iic + 1 : iic + ic, 1))];
    Y        = [Y; (c (iic + 1 : iic + ic, 2))];
    iic      = iic + ic + 1;
end

