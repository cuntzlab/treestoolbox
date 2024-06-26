% DIRECTION_TREE   Direction vectors of all nodes from parents.
% (trees package)
% 
% direction = direction_tree (intree, options)
% --------------------------------------------
%
% Returns the vectors between .
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
%       alternatively, intree can be a Nx3 matrix XYZ of points
% - options  ::string:
%     '-s'   : show
%     '-n'   : normalise the vector length to unit
%     {DEFAULT: '-n'}
%
% Output
% ------
% eucl       ::Nx1 vector: euclidean distance values for each node
%
% Example
% -------
% direction_tree    (sample_tree, '-s')
%
% See also cyl_tree Pvec_tree len_tree
% Uses ver_tree X Y Z
%
% This function was contributed by Marcel Beining, 2017
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function direction = direction_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
tree         = intree;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('n', true, @isBinary)
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {}, {'n', 's'});
%==============================================================================%

idpar            = idpar_tree (tree);
direction        = zeros (numel (tree.X), 3);
for counter      = 1 : numel (tree.X)
     % node to parent node differences:
    direction (counter, 1)  = tree.X (counter) - tree.X (idpar (counter));
    direction (counter, 2)  = tree.Y (counter) - tree.Y (idpar (counter));
    direction (counter, 3)  = tree.Z (counter) - tree.Z (idpar (counter));
    if pars.n
        direction (counter, :) = ...
            direction (counter, :) / norm (direction (counter, :));
    end
end
direction (1, :) = direction (2, :);


if pars.s % show option
    clf;
    hold         on;
    HP           = plot_tree (intree, direction (:, 1), [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    colorbar;
    title        ('e.g. direction amplitude in X');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

