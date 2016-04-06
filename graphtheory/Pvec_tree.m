% PVEC_TREE   Cumulative summation along paths of a tree.
% (trees package)
% 
% Pvec = Pvec_tree (intree, v, options)
% -------------------------------------
%
% Cumulative vector, calculates the total path to the root cumulating
% elements of v (addition) of each node. This is a META-FUNCTION and can
% lead to various applications.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - v        ::Nx1 vector:   for each node a number to be cumulated
%     {DEFAULT: len}
% - options  ::string:
%     '-s'   : shows first column of matrix dist
%     {DEFAULT: ''}
%
% Output
% ------
% - Pvec     ::Nx1 vector:   cumulative v along path from the root
%
% Example
% -------
% Pvec_tree    (sample_tree, [], '-s')
%
% See also   ipar_tree child_tree morph_tree bin_tree
% Uses       ipar_tree len_tree ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function Pvec = Pvec_tree (intree, v, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree);                 % verify that input is a tree

if (nargin < 2) || isempty (v)
    % {DEFAULT vector: lengths of segments}
    v        = len_tree (intree);
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

% parent index structure (see "ipar_tree"):
ipar             = ipar_tree (intree);
v0               = [0; v];

if size (ipar, 1) == 1
    Pvec         = v;
else
    Pvec         = sum (v0 (ipar + 1), 2);
end

if strfind       (options, '-s')       % show option
    clf;
    hold         on; 
    HP           = plot_tree (intree, Pvec, [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');    
    colorbar;
    title        ('path accumulation');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end







