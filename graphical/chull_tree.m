% CHULL_TREE   Convex hull
% (trees package)
%
% [HP hull] = chull_tree (intree, ipart, color, DD, alpha, options)
% -----------------------------------------------------------------
%
% Plots a convex hull around nodes with index ipart of tree intree (intree
% can also simply be an *Nx3* matrix of XYZ points). Hull patch is offset by
% XYZ 3-tupel DD and coloured with RGB 3-tupel color. alpha sets the
% transparency of the patch (by default .2). Option '-2d' restricts the
% hull patch to two dimensions. HP is the handle to the graphical object.
% Set options to 'none' to avoid graphical output. Output hull is a
% structure containing in hull.XY(Z) the coordinates and in hull.ch the
% indices to the convex hull (see Matlab function �convhull�).
%
% If the tree is 100% flat 3D convex hull doesn't work. If selected nodes
% are two draws a straight line. If selected nodes are one plots a point. 
%
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
%     '-dim2'  : 2D (Careful, used to be called '-2d')
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

function [HP,  hull] = chull_tree (intree, varargin)

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

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('ipart', (1 : length (X))')
p.addParameter('color', [0 0 0])
p.addParameter('DD', [0 0 0])
p.addParameter('alpha', 0.2)
p.addParameter('dim2', false, @isBinary)
pars = parseArgs(p, varargin, {'ipart', 'color', 'DD', 'alpha'}, {'dim2'});
%==============================================================================%

if length (pars.DD) < 3
    % append 3-tupel with zeros:
    pars.DD       = [pars.DD (zeros (1, 3 - length (pars.DD)))];
end

% this is basically simple graphical patch of the output of convhull
if pars.dim2
    if     length (pars.ipart) > 2
        ch       = convhull (X (pars.ipart), Y (pars.ipart));
        HP       = patch    ( ...
            X (pars.ipart (ch)) + pars.DD (1), ...
            Y (pars.ipart (ch)) + pars.DD (2), pars.color);
        set      (HP, ...
            'facealpha',       pars.alpha, ...
            'edgecolor',       'none');
    elseif length (pars.ipart) == 2
        HP       = line ( ...
            X (pars.ipart) + pars.DD (1), ...
            Y (pars.ipart) + pars.DD (2));
        set      (HP, ...
            'color',           pars.color);
    elseif length (pars.ipart) < 2
        HP       = plot ( ...
            X (pars.ipart) + pars.DD (1), ...
            Y (pars.ipart) + pars.DD (2), 'k.');
        set      (HP, ...
            'color',           pars.color);
    end
else
    if     length (pars.ipart) > 2
        XYZ      = [ ...
            (X (pars.ipart) + pars.DD (1)), ...
            (Y (pars.ipart) + pars.DD (2)), ...
            (Z (pars.ipart) + pars.DD (3))];
        ch       = convhulln (XYZ);
        xc       = XYZ (:, 1);
        yc       = XYZ (:, 2);
        zc       = XYZ (:, 3);
        HP       = patch ( ...
            xc (ch)', ...
            yc (ch)', ...
            zc (ch)', pars.color);
        set      (HP, ...
            'facealpha',       pars.alpha, ...
            'edgecolor',       'none');
    elseif length (pars.ipart) == 2
        HP       = line  ( ...
            X (pars.ipart) + pars.DD (1), ...
            Y (pars.ipart) + pars.DD (2), ...
            Z (pars.ipart) + pars.DD (3));
        set      (HP, ...
            'color',           pars.color);
    elseif length (pars.ipart) < 2
        HP       = plot3 ( ...
            X (pars.ipart) + pars.DD (1), ...
            Y (pars.ipart) + pars.DD (2), ...
            Z (pars.ipart) + pars.DD (3) , 'k.');
        set      (HP, ...
            'color',           pars.color);
    end
end

if sum (get (gca, 'Dataaspectratio') == [1 1 1]) ~= 3
    axis         equal
end

if (nargout > 1)
    if pars.dim2
        hull     = [];
        hull.XY  = [ ...
            (X (pars.ipart) + pars.DD (1)) ...
            (Y (pars.ipart) + pars.DD (2))];
    else
        hull     = [];
        hull.XYZ = [ ...
            (X (pars.ipart) + pars.DD (1)) ...
            (Y (pars.ipart) + pars.DD (2)) ...
            (Z (pars.ipart) + pars.DD (3))];
    end
    hull.ch      = ch;
end

