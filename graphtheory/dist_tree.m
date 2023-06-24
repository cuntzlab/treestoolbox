% DIST_TREE   Index to tree nodes at um path distance away from root.
% (trees package)
% 
% dist = dist_tree (intree, l, options)
% -------------------------------------
%
% Returns a binary output with the nodes which are in path distance l
% from the root. If l is a vector dist is a matrix. 
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - l        ::horizontal vector: distances from the root in um
%     {DEFAULT: 100}
% - options  ::string:
%     '-s'   : shows nodes dist
%     {DEFAULT: ''}
%
% Output
% ------
% - dist     ::sparse binary matrix (N x length(l)): 1 when node segement
%     is in distance l
%
% Example
% -------
% dist_tree    (sample_tree, [50 100], '-s')
%
% See also   sholl_tree Pvec_tree
% Uses       len_tree Pvec_tree idpar_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function dist = dist_tree (intree, l, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (l)
    % {DEFAULT horizontal vector: one value, 100 um}
    l        = 100; 
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

% path length from the root [um]:
Plen             = Pvec_tree  (intree, len_tree (intree));
 % vector containing index to direct parent:
idpar            = idpar_tree (intree);
llen             = size   (l, 2);
l                = repmat (l, size (Plen, 1), 1);
% node itself is more than l path length from root but parent is less:
dist             = sparse ( ...
    (l >= repmat (Plen (idpar), 1, llen)) & ...
    (l <  repmat (Plen, 1, llen)));

if contains (options, '-s') % show option
    clf;
    hold         on;
    plot_tree        (intree, [0 0 0], [], ~sum (dist, 2));
    for counter      = 1 : size (dist, 2)
        plot_tree    (intree, [1 0 0], [], dist (:, counter));
    end
    title        ('distance crossing');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end



