% VTEXT_TREE   Write text at node locations in a tree.
% (trees package)
% 
% HP = vtext_tree (intree, v, color, DD, crange, ipart, options)
% --------------------------------------------------------------
%
% Displays text numbers in the vector v at the coordinates of the nodes
% ipart in the tree.
%
% Input
% -----
% - intree   ::integer:index of tree in trees structure or structured tree
% - v        ::vertical vector of size N (number of nodes): any vector of
%     numbers to be displayed in the appropriate location
%     {DEFAULT: node indices}
% - color    ::RGB 3-tupel, vector or matrix: RGB values
%     if vector then values are treated in colormap (must contain one value
%     per node then!)
%     if matrix (num x 3) then individual colors are mapped to each element
%     {DEFAULT [1 0 0]} red
% - DD       :: XY-tupel or XYZ-tupel: coordinates offset
%     {DEFAULT [0,0,0]}
% - crange   ::2-tupel:      color range [min max]
%     {DEFAULT tight}
% - ipart    ::index:        index to the nodes to be plotted
% - options  ::string:
%     '-dim2'  : text coordinates only 2 dimensions (DD has to correspond)
%                (Careful, used to be called '-2d')
%     '-sc'  : text does not scale the axis not even with axis tight, this
%         option does it for you
%     {DEFAULT ''}
%
% Output
% ------
% - HP       ::handles:      links to the graphical objects.
%
% Example
% -------
% vtext_tree   (sample2_tree, [], [], [], [], [], '-sc');
%
% See also   plot_tree xplore_tree
% Uses       X, Y, Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function HP = vtext_tree (intree, varargin)

ver_tree     (intree);                 % verify that input is a tree
N            = size (intree.X, 1);     % number of nodes in tree

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('v', (1 : N)')
p.addParameter('color', [1 0 0])
p.addParameter('DD', [0 0 0])
p.addParameter('crange', [])
p.addParameter('ipart', (1 : N)')
p.addParameter('dim2', false, @isBinary)
p.addParameter('sc', false, @isBinary)
pars = parseArgs(p, varargin, {'v', 'color', 'DD', 'crange', 'ipart'}, ...
    {'dim2', 'sc'});
%==============================================================================%

% use only node position for this function
X            = intree.X;
Y            = intree.Y;
if ~pars.dim2
    Z        = intree.Z;
end

if (size (pars.v, 1) == N) && (size (pars.ipart, 1) ~= N)
    pars.v        = pars.v (pars.ipart);
end

if (size (pars.color, 1) == N) && (size (pars.ipart, 1) ~= N)
    pars.color    = pars.color (pars.ipart);
end

if length (pars.DD) < 3
    % append 3-tupel with zeros:
    pars.DD       = [pars.DD (zeros (1, 3 - length (pars.DD)))];
end

% if color values are mapped:
if size              (pars.color, 1) > 1
    if size          (pars.color, 2) ~= 3
        if islogical (pars.color)
            pars.color    = double (pars.color);
        end
        if isempty (pars.crange)
            pars.crange   = [ ...
                (min (pars.color)) ...
                (max (pars.color))];
        end
        % scaling of the vector
        if diff (pars.crange) == 0
            pars.color    = ones (size (pars.color, 1), 1);
        else
            pars.color    = floor ( ...
                (pars.color - pars.crange (1)) ./ ...
                ((pars.crange (2) - pars.crange (1)) ./ 64));
            pars.color (pars.color < 1 ) =  1;
            pars.color (pars.color > 64) = 64;
        end
        map          = colormap;
        colors       = map (pars.color, :);
    else
        colors       = pars.color;
    end
end

if pars.dim2
    vt               = num2str (pars.v);
    HP               = text ( ...
        X (pars.ipart) + pars.DD (1), ...
        Y (pars.ipart) + pars.DD (2), vt);
else
    vt               = num2str (pars.v);
    HP               = text ( ...
        X (pars.ipart) + pars.DD (1), ...
        Y (pars.ipart) + pars.DD (2), ...
        Z (pars.ipart) + pars.DD (3), vt);
end

if size (pars.color, 1)   > 1
    for counter      = 1 : length (pars.ipart)
        set          (HP (counter), ...
            'color',           colors (counter, :), ...
            'fontsize',        14);
    end
else
    set              (HP, ...
        'color',               pars.color, ...
        'fontsize',            14);
end

if pars.sc
    axis             equal;
    xlim             ([(min (X)) (max (X))]);
    ylim             ([(min (Y)) (max (Y))]);
    if ~pars.dim2
        zlim         ([(min (Z)) (max (Z))]);
    end
end

