% BCT_TREE   Creates a tree from a BCT string.
% (trees package)
% 
% tree = BCT_tree (BCT, options)
% ------------------------------
%
% Finds the directed adjacency matrix from a BCT vector (0: terminal, 1:
% continuation, 2: branch), uses a stack.
% Creates a fake tree (see "xdend_tree").
%
% Input
% -----
% - BCT      ::1-D array: where 2:branching 1:continuation 0:termination
%     {DEFAULT: [1 2 1 0 2 0 0], a sample tree}
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     '-dA'  : only adjacency matrix without fake metrics
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     ::structured output tree
%
% Example
% -------
% BCT_tree     ([1 2 1 0 2 0 0], '-s');
% BCT_tree     ([1 2 1 0 2 0 0], '-s -dA');
%
% See also isBCT_tree xdend_tree dendrogram_tree sortBCT_tree allBCTs_tree
% Uses xdend_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function varargout = BCT_tree (BCT, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (BCT)
    BCT      = [1 2 1 0 2 0 0];
end

if (nargin < 2) || isempty (options)
    options  = '';
end

if ~isBCT_tree (BCT)
    error    ('input vector is not BCT conform');
end

zlen             = length (BCT);
STACK            = 1;
POINTER          = 1;
i1               = 0;
dA               = zeros (zlen, zlen);
for counter      = 1 : zlen
    if i1       ~= 0
        dA       (counter, i1) = 1;
    end
    i1           = counter;
    if BCT (counter) == 0
        % POP ART
        ART      = STACK (POINTER);
        POINTER  = POINTER - 1;
        i1       = ART;
    end
    if BCT (counter) == 2
        PC       = counter;
        % PUSH PC
        POINTER  = POINTER + 1;
        STACK (POINTER) = PC;
    end
end
dA               = sparse (dA);
tree             = [];
tree.dA          = dA;

% add metrics if not explicitly unwanted
if ~contains     (options, '-dA')
    if contains  (options, '-w')
        [~, tree] = xdend_tree (tree, '-w');
    else
        [~, tree] = xdend_tree (tree, 'none');
    end
end

if contains      (options, '-s') % show option
    clf;
    hold         on;
    if contains  (options, '-dA'),
        dendrogram_tree (tree, [], PL_tree (tree));
        axis     off;
    else
        plot_tree    (tree);
        pointer_tree ([0 0 0]);
        view     (2);
        grid     on;
        axis     image off;
    end
    title        ('BCT tree');
end

if (nargout > 0)
    % if output is defined then it becomes the tree
    varargout{1} = tree;
else
    % otherwise add to end of trees cell array
    trees{(length (trees) + 1)} = tree;
end



