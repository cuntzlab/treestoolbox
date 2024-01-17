% DENDROGRAM_TREE   Plots a dendrogram of a tree.
% (trees package)
%
% HP = dendrogram_tree (intree, diam, yvec, color, DD, wscale, options)
% ---------------------------------------------------------------------
%
% Plots a dendrogram of the topology of a tree (must be BCT conform).
% (consider applying repair_tree first). Option '-p' a patches is obviously
% a lot faster!
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - diam     ::vector/single value: attributes to each element a horizontal
%     width
%     {DEFAULT 0.5}
% - yvec     ::vertical vector: attributes to each element a Y-position
%     {DEFAULT: metric path length}
% - color    ::RGB 3-tupel, vector or matrix: RGB values
%     if vector then values are treated in colormap (must be Nx1,
%     works only with '-p' option)
%     if matrix (num x 3) then individual colors are mapped to each element
%     {DEFAULT [0 0 0]}
% - DD       :: X XY-tupel or XYZ-tupel: coordinates offset
%     {DEFAULT [0,0,0]}
% - wscale   ::scalar:       spacing of terminals
%     {DEFAULT 1}
% - options  ::string:
%     '-p'   : drawn as patches instead of lines (color then be Nx1 vector)
%     '-v'   : no horizontal lines
%     {DEFAULT: '-p'}
%
% Output
% ------
% - HP       ::handles:      depending on options HP links to the graphical
%     objects
%
% Example
% -------
% dendrogram_tree (sample_tree)
%
% See also   xdend_tree BCT_tree
% Uses       xdend_tree ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function HP = dendrogram_tree ( ...
    intree, diam, yvec, color, DD, wscale, options)

ver_tree     (intree); % verify that input is a tree structure
% use only directed adjacency for this function
dA           = intree.dA;

if (nargin < 2) || isempty (diam)
    % {DEFAULT: half of distance between two end-nodes}
    diam     = 0.5;
end

if (nargin < 3) || isempty (yvec)
    % {DEFAULT vector: metric path length}
    yvec     = Pvec_tree (intree);
end

if (nargin < 4) || isempty (color)
    % {DEFAULT color: black}
    color    = [0 0 0];
end

if (nargin < 5) || isempty (DD)
    % {DEFAULT 3-tupel: no spatial displacement from the root}
    DD       = [0 0 0];
end
if length (DD) < 3
    % append 3-tupel with zeros:
    DD       = [DD (zeros (1, 3 - length (DD)))];
end

if (nargin < 6) || isempty (wscale)
    % {DEFAULT: 1 um between two terminal nodes}
    wscale   = 1;
end

if (nargin < 7) || isempty (options)
    % {DEFAULT: as patches}
    options  = '-p';
end

% get the x-positions for the dendrogram:
xdend            = xdend_tree (intree);

% xdend (idpar) is the same as dA * xdend
% vector containing index to direct parent:
idpar            = dA * (1 : size (dA, 1))';
idpar (idpar == 0) = 1;
% coordinates of the nodes in dendrogram:
X1               = ((xdend (idpar)) .* wscale) + DD (1);
X2               = (xdend .* wscale)           + DD (1);
Y1               = yvec  (idpar)               + DD (2);
Y2               = yvec                        + DD (2);
Z1               = zeros (size (X1, 1), 1)     + DD (3);
Z2               = zeros (size (X1, 1), 1)     + DD (3);
if numel (diam)  == 1
    diam         = ones (size (X1, 1), 1) .* diam;
end
if ~contains (options, '-v')
    % separate in horizontal and vertical components:
    X1           = [X1; X2];
    X2           = [X2; X2];
    Y2           = [Y1; Y2];
    Y1           = [Y1; Y1];
    Z1           = [Z1; Z2];
    Z2           = [Z2; Z2];
    if size (color, 1) > 1
        color    = [color; color]';
    end
    diam         = [ ....
        (diam * (max (Y1) - min (Y1)) / (max (X1) - min (X1))); ...
        diam];
else
    if size  (color, 1) > 1
        color    = color';
    end
end

if ~contains (options, '-p')
    % as lines:
    HP           = line ( ...
        [X1 X2]', ...
        [Y1 Y2]', ...
        [Z1 Z2]');
    for counter  = 1 : length (HP)
        set      (HP (counter), ...
            'linewidth',       diam (counter), ...
            'color',           color);
    end
else
    % as patches:
    A            = ...
        [(X2 - X1) (Y2 - Y1)] ./ ...
        repmat (sqrt ((X2 - X1).^2 + (Y2 - Y1).^2), 1, 2);
    % use rotation matrix to rotate the data
    V1           = (A * [0, -1;  1, 0]) .* (repmat (diam, 1, 2) / 2);
    V2           = (A * [0,  1; -1, 0]) .* (repmat (diam, 1, 2) / 2);
    HP           = patch ([ ...
        (X1 + V2 (:, 1)) ...
        (X1 + V1 (:, 1)) ...
        (X2 + V1 (:, 1)) ...
        (X2 + V2 (:, 1))]', [ ...
        (Y1 + V2 (:, 2)) ...
        (Y1 + V1 (:, 2)) ...
        (Y2 + V1 (:, 2)) ...
        (Y2 + V2 (:, 2))]', ...
        [Z1 Z1 Z2 Z2]', ...
        color);
    set           (HP, ...
        'edgecolor',           'none');
end

