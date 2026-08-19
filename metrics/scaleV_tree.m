% SCALEV_TREE   Scales a tree.
% (trees package)
%
% [xtree, sc] = scaleV_tree (intree, tV, alpha, options)
% -----------------------------------------------
%
% Scales the entire tree to ensure that the tree covers a target
% volume/surface tV. Uses the boundary function.
% NOTE: make sure tree is resampled to high resolution.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - tV       ::scalar:  target volume (or surface)
%     {DEFAULT: 1,000,000um3}
% - alpha    ::value between 0..1: convexity for boundary function
%     {DEFAULT 0.5}
% - options  ::string:
%     '-s'   : show before and after
%     '-d'   : do not scale diameter
%     '-2d'  : 2d
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
% - sc       :: scaling factor
% - V        :: original volume value
%
% Example
% -------
% scale_tree   (sample_tree, 1000000, '-s')
%
% See also scaleS_tree tran_tree theta_tree theta_mc_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz

function varargout = scaleV_tree (intree, tV, alpha, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees{intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (tV)
    % {DEFAULT: 1,000,000 um3}
    tV        = 1000000;
end

if (nargin < 3) || isempty (alpha)
    % {DEFAULT: 1,000,000 um3}
    alpha = 0.5;
end


if (nargin < 4) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end
if contains       (options, '-2d')
    % calculate tight hull volume
    [~, V]           = boundary (tree.X, tree.Y, alpha);
    
    % scale volume
    sc               = (tV ./ V) .^  (1 / 2);
    xtree            = scale_tree    (tree,  sc);
    
    % recalculate tight hull volume
    [~, V]           = boundary (xtree.X, xtree.Y, alpha);
    
    display          (['error in um2: ' (num2str ((V ./ tV) - 1))]);    
    
    
else
    % calculate tight hull volume
    [~, V]           = boundary (tree.X, tree.Y, tree.Z, alpha);
    
    % scale volume
    sc               = (tV ./ V) .^  (1 / 3);
    xtree            = scale_tree    (tree,  sc);
    
    % recalculate tight hull volume
    [~, V]           = boundary (xtree.X, xtree.Y, xtree.Z, alpha);
    
    display          (['error in um3: ' (num2str ((V ./ tV) - 1))]);
end
% scale volume again
if (nargout >= 1) || (isstruct (intree))
    varargout{1}   = xtree; % if output is defined then it becomes the tree
else
    trees {intree} = xtree; % otherwise add to end of trees cell array
end

if (nargout > 1)
    varargout{2}   = sc;
end

if contains       (options, '-s') % show option
    clf;
    hold         on;
    HP           = plot_tree (tree,       [], [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    HP           = plot_tree (xtree, [1 0 0], [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, ...
        {'before',             'after'});
    set          (HP, ...
        'visible',             'off');
    title        ('scale a tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (3);
    grid         on;
    axis         image;
end


