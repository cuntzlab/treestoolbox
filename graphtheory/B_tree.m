% B_TREE   Branch point indices in a tree.
% (trees package)
% 
% B = B_tree (intree, options)
% ----------------------------
%
% Returns a binary vector which is one only where there is a
% branching element (more than one child). Branch point indices are then
% find (B).
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
% B          ::Nx1 logical vector: branch points are 1, others 0
%
% Example
% -------
% B_tree       (sample_tree, '-s')
%
% See also   C_tree T_tree typeN_tree BCT_tree isBCT_tree
% Uses       ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2015  Hermann Cuntz

function B = B_tree (intree, options)

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

% sum (dA) (but actually faster than sum (dA)) ;-)
% branch points have more than one entry in dA:
B            = ((ones (1, size (dA, 1)) * dA) > 1)';

if strfind   (options, '-s') % show option
    clf; hold on; 
    HP       = plot_tree (intree);
    set      (HP, ...
        'facealpha',           0.2);
    HP       = pointer_tree (intree, find (B), 50);
    set      (HP, ...
        'facealpha',           0.2);
    title    ('branch points');
    xlabel   ('x [\mum]');
    ylabel   ('y [\mum]');
    zlabel   ('z [\mum]');
    view     (2);
    grid     on;
    axis     image;
end



