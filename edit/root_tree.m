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
% Copyright (C) 2009 - 2023  Hermann Cuntz

function tree = root_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
tree         = intree;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {}, {'s'});
%==============================================================================%

N                = size (tree.dA, 1); % number of nodes in tree
% expand directed adjacency matrix:
tree.dA          = [ ...
    (zeros (1, N + 1)); [ ...
    (zeros (N, 1)) tree.dA]];
tree.dA (2, 1)   = 1; % connect new root to old root
S                = fieldnames (tree); % update all fields:
for counter      = 1 : length (S)
    if ~strcmp (S{counter}, 'dA') && ~strcmp (S{counter}, 'rnames')
        vec      = tree.(S{counter});
        if ...
                ~ischar  (vec) && ...
                ~(iscell (vec) && ischar   (vec{1})) && ...
                ~(iscell (vec) && isstruct (vec{1})) && ...
                isvector (vec) && ...
                (numel   (vec) == N)
            tree.(S{counter})   = [ ...
                tree.(S{counter})(1); ...
                tree.(S{counter})];
        end
    end
end

if isfield       (tree, 'X')
    tree.X (1)   = tree.X (1) - 0.0001;
end

if pars.s % show option
    clf;
    hold         on;
    pointer_tree (tree, 1);
    xplore_tree  (tree);
    title        ('root tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

