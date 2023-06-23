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
%     '-2d'  : text coordinates only 2 dimensions (DD has to correspond)
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

function HP = vtext_tree (intree, v, color, DD, crange, ipart, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 7) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

if (nargin < 1) || isempty (intree)
    % {DEFAULT last tree in trees}
    intree   = length (trees);
end

ver_tree     (intree);                 % verify that input is a tree

% use only node position for this function
if ~isstruct (intree)
    X        = trees{intree}.X;
    Y        = trees{intree}.Y;
    if ~contains (options, '-2d')
        Z    = trees{intree}.Z;
    end
else
    X        = intree.X;
    Y        = intree.Y;
    if ~contains (options, '-2d')
        Z    = intree.Z;
    end
end

N            = size (X, 1); % number of nodes in tree

if (nargin < 6) || isempty (ipart)
    % {DEFAULT: select all nodes}
    ipart    = (1 : N)';
end

if (nargin < 2) || isempty (v)
    % {DEFAULT: count up nodes}
    v        = (1 : N)';
end
if (size (v, 1) == N) && (size (ipart, 1) ~= N)
    v        = v (ipart);
end

if (nargin < 3) || isempty (color)
    % {DEFAULT color: red}
    color    = [1 0 0];
end

if (size (color, 1) == N) && (size (ipart, 1) ~= N)
    color    = color (ipart);
end

if (nargin < 4) || isempty (DD)
    % {DEFAULT 3-tupel: no spatial displacement from the root}
    DD       = [0 0 0];                  
end
if length (DD) < 3
    % append 3-tupel with zeros:
    DD       = [DD (zeros (1, 3 - length (DD)))];
end

% if color values are mapped:
if size              (color, 1) > 1
    if size          (color, 2) ~= 3
        if islogical (color)
            color    = double (color);
        end
        if (nargin < 5) || isempty (crange)
            crange   = [ ...
                (min (color)) ...
                (max (color))];
        end
        % scaling of the vector
        if diff (crange) == 0
            color    = ones (size (color, 1), 1);
        else
            color    = floor ( ...
                (color - crange (1)) ./ ...
                ((crange (2) - crange (1)) ./ 64));
            color (color < 1 ) =  1;
            color (color > 64) = 64;
        end
        map          = colormap;
        colors       = map (color, :);
    else
        colors       = color;
    end
end

if contains (options, '-2d')
    vt               = num2str (v);
    HP               = text ( ...
        X (ipart) + DD (1), ...
        Y (ipart) + DD (2), vt);
else
    vt               = num2str (v);
    HP               = text ( ...
        X (ipart) + DD (1), ...
        Y (ipart) + DD (2), ...
        Z (ipart) + DD (3), vt);
end

if size (color, 1)   > 1
    for counter      = 1 : length (ipart)
        set          (HP (counter), ...
            'color',           colors (counter, :), ...
            'fontsize',        14);
    end
else
    set              (HP, ...
        'color',               color, ...
        'fontsize',            14);
end

if contains (options, '-sc')
    axis             equal;
    xlim             ([(min (X)) (max (X))]);
    ylim             ([(min (Y)) (max (Y))]);
    if ~contains (options, '-2d')
        zlim         ([(min (Z)) (max (Z))]);
    end
end



