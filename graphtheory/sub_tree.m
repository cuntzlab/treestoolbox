% SUB_TREE   Indices to child nodes forming a subtree.
% (trees package)
%
% [sub, subtree] = sub_tree (intree, inode, options)
% --------------------------------------------------
%
% Returns the indices of a subtree indicated by starting node inode.
%
% NOTE ! region update for tree output still missing!!!
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - inode    ::integer: index of starting node of subtree
%     {DEFAULT: node # 2}
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - sub      ::Nx1 vector: index of subtree: 1 if part of subtree, 0 if not
% - subtree  ::tree: subtree cut out
%
% Example
% -------
% sub_tree     (sample_tree, 166, '-s')
%
% See also
% Uses dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [sub, subtree] = sub_tree (intree, inode, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees{intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (inode)
    % {DEFAULT index: second node in tree}
    inode    = 2;
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

dA               = tree.dA; % directed adjacency matrix of tree
sub              = false (size (dA, 1), 1);
tdA              = dA (:, inode);
sub (inode)      = 1;
while sum (tdA)
    sub          = sub + tdA;
    tdA          = dA *  tdA;  % use adjacency matrix to walk through tree
end
sub              = logical (sub);

if strfind       (options, '-s') % show option
    clf;
    hold         on;
    HP           = plot_tree (intree, [],      [], ~sub, [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    HP           = plot_tree (intree, [1 0 0], [],  sub, [], '-b');
    set          (HP, ...
        'edgecolor',           'none');    
    title        ('cutout subtree');
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, ...
        {'rest', 'subtree'});
    set          (HP, ...
        'visible',             'off');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

if (nargout > 1)
    odA          = tree.dA;
    isub         = find    (sub);
    tree.dA      = tree.dA (isub, isub); % simple procedure
    % update all vectors of form N x 1
    S            = fieldnames (tree);
    for counter  = 1 : length (S)
        if ~strcmp (S{counter}, 'dA')
            vec  = tree.(S{counter});
            if (isvector (vec)) && (numel (vec) == size (odA, 1))
                tree.(S{counter}) = tree.(S{counter})(isub);
            end
        end
    end
    subtree      = tree;
end



