% POINTER_TREE Draws pointers (electrodes) to nodes on a tree.
% (trees package)
%
% HP = pointer_tree (intree, inodes, llen, color, DD, options)
% ------------------------------------------------------------
%
% Draws pointers to nodes inodes. Several options exist, some look a bit
% like electrodes.
%
% Input
% -----
% - intree   ::integer:        index of tree in trees or structured tree
%     or N x 3 matrix with [X Y Z] points
% - inodes   ::vector:         indices in intree of pointer locations
%     {DEFAULT: nothing!! (this used to be: last node)}
% - llen     ::value:          average length of pointer
% - color    ::RGB 3-tupel:    RGB values
%     {DEFAULT red, but bluish for electrodes}
% - DD       :: XY-tupel or XYZ-tupel: coordinates offset
%     {DEFAULT [0, 0, 0]}
% - options  ::string:
%     '-l'   : thin electrode tip
%     '-v'   : huge electrode tip
%     '-s'   : sphere
%     '-o'   : small  marker
%     '-O'   : larger marker
%     {DEFAULT '-O'}
%
% Output
% ------
% - HP       ::handles: handles to the graphical elements.
%
% Example
% -------
% pointer_tree (sample_tree)
%
% See also
% Uses ver X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function HP = pointer_tree (intree, varargin)

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('inodes', [])
p.addParameter('llen', 150)
p.addParameter('color', [])
p.addParameter('DD', [0 0 0])
p.addParameter('l', false, @isBinary)
p.addParameter('v', false, @isBinary)
p.addParameter('s', false, @isBinary)
p.addParameter('o', false, @isBinary)
pars = parseArgs(p, varargin, {'inodes', 'llen', 'color', 'DD'}, ...
    {'l', 'v', 's', 'o'});
%==============================================================================%

% use only node position for this function
if ~isstruct (intree)
    X        = intree (:, 1);
    Y        = intree (:, 2);
    Z        = intree (:, 3);
else
    X        = intree.X;
    Y        = intree.Y;
    Z        = intree.Z;
end

if (islogical (pars.inodes)) && (length (pars.inodes) == length (X))
    pars.inodes   = find (pars.inodes);
end

if isempty (pars.color)
    if pars.v
        % {DEFAULT: bluegreenish}
        pars.color    = [0.6 0.7 1];
    else
        % {DEFAULT: red}
        pars.color    = [1 0 0];
    end

end

if length (pars.DD) < 3
    pars.DD       = [pars.DD (zeros (1, 3 - length (pars.DD)))];
end

% the electrodes are basically tapering straight dendrites:
if pars.v
    HP       = zeros (length (pars.inodes), 1);
    for counter  = 1 : length (pars.inodes)
        tree     = [];
        tree.dA  = sparse ([0 0; 1 0]);
        tree.X   = X (pars.inodes (counter)) + [0; (rand * pars.llen)] + pars.DD (1);
        tree.Y   = Y (pars.inodes (counter)) + [0; (rand * pars.llen)] + pars.DD (2);
        tree.Z   = Z (pars.inodes (counter)) + [0; (rand * pars.llen)] + pars.DD (3);
        tree.D   = [1; 10];
        tree.frustum = 1;
        tree     = resample_tree (tree, 20, '-d');
        tree.D   = tree.D * 10;
        HP (counter) = plot_tree (tree, pars.color, [], [], 32);
    end
    set      (HP, ...
        'facealpha',       0.2);
elseif pars.l
    HP       = zeros (length (pars.inodes), 1);
    for counter  = 1 : length (pars.inodes)
        tree     = [];
        tree.dA  = sparse([0 0; 1 0]);
        tree.X   = X (pars.inodes (counter)) + [0; (rand * pars.llen)] + pars.DD (1);
        tree.Y   = Y (pars.inodes (counter)) + [0; (rand * pars.llen)] + pars.DD (2);
        tree.Z   = Z (pars.inodes (counter)) + [0; (rand * pars.llen)] + pars.DD (3);
        tree.D   = [1; 10];
        tree.frustum = 1;
        HP (counter) = plot_tree ( ...
            resample_tree (tree, 20, '-d'), pars.color, [], [], 8);
    end
elseif pars.s
    HP       = zeros (length (pars.inodes), 1);
    [XS, YS, ZS] = sphere (16);
    for counter = 1 : length (pars.inodes)
        HP (counter) = surface ( ...
            X (pars.inodes (counter)) + (pars.llen / 150) * 2.5 * XS + pars.DD (1), ...
            Y (pars.inodes (counter)) + (pars.llen / 150) * 2.5 * YS + pars.DD (2), ...
            Z (pars.inodes (counter)) + (pars.llen / 150) * 2.5 * ZS + pars.DD (3));
    end
    set      (HP, ...
        'edgecolor',       'none', ...
        'facecolor',       pars.color, ...
        'facealpha',       0.2);
    axis     image;
elseif pars.o
    HP    = plot3 ( ...
        X (pars.inodes) + pars.DD (1), ...
        Y (pars.inodes) + pars.DD (2), ...
        Z (pars.inodes) + pars.DD (3), 'ko');
    set          (HP, ...
        'markersize',      2, ...
        'markerfacecolor', pars.color, ...
        'color',           pars.color);
else
    HP    = plot3 ( ...
        X (pars.inodes) + pars.DD (1), ...
        Y (pars.inodes) + pars.DD (2), ...
        Z (pars.inodes) + pars.DD (3), 'ko');
    set          (HP, ...
        'markersize',      8, ...
        'markerfacecolor', pars.color, ...
        'color',           pars.color);
end
axis             equal

