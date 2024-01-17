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

function HP = pointer_tree (intree, inodes, llen, color, DD, options)

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

if (nargin < 2) || isempty (inodes)
    % {DEFAULT: nothing!! (this used to be: last node)}
    inodes   = [];
end
if (islogical (inodes)) && (length (inodes) == length (X))
    inodes   = find (inodes);
end

if (nargin < 3) || isempty (llen)
    % {DEFAULT: average length of pointer}
    llen     = 150;
end

if (nargin < 6) || isempty (options)
    % {DEFAULT: large marker}
    options  = '-O';
end

if (nargin < 4) || isempty (color)
    if contains (options, '-v')
        % {DEFAULT: bluegreenish}
        color    = [0.6 0.7 1];
    else
        % {DEFAULT: red}
        color    = [1 0 0];
    end
    
end

if (nargin < 5) || isempty (DD)
    % {DEFAULT 3-tupel: no spatial displacement from the root}
    DD       = [0 0 0];
end
if length (DD) < 3
    DD       = [DD (zeros (1, 3 - length (DD)))];
end

% the electrodes are basically tapering straight dendrites:
switch           options
    case         '-v'
        HP       = zeros (length (inodes), 1);
        for counter  = 1 : length (inodes)
            tree     = [];
            tree.dA  = sparse ([0 0; 1 0]);
            tree.X   = X (inodes (counter)) + [0; (rand * llen)] + DD (1);
            tree.Y   = Y (inodes (counter)) + [0; (rand * llen)] + DD (2);
            tree.Z   = Z (inodes (counter)) + [0; (rand * llen)] + DD (3);
            tree.D   = [1; 10];
            tree.frustum = 1;
            tree     = resample_tree (tree, 20, '-d');
            tree.D   = tree.D * 10;
            HP (counter) = plot_tree (tree, color, [], [], 32);
        end
        set      (HP, ...
            'facealpha',       0.2);
    case         '-l'
        HP       = zeros (length (inodes), 1);
        for counter  = 1 : length (inodes)
            tree     = [];
            tree.dA  = sparse([0 0; 1 0]);
            tree.X   = X (inodes (counter)) + [0; (rand * llen)] + DD (1);
            tree.Y   = Y (inodes (counter)) + [0; (rand * llen)] + DD (2);
            tree.Z   = Z (inodes (counter)) + [0; (rand * llen)] + DD (3);
            tree.D   = [1; 10];
            tree.frustum = 1;
            HP (counter) = plot_tree ( ...
                resample_tree (tree, 20, '-d'), color, [], [], 8);
        end
    case         '-s'
        HP       = zeros (length (inodes), 1);
        [XS, YS, ZS] = sphere (16);
        for counter = 1 : length (inodes)
            HP (counter) = surface ( ...
                X (inodes (counter)) + (llen / 150) * 2.5 * XS + DD (1), ...
                Y (inodes (counter)) + (llen / 150) * 2.5 * YS + DD (2), ...
                Z (inodes (counter)) + (llen / 150) * 2.5 * ZS + DD (3));
        end
        set      (HP, ...
            'edgecolor',       'none', ...
            'facecolor',       color, ...
            'facealpha',       0.2);
        axis     image;
    case         '-o'
        HP    = plot3 ( ...
            X (inodes) + DD (1), ...
            Y (inodes) + DD (2), ...
            Z (inodes) + DD (3), 'ko');
        set          (HP, ...
            'markersize',      2, ...
            'markerfacecolor', color, ...
            'color',           color);        
    otherwise
        HP    = plot3 ( ...
            X (inodes) + DD (1), ...
            Y (inodes) + DD (2), ...
            Z (inodes) + DD (3), 'ko');
        set          (HP, ...
            'markersize',      8, ...
            'markerfacecolor', color, ...
            'color',           color);
end
axis             equal

