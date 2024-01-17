% RECON_TREE   Reconnect subtrees to new parent nodes.
% (trees package)
%
% tree = recon_tree (intree, ichilds, ipars, options)
% ---------------------------------------------------
%
% Reconnects a set of subtrees, given by points ichilds to new parents
% ipars.
% This function alters the original morphology!
%
% Input
% -----
% - intree   ::integer/tree:index of tree in trees or structured tree
% - ichilds  ::vector: children ids
%     {NO DEFAULTS}
% - ipars    ::vector: new parent ids
%     {NO DEFAULTS}
% - options  ::string:
%     '-h'   : shifting of subtree to match the position of parent id
%     '-s'   : show
%     {DEFAULT: '-h', shifts the subtrees}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Examples
% --------
% recon_tree   (sample_tree, 105, 160, '-s')
% recon_tree   (sample_tree, 105, 160, '-s -h')
%
% See also cat_tree sub_tree
% Uses idpar_tree sub_tree ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function tree = recon_tree (intree, ichilds, ipars, options)

ver_tree     (intree); % verify that input is a tree structure
tree         = intree;

if (nargin < 4) || isempty (options)
    % {DEFAULT: shift tree}
    options  = '-h';
end

if contains (options, '-h')
    for counter  = 1 : length (ichilds) % move subtrees:
        isub     = find (sub_tree (tree, ichilds (counter)));
        dX       = ...
            tree.X (ichilds (counter)) - ...
            tree.X (ipars (counter));
        dY       = ...
            tree.Y (ichilds (counter)) - ...
            tree.Y (ipars (counter));
        dZ       = ...
            tree.Z (ichilds (counter)) - ...
            tree.Z (ipars (counter));
        tree.X (isub) = tree.X (isub) - dX;
        tree.Y (isub) = tree.Y (isub) - dY;
        tree.Z (isub) = tree.Z (isub) - dZ;
    end
end

% vector containing index to direct parents:
idpar        = idpar_tree (tree);
for counter  = 1 : length (ichilds)
    tree.dA  (ichilds (counter), idpar (ichilds (counter))) = 0;
    tree.dA  (ichilds (counter), ipars (counter))           = 1;
end

if contains (options, '-s') % show option
    clf;
    hold         on; 
    plot_tree    (intree, [0 0 0], -20);
    plot_tree    (tree,   [1 0 0]);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, ...
        {'before',             'after'});
    set          (HP, ...
        'visible',             'off');
    title        ('reconnect nodes');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

