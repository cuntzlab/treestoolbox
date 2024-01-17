% SORT_TREE   sorts index of nodes in tree to be BCT conform.
% (trees package)
%
% [tree, order] = sort_tree (intree, options)
% -------------------------------------------
%
% Puts the indices in the so-called BCT order, an order in which elements
% are arranged according to their hierarchy keeping the subtree-structure
% intact. Many isomorphic BCT order structures exist, this one is created
% by switching the location of each element one at a time to the
% neighboring position of their parent element. For a unique sorting use
% '-LO' or '-LEX' options. '-LO' orders the indices using path length and
% level order. This results in a relatively unique equivalence relation.
% '-LEX' orders the BCT elements lexicographically. This makes less sense
% but results in a purely unique equivalence relation. "sort_tree" changes
% index in all vectors of form Nx1 accordingly.
%
% Input
% -----
% - intree   ::integer/tree: index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     '-LO'  : sort according to level order (see "LO_tree")
%     '-LEX' : lexicograph order: B before C before T at branch points
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
% - order    ::vector: vector of new indices
%
% Example
% -------
% sort_tree (sample_tree, '-s')
% sort_tree (sample_tree, '-s -LO')
%
% See also redirect_tree LO_tree BCT_tree isBCT_tree dendrogram_tree
% Uses idpar_tree ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [tree, order] = sort_tree (intree, options)

ver_tree     (intree);       % verify that input is a tree structure
tree         = intree;

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

N                = size (tree.dA, 1); % number of nodes in tree

if     contains (options, '-LO')
    % path length away from node:
    PL           = PL_tree (intree);
    % level order for each node (see "LO_tree"):
    LO           = LO_tree (intree);
    % order indices first according to path length then to level order
    [~, iipre]   = sortrows ([PL LO]);
    % change the adjacency matrix according to the new order:
    tree.dA      = tree.dA (iipre, iipre);
    % update all vectors of form Nx1:
    S            = fieldnames (tree);
    for counter  = 1 : length (S)
        if ~strcmp (S{counter}, 'dA')
            vec  = tree.(S{counter});
            if ...
                    (isvector (vec)) && ...
                    (numel    (vec) == size (tree.dA, 1)) && ...
                    ~(ischar  (vec))
                tree.(S{counter}) = tree.(S{counter})(iipre);
            end
        end
    end
elseif contains (options, '-LEX')
    % order indices first according to number of daughters:
    % this means that T comes first then C then B
    typeN        = full (sum (tree.dA)');
    [~, iipre]   = sort (typeN (2 : end));
    iipre        = [1;  (iipre + 1)];
    % change the adjacency matrix according to the new order:
    tree.dA      = tree.dA (iipre, iipre);
    % update all vectors of form Nx1
    S            = fieldnames (tree);
    for counter  = 1 : length (S)
        if ~strcmp (S{counter}, 'dA')
            vec  = tree.(S{counter});
            if   ...
                    (isvector (vec)) && ...
                    (numel    (vec) == size (tree.dA, 1)) && ...
                    ~(ischar  (vec))
                tree.(S{counter}) = tree.(S{counter})(iipre);
            end
        end
    end
else
    iipre        = (1 : N)';
end


idpar            = idpar_tree (tree); % index to direct parent
dA               = tree.dA;           % directed adjacency matrix of tree

% simple hierarchical sorting
ii               = 1 : N;
r2               = 1 : N;
for counter      = 2 : N
    elem         = r2 (counter); % sorting ii is not faster...
    par          = r2 (idpar (counter)); % parent node
    % just sort that the parent always comes directly before the daughter:
    if par > elem
        r        = [ ...
            (1 : elem - 1) ...
            (elem + 1 : par) ...
            elem ...
            (par + 1 : N)];
    elseif par == elem  % root
        r        = [ ...
            par ...
            elem ...
            (1 : elem - 1) ...
            (elem + 1 : N)];        
    else
        r        = [ ...
            (1 : par) ...
            elem ...
            (par + 1 : elem - 1) ...
            (elem + 1 : N)];
    end
    ii           = ii (r);
    [~, r2]      = sort  (ii);
end
order            = iipre (ii);

% change the trees-structure according to the new order:
tree.dA          = sparse (dA (ii, ii));
% in all vectors of form Nx1:
S                = fieldnames (tree);
for counter      = 1 : length (S)
    if ~strcmp   (S{counter}, 'dA')
        vec      = tree.(S{counter});
        if ...
                (isvector (vec)) && ...
                (numel    (vec) == size (tree.dA, 1)) && ...
                ~(ischar  (vec))
            tree.(S{counter}) = tree.(S{counter})(ii);
        end
    end
end

if contains (options, '-s') % show option
    clf;
    hold         on;
    HP           = plot_tree  (intree, [], [], [], [], '-b');
    set          (HP, ...
        'facealpha',           0.5, ...
        'edgecolor',           'none');
    T            = vtext_tree (intree, [], [0 1 0], [-2 3 5]);
    set          (T, ...
        'fontsize',           14);
    T            = vtext_tree (tree,   [],      [], [0 0 5]);
    set          (T, ...
        'fontsize',           14);
    title       ('sort nodes BCT conform');
    HP (1)      = plot (1, 1, 'g-');
    HP (2)      = plot (1, 1, 'r-');
    legend      (HP, {'before', 'after'});
    set         (HP, ...
        'visible',             'off');
    xlabel      ('x [\mum]');
    ylabel      ('y [\mum]');
    zlabel      ('z [\mum]');
    view        (2);
    grid        on;
    axis        image;
end

