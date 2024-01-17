% REDIRECT_TREE   Set root to new point and redirect tree graph.
% (trees package)
%
% [tree, order] = redirect_tree (intree, istart, options)
% -------------------------------------------------------
%
% Changes the direction of the adjacency matrix so that arrows show away
% from element istart (which becomes the first elements)
% ! redirect only makes sense on terminal or continuation nodes !
% ! because otherwise a trifurcation occurs                   !
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - istart   ::number:       starting node
%     {DEFAULT: last node}
% - options  ::string:
%     '-s'   : show (green - old index, red - new index)
%     {DEFAULT: ''}
%
% Outputs
% -------
% if no output is declared the tree is changed in trees
% - tree     ::structured output tree
% - order    ::Nx1 vector:   vector of new indices
%
% Example
% -------
% redirect_tree  (sample2_tree, 5, '-s')
%
% See also   sort_tree
% Uses       PL_tree ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [tree, order] = redirect_tree (intree, istart, options)

ver_tree     (intree);                 % verify that input is a tree
tree         = intree;

if (nargin < 2) || isempty (istart)
    % {DEFAULT index: last node in tree}
    istart   = size (tree.dA, 1);
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

if sum (tree.dA (:, istart)) == 2
    warning      (...
        'TREES:BCTinconsistency', ...
        'branching point! => trifurcation will occur');
end

% simple use of the adjacency matrix again
A                = tree.dA + tree.dA';
counter          = 1;
W                = A (:, istart);
PL               = W;
resW             = W;
% maximum depth by 2x maximum path length for when root is in center:
maxPL            = max (PL_tree (tree)) * 2;
while ((sum (sum (resW == 1)) ~= 0) && (counter <= maxPL))
    counter      = counter + 1;
    % use adjacency matrix to walk through tree:
    resW         = A * resW;
    PL           = PL + counter .* (resW == 1);
end
PL (istart)      = 0;
[~, order]          = sort (PL);

% change the trees-structure according to the new order:
tree.dA          = tril (A (order, order));
% in all vectors of form Nx1
S                = fieldnames (tree);
for counter      = 1 : length (S)
    if ~strcmp   (S{counter}, 'dA')
        vec      = tree.(S{counter});
        if  (isvector (vec)) && (numel(vec) == size (tree.dA, 1))
            tree.(S{counter}) = tree.(S{counter}) (order);
        end
    end
end

if contains (options,'-s') % show option
    clf;
    hold         on; 
    HP           = plot_tree  (intree, [], [], [], [], '-b');
    set          (HP, ...
        'facealpha',           0.2, ...
        'edgecolor',           'none');
    plot_tree    (tree,   [1 0 0], [], [], [], '-3q');
    pointer_tree (tree,   1);
    T            = vtext_tree (intree, [], [0 1 0], [-2 3 5]);
    set          (T, ...
        'fontsize',            14);
    T            = vtext_tree (tree,   [],      [],  [0 0 5]);
    set          (T, ...
        'fontsize',            14);
    title        ('redirect to other root node');
    HP (1)       = plot (1, 1, 'g-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, {'before', 'after'});
    set          (HP, ...
        'visible',             'off');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

