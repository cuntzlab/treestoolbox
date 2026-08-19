% BLO_TREE   Branch length order.
% (trees package)
%
% BLO = BLO_tree (intree, V, options)
% --------------------------------
%
% Returns the primary branches by longest first. This function is useful
% for the topological analysis by Lida Kanari to obtain topological bar
% codes. It was first conceptualised with Gaia Tavosanis to make a
% biologically relevant ordering of branches. 
% This is a META-FUNCTION and can lead to various applications.
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - V        ::Nx1 vector: values to be integrated to select longest path
%     {DEFAULT: len_tree, segment length}
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% -------
% -  BLO     ::Nx1 vector: index value for each long attributing to order
% - lBLO     ::Nx1 vector: length of branches
% - clBLO    ::Nx1 vector: cumulative length of branches
%
% Example
% -------
% BLO_tree     (sample_tree, '-s')
%
% See also barcode_tree
% Uses ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz

function [BLO, lBLO, clBLO] = BLO_tree (intree, V, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees {intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (V)
    % {DEFAULT: length of segment in um, this way path length determines
    % order}
    V        = len_tree (tree);
end

V0           = [0; V];
N            = size (tree.dA, 1);
pV           = Pvec_tree (tree, V);

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

ipar             = ipar_tree (tree);
BLO              = zeros (N, 1);
lBLO             = zeros (N, 1);
clBLO            = zeros (N, 1);
counterO         = 1;
while ~(sum (sum (ipar))) == 0
    [~, i2]      = max (sum (V0 (ipar + 1) > 0, 2));
    i1           = sum (V0 (ipar (i2, :) + 1));    
    branch       = ipar (i2, :);
    branch (branch == 0) = [];
    i3           = cumsum (V (fliplr (branch)));
    clBLO (fliplr(branch)) = i3;
    lBLO (branch) = i1;
    BLO (branch) = counterO;
    counterO     = counterO + 1;
    ipar (ismember (ipar, branch)) = 0;
end
counterO          = counterO - 1;

if contains      (options, '-s') % show option
    R                = rand (counterO * 2, 3);
    clf;
    hold         on;
    HP           = plot_tree    (intree, BLO, [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    colormap         (R);    
    colorbar;
    title        ('Branch length order');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end



