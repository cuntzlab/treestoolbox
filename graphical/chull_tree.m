% CHULL_TREE   Convex hull around whole or part of a tree.
% (trees package)
%
% [HP hull] = chull_tree (intree, ipart, color, DD, alpha, options)
% -----------------------------------------------------------------
%
% Plots a convex hull around indexed nodes (ipart) of a tree. If tree is
% 100% flat 3D convex hull doesn't work. If number of selected nodes is 2
% draw a straight line. If number of selected nodes is 1 plot a point.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
%       alternatively, intree can be a Nx3 matrix XYZ of points
% - ipart    ::index:        index to the subpart to be convex hulled
%     {DEFAULT: all nodes}
%     (needs to be real index values not logical subset)
% - color    ::RGB 3-tupel:  RGB values
%     {DEFAULT black [0 0 0]}
% - DD       :: XY-tupel or XYZ-tupel: coordinates offset
%     {DEFAULT no offset [0,0,0]}
% - alpha    ::value:        transparency value for the patch
%     {DEFAULT 0.2}
% - options  ::string:
%     '-2d'  : 2D
%     {DEFAULT ''}
%
% Output
% ------
% - HP       ::handles:      depending on options HP links to the graphical
%     objects.
% - hull     ::convex polygon:  hull.XY(Z) - X Y (Z) coordinates
%                               hull.ch    - index to convex hull
%
% Example
% -------
% chull_tree   (sample_tree)
% chull_tree   (sample_tree, ...
%     find (sub_tree (sample_tree, 166)), [1 0 0], 20, 1, '-2d');
% plot_tree    (sample_tree) % plot tree as a comparison
%
% See also dhull_tree, hull2d_tree, vhull_tree and vhull2d_tree.
% Uses cyl ver X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [HP,  hull] = chull_tree ( ...
    intree, ...
    ipart, color, DD, alpha, options)

% use only node position for this function
if isnumeric (intree) && numel (intree) > 1
    X        = intree (:, 1);
    Y        = intree (:, 2);
    Z        = intree (:, 3);
else
    ver_tree (intree); % verify that input is a tree structure
    X        = intree.X;
    Y        = intree.Y;
    Z        = intree.Z;

end

if (nargin < 2) || isempty (ipart)
    % {DEFAULT index: select all nodes/points}
    ipart    = (1 : length (X))';
end

if (nargin < 3) || isempty (color)
    % {DEFAULT color: black}
    color    = [0 0 0];
end

if (nargin < 4) || isempty (DD)
    % {DEFAULT 3-tupel: no spatial displacement from the root}
    DD       = [0 0 0];
end
if length (DD) < 3
    % append 3-tupel with zeros:
    DD       = [DD (zeros (1, 3 - length (DD)))];
end

if (nargin < 5) || isempty (alpha)
    % {DEFAULT value: quite a bit transparent}
    alpha    = 0.2;
end

if (nargin < 6) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

% this is basically simple graphical patch of the output of convhull
if contains      (options, '-2d')
    if     length (ipart) > 2
        ch       = convhull (X (ipart), Y (ipart));
        HP       = patch    ( ...
            X (ipart (ch)) + DD (1), ...
            Y (ipart (ch)) + DD (2), color);
        set      (HP, ...
            'facealpha',       alpha, ...
            'edgecolor',       'none');
    elseif length (ipart) == 2
        HP       = line ( ...
            X (ipart) + DD (1), ...
            Y (ipart) + DD (2));
        set      (HP, ...
            'color',           color);
    elseif length (ipart) < 2
        HP       = plot ( ...
            X (ipart) + DD (1), ...
            Y (ipart) + DD (2), 'k.');
        set      (HP, ...
            'color',           color);
    end
else
    if     length (ipart) > 2
        XYZ      = [ ...
            (X (ipart) + DD (1)), ...
            (Y (ipart) + DD (2)), ...
            (Z (ipart) + DD (3))];
        ch       = convhulln (XYZ);
        xc       = XYZ (:, 1);
        yc       = XYZ (:, 2);
        zc       = XYZ (:, 3);
        HP       = patch ( ...
            xc (ch)', ...
            yc (ch)', ...
            zc (ch)', color);
        set      (HP, ...
            'facealpha',       alpha, ...
            'edgecolor',       'none');
    elseif length (ipart) == 2
        HP       = line  ( ...
            X (ipart) + DD (1), ...
            Y (ipart) + DD (2), ...
            Z (ipart) + DD (3));
        set      (HP, ...
            'color',           color);
    elseif length (ipart) < 2
        HP       = plot3 ( ...
            X (ipart) + DD (1), ...
            Y (ipart) + DD (2), ...
            Z (ipart) + DD (3) , 'k.');
        set      (HP, ...
            'color',           color);
    end
end

if sum (get (gca, 'Dataaspectratio') == [1 1 1]) ~= 3
    axis         equal
end

if (nargout > 1)
    if contains (options, '-2d')
        hull     = [];
        hull.XY  = [ ...
            (X (ipart) + DD (1)) ...
            (Y (ipart) + DD (2))];
    else
        hull     = [];
        hull.XYZ = [ ...
            (X (ipart) + DD (1)) ...
            (Y (ipart) + DD (2)) ...
            (Z (ipart) + DD (3))];
    end
    hull.ch      = ch;
end

