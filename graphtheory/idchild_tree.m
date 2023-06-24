% IDCHILD_TREE   Index to direct child nodes in a tree.
% (trees package)
% 
% idchild = idchild_tree (intree, ipart, options)
% -----------------------------------------------
%
% Returns the indices to the direct child nodes for each individual node in
% the tree.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - ipart    ::index:        index to the subpart to be plotted
%     {DEFAULT: all nodes}
% - options  ::string:
%     '-s'   : show
%     '-1'   : output only first child
%     {DEFAULT: ''}
%
% Output
% ------
% - idchild  ::N x 2 vector: index of direct child node to each node
%
% Example
% -------
% idchild_tree (sample_tree, [], '-s')
%
% See also     ipar_tree child_tree
% Uses         ver_tree dA
%
% Contributed by Marcel Beining 2017
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function idchild = idchild_tree (intree, ipart, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree);                 % verify that input is a tree

% use only directed adjacency for this function
if ~isstruct (intree)
    dA       = trees{intree}.dA;
else
    dA       = intree.dA;
end

N            = size (dA, 1);

if (nargin < 2) || isempty (ipart)
    % {DEFAULT index: select all nodes/points}
    ipart    = (1 : N)';
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

idchild          = NaN (numel (ipart), 2);
[row, col]       = find (dA (:, ipart));

for n            = 1 : numel (ipart)
    idchild (n, 1 : sum (col == n)) = row (col == n)';
end

if contains (options, '-1')
   idchild       = idchild (:, 1); 
end

if contains (options, '-s')            % show option
    clf; 
    HP           = plot_tree  (intree, [], [], [], [], '-b');
    set          (HP, ...
        'facealpha',           0.2, ...
        'edgecolor',           'none');
    T            = vtext_tree (intree, [], [0 0.5 0], [-2 3 5]);
    set          (T, ...
        'fontsize',            14);
    inan         = ~isnan     (idchild (:, 1));
    T            = vtext_tree (intree, idchild (inan, 1), [1 0 0],  ...
        [0 0 5], [], inan);
    set          (T, ...
        'fontsize',            14);
    inan         = ~isnan     (idchild (:, 2));
    T            = vtext_tree (intree, idchild (inan, 2), [1 0.5 0],  ...
        [0 5 0], [], inan);
    set          (T, ...
        'fontsize',            14);
    title        ('direct child ID');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end



