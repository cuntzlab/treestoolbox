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

function HP = dendrogram_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
% use only directed adjacency for this function
dA           = intree.dA;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('diam', 0.5)
p.addParameter('yvec', Pvec_tree(intree))
p.addParameter('color', [0 0 0])
p.addParameter('DD', [0 0 0])
p.addParameter('wscale', 1)
p.addParameter('p', true, @isBinary)
p.addParameter('v', false, @isBinary)
pars = parseArgs(p, varargin, {'diam', 'yvec', 'color', 'DD', 'wscale'}, {'p', 'v'});
%==============================================================================%

if length (pars.DD) < 3
    % append 3-tupel with zeros:
    pars.DD       = [pars.DD (zeros (1, 3 - length (pars.DD)))];
end

% get the x-positions for the dendrogram:
xdend            = xdend_tree (intree);

% xdend (idpar) is the same as dA * xdend
% vector containing index to direct parent:
idpar            = dA * (1 : size (dA, 1))';
idpar (idpar == 0) = 1;
% coordinates of the nodes in dendrogram:
X1               = ((xdend (idpar)) .* pars.wscale) + pars.DD (1);
X2               = (xdend .* pars.wscale)           + pars.DD (1);
Y1               = pars.yvec  (idpar)               + pars.DD (2);
Y2               = pars.yvec                        + pars.DD (2);
Z1               = zeros (size (X1, 1), 1)          + pars.DD (3);
Z2               = zeros (size (X1, 1), 1)          + pars.DD (3);
if numel (pars.diam)  == 1
    pars.diam         = ones (size (X1, 1), 1) .* pars.diam;
end
if ~pars.v
    % separate in horizontal and vertical components:
    X1           = [X1; X2];
    X2           = [X2; X2];
    Y2           = [Y1; Y2];
    Y1           = [Y1; Y1];
    Z1           = [Z1; Z2];
    Z2           = [Z2; Z2];
    if size (pars.color, 1) > 1
        pars.color    = [pars.color; pars.color]';
    end
    pars.diam         = [ ....
        (pars.diam * (max (Y1) - min (Y1)) / (max (X1) - min (X1))); ...
        pars.diam];
else
    if size  (pars.color, 1) > 1
        pars.color    = pars.color';
    end
end

if ~pars.p
    % as lines:
    HP           = line ( ...
        [X1 X2]', ...
        [Y1 Y2]', ...
        [Z1 Z2]');
    for counter  = 1 : length (HP)
        set      (HP (counter), ...
            'linewidth',       pars.diam (counter), ...
            'color',           pars.color);
    end
else
    % as patches:
    A            = ...
        [(X2 - X1) (Y2 - Y1)] ./ ...
        repmat (sqrt ((X2 - X1).^2 + (Y2 - Y1).^2), 1, 2);
    % use rotation matrix to rotate the data
    V1           = (A * [0, -1;  1, 0]) .* (repmat (pars.diam, 1, 2) / 2);
    V2           = (A * [0,  1; -1, 0]) .* (repmat (pars.diam, 1, 2) / 2);
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
        pars.color);
    set           (HP, ...
        'edgecolor',           'none');
end

