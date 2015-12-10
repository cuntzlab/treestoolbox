% ROOT_TREE   Add tiny segment at tree root.
% (trees package)
% 
% tree = root_tree (intree, options)
% ----------------------------------
%
% Roots a tree by adding tiny segment in the root.
% This function alters the original morphology!
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% root_tree    (sample_tree, '-s')
%
% See also neuron_tree
% Uses ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2015  Hermann Cuntz

function varargout = root_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees); 
end;

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees {intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

N            = size (tree.dA, 1); % number of nodes in tree
% expand directed adjacency matrix:
tree.dA      = [ ...
    (zeros (1, N + 1)); [ ...
    (zeros (N, 1)) tree.dA]];
tree.dA (2, 1) = 1; % connect new root to old root
S            = fieldnames (tree); % update all fields:
for ward     = 1 : length (S)
    if ~strcmp (S{ward}, 'dA')
        vec  = tree.(S{ward});
        if isvector (vec) && (numel (vec) == N) && ~(ischar (vec))
            tree.(S{ward})   = [ ...
                tree.(S{ward})(1); ...
                tree.(S{ward})];
        end
    end
end

if isfield       (tree, 'X')
    tree.X (1)   = tree.X (1) - 0.0001;
end

if strfind       (options, '-s') % show option
    clf; hold on; 
    HP           = pointer_tree (tree, 1); 
    set          (HP, ...
        'facealpha',           0.5);
    xplore_tree  (tree);
    title        ('root tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on; 
    axis         image;
end

if (nargout == 1) || (isstruct (intree))
    varargout {1}  = tree; % if output is defined then it becomes the tree
else
    trees {intree} = tree; % otherwise replace orginal tree in trees
end





