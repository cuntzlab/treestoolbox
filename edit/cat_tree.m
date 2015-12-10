% CAT_TREE   Concatenates two trees.
% (trees package)
%
% tree = cat_tree (intree1, intree2, inode1, inode2, options)
% -----------------------------------------------------------
%
% Concatenates two trees (the second onto the first) at respective
% positions within the branching structure. Sorts the indices according to
% level order (see "sort_tree" with option '-LO'). Fields are prefarably
% taken from intree1, all vectors (X, Y, Z, D etc...) must exist in both if
% they exist in one tree and are concatenated as well. Region fields R and
% rnames are updated. By default, the second tree is connected at its root
% to the node in the first tree which is closest.
%
% Input
% -----
% - intree1  ::integer: index of tree 1 in trees or structured tree
% - intree2  ::integer: index of tree 2 in trees or structured tree
% - inode1   ::number:  position in first tree
%     {DEFAULT: node which is closest to inode2 of tree 2}
% - inode2   ::number:  position in second tree
%     {DEFAULT: root == 1}
% - options  ::string:
%     '-s'   : show
%     '-e'   : echo field degeneration
%     '-r'   : do not update regions
%     {DEFAULT: '-e'}
%
% Output
% ------
% if no output is defined tree intree1 is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% sample1    = sample_tree;
% sample2    = tran_tree (sample_tree, [100 70 0]);
% cat_tree   (sample1, sample2, [], [], '-s -e')
%
% See also delete_tree insert_tree
% Uses redirect_tree sort_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function varargout = cat_tree (intree1, intree2, inode1, inode2, options)

% trees : contains the tree structures in the trees package
global       trees

ver_tree     (intree1); % verify that input 1 is a tree structure
ver_tree     (intree2); % verify that input 2 is a tree structure

% use full tree 1 for this function
if ~isstruct (intree1)
    tree1    = trees{intree1};
else
    tree1    = intree1;
end

% use full tree 2 for this function
if ~isstruct (intree2)
    tree2    = trees{intree2};
else
    tree2    = intree2;
end

if (nargin < 4) || isempty (inode2)
    % {DEFAULT: root node of second tree}
    inode2   = 1;
end

if (nargin < 3) || isempty (inode1)
     % {DEFAULT: connect to node on first tree which is closest to inode2
     % of tree 2}
    [~, inode1]  = min (eucl_tree (tree1, [ ...
        (tree2.X (inode2)), ...
        (tree2.Y (inode2)), ...
        (tree2.Z (inode2))]));
end

if (nargin < 5) || isempty (options)
    % {DEFAULT: echo changes}
    options  = '-e';
end

% if inode2 is not root on tree2 set it to root:
tree2        = redirect_tree (tree2, inode2);
dA1          = tree1.dA;        % directed adjacency matrix of tree 1
dA2          = tree2.dA;        % directed adjacency matrix of tree 2
N1           = size   (dA1, 1); % number of nodes in tree 1
N2           = size   (dA2, 1); % number of nodes in tree 2
ndA          = sparse ( ...
    [[dA1; (sparse (N2, N1))], ...
    [(sparse (N1, N2)); dA2]]);
ndA (1 + N1, inode1) = 1;
tree.dA      = ndA;

% expand all fields, take only tree1 fields:
S                = fieldnames (tree1);
for counter      = 1 : length (S)
    if ~strcmp   (S{counter}, 'dA')
        vec1     = tree1.(S{counter});
        tree.(S{counter}) = vec1;
        if isfield (tree2, S{counter})
            vec2 = tree2.(S{counter});
            if      isvector (vec1) && (numel (vec1) == N1) && ~(ischar (vec1))
                if  isvector (vec2) && (numel (vec2) == N2) && ~(ischar (vec2))
                    tree.(S{counter}) = [ ...
                        tree1.(S{counter}); ...
                        tree2.(S{counter})];
                else
                    if strfind (options, '-e')
                        warning ( ...
                            'TREES:treeinconsistency', ...
                            ['degenerating field: ' S{counter}]);
                    end
                end
            end
        end
    end
end

% eliminate obsolete regions (only if everything is correct)
if isempty (strfind (options, '-r'))
    if isfield (tree1,'R') && isfield (tree2, 'R')
        if      isfield (tree1, 'rnames') && ...
                isfield (tree2, 'rnames')
            [i1, ~, i3]  = unique ([ ...
                tree1.rnames ...
                tree2.rnames]);
            R            = [tree1.R; (tree2.R + length (tree1.rnames))];
            if isrow     (i3)
                i3       = i3';
            end
            tree.R       = i3(R);
            tree.rnames  = i1;
        else
            [~, ~, i3]   = unique ([ ...
                tree1.R; ...
                tree2.R]);
            if isrow     (i3)
                i3       = i3';
            end
            tree.R       = i3;
        end
    end
end

tree         = sort_tree (tree, '-LO');

if strfind   (options, '-s')
    clf; hold on;
    plot_tree    (intree1);
    plot_tree    (intree2, [1 0 0]);
    plot_tree    (tree,    [0 1 0], [20 0 0]);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    HP (3)       = plot (1, 1, 'g-');
    legend       (HP, {'tree 1', 'tree 2', 'concat. tree'});
    set          (HP, ...
        'visible',             'off');
    title        ('concatenate two trees');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

if (nargout == 1) || (isstruct (intree1))
    varargout{1}   = tree;
else
    trees{intree1} = tree;
end
