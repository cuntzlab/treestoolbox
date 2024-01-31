% RESTRAIN_TREE   Prunes tree to not exceed max path length
% (trees package)
%
% tree = restrain_tree (intree, maxpl, options)
% ---------------------------------------------
%
% Deletes nodes
%
% Input
% -----
% - intree   ::integer:   index of tree in trees or structured tree
% - maxpl    ::number:    maximum path length
%     {DEFAULT: 400 um}
% - options  ::string:
%     '-s'   : show
%     '-i'   : interpolate termination point to maxpl (default). without
%       this option, the termination point is deleted without substitute
%     {DEFAULT: '-i'}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% restrain_tree (sample_tree, 80, '-i -s')
%
% contributed function by Marcel Beining, 2017
%
% See also insert_tree cat_tree
% Uses idpar_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function tree = restrain_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
tree         = intree;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('maxpl', 400, @isnumeric)
p.addParameter('i', true, @isBinary)
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {'maxpl'}, {'i', 's'});
%==============================================================================%

Plen             = Pvec_tree (tree); %get path lengths

if any           (Plen > pars.maxpl)
    if pars.i
        idpar    = idpar_tree (tree); % get parent indices
        % delete all nodes whose parent nodes are too far away from soma,
        % too:
        ind      = Plen > pars.maxpl & Plen (idpar) > pars.maxpl;
        tree     = delete_tree (tree, ind, '-r');
        % for the rest, make them be as far away as possible (maxpl)
        % without changing direction
        idpar    = idpar_tree (tree); % parent indices of cut tree
        Plen     = Pvec_tree  (tree); % path lengths of cut tree
        ind      = Plen > pars.maxpl;
        direction = direction_tree (tree, '-n'); % get normed direction vectors
        % substract path length from parent node and multiply by direction
        % to have point farthest away:
        tree.X (ind) = tree.X (idpar (ind)) + ...
            direction (ind, 1) .* (pars.maxpl - Plen (idpar (ind)));
        tree.Y (ind) = tree.Y (idpar (ind)) + ....
            direction (ind, 2) .* (pars.maxpl - Plen (idpar (ind)));
        tree.Z (ind) = tree.Z (idpar (ind)) + ...
            direction (ind, 3) .* (pars.maxpl - Plen (idpar (ind)));
    else
        % delete all nodes which are farther away as maxpl
        tree     = delete_tree (tree, Plen > pars.maxpl, '-r');
    end
end

% display the result
if pars.s
    clf;
    hold         on;
    plot_tree    (intree);
    colors       = [ ...
        0    1    0; ...
        0    0    1; ...
        0    0.5  0; ...
        0    0.75 0.75; ...
        0.75 0    0.75; ...
        0.75 0.75 0; ...
        0.5  0    0];
    if length    (tree) > 1
        for counter = 1 : length (tree)
            plot_tree    (tree{counter}, ...
                colors (mod (counter - 1, size (colors, 1)) + 1, :), 100);
        end
    else
        plot_tree    (tree, [0 1 0], 100);
        HP (1)       = plot (1, 1, 'k-');
        HP (2)       = plot (1, 1, 'g-');
        legend       (HP, ...
            {'original tree',      'trimmed tree'}); 
        set          (HP, ...
            'visible',             'off');
    end
    title        ('find the differences: delete nodes in tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
    if (exist ('ind', 'var')) && (~isempty (ind))
        pointer_tree (tree, ind);
    end
end

