% IN_C   Applies inpolygon on contour.
% scheme package
%
% [IN, ON] = in_c (X, Y, c, dx, dy)
% ---------------------------------
%
% If c is a contour obtained from a single isoline contourc, checks if
% points X and Y are located IN the largest contour or ON the outer
% boundaries of the largest contour (using inpolygon).
%
% Input
% -----
% - X        ::vertical vector: horizontal coordinates of test points.
% - Y        ::vertical vector: vertical  coordinates of test points.
% - c        ::contour: as obtained from contour function
% - dx       ::scalar:  offset in X
% - dy       ::scalar:  offset in Y
%
% Output
% ------
% - IN       ::index in X and Y of points inside
% - ON       ::index in X and Y of points on the contour
%
% Example
% -------
% c          = hull_tree (sample_tree, 5, [], [], [], 'dim2');
% X          = 100 * rand (1000, 1);
% Y          = 100 * rand (1000, 1);
% IN         = in_c (X, Y, c);
% plot       (X (IN), Y (IN), 'k.');
%
% See also hull_tree cplotter cpoints rpoints_tree contourc
% Uses inpolygon
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [IN, ON] = in_c (X, Y, c, dx, dy)

if (nargin < 5) || isempty (dy)
    dy       = 0;
end

if (nargin < 4) || isempty (dx)
    dx       = 0;
end

iic              =  1;
POL              = {};
POLSIZE          = [];
counter          =  1;
while (iic < size (c, 1))
    ic           = c (iic, 2);
    POL{counter} = [ ...
        (c (iic + 1 : iic + ic, 1) + dx) ...
        (c (iic + 1 : iic + ic, 2) + dy)];
    POLSIZE (counter) = ic;
    iic          = iic + ic + 1;
    counter      = counter + 1;
end

[~, i2]          = max (POLSIZE);
[IN, ON]         = inpolygon (X, Y, ...
    POL{i2} (:, 1), ...
    POL{i2} (:, 2));

for counter      = 1 : length (POLSIZE)
    if (counter ~= i2)
        IN       = IN & ~inpolygon (X, Y, ...
            POL{counter} (:, 1), ...
            POL{counter} (:, 2));
    end
end



