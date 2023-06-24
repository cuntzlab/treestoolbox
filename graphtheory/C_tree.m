% C_TREE   Continuation point indices in a tree.
% (trees package)
% 
% C = C_tree (intree, options)
% ----------------------------
%
% Returns a binary vector which is one only where there is a continuation
% node (exactly one child). Continuation point indices are then find (C).
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% C          ::vertical logical vector: continuations are 1, others 0
%
% Example
% -------
% C_tree       (sample_tree, '-s')
%
% See also   B_tree T_tree typeN_tree BCT_tree isBCT_tree
% Uses       ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function C = C_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

% use only directed adjacency for this function
if ~isstruct (intree)
    dA       = trees{intree}.dA;
else
    dA       = intree.dA;
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

% sum (dA) (actually faster than sum(dA)) ;-)
% continuation points have one entry in dA:
C                = ((ones (1, size (dA, 1)) * dA) == 1)';

if contains (options,'-s') % show option
    clf;
    hold         on; 
    plot_tree    (intree, [], [], [], [], '-b');
    pointer_tree (intree, find (C), 50);
    title        ('continuation points');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end



