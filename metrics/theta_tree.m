% THETA_TREE   Space filling measure.
% (trees package)
%
% [theta, hB, BW] = theta_tree (intree, options)
% ----------------------------------------------
%
% Uses bwdist (image processing toolbox) to measure the distances of
% NOTE: make sure tree is resampled to high resolution.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show before and after
%     '-e'   : no edges
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - theta    :: distance covering ~90%
% - hB       :: distance values
% - M        :: binary matrix
%
% Example
% -------
% theta_tree   (sample_tree, '-s')
%
% See also span_tree theta_mc_tree scaleS_tree scaleV_tree
% Uses span_tree ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz

function [theta, hB, BW] = theta_tree (intree, options)

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

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

radius           = round     (sqrt (     ...
    (max (tree.X) - min (tree.X)) .* ...
    (max (tree.Y) - min (tree.Y))) /2);
M                = span_tree (tree, radius, 'none');
S                = sum       (sum (M));
iP               = M;
span             = floor     (size (M, 1) / 2);
iM               = sub2ind   (size (M),  ...
    round (tree.Y) + span + 1, ...
    round (tree.X) + span + 1);

if contains      (options, '-e') % no edges
    M            = M * 0;
    M (iM)       = 1;
else
    M                = 1 - M;
    M  (iM)          = 1;
end
iP (iP == 0)     = NaN;
BW               = bwdist    (M);
BW               = BW .* iP;
hB               = reshape   (BW, numel (BW), 1);
hB (isnan (hB))  = [];
xax              = 0 : ceil  (max   (hB));
y                = cumsum    (histax (hB, xax));
theta            = find      (y > 0.9069 * S, 1, 'first');

if contains      (options, '-s') % show option
    clf;
    hold         on;
    mBW             = BW;
    mBW (isnan (mBW)) = 0;
    mBW             = double (mBW < theta) / 2;
    imagesc          ( ...
        -span : span, ...
        -span : span, ...
        mBW + 0.5);
    [~, hp]          = contour ( ...
        -span : span, ...
        -span : span, ...
        BW < theta, [0.5 0.5]);
    set              (hp, ...
        'color',                   [0.5 0.5 0.5], ...
        'linewidth',               0.5);
    hp               = plot_tree ( ...
        tree, [], [0 0 0], [], [], '-2l');
    hp               = plot ( ...
        tree.X (1), ...
        tree.Y (1), 'k.');
    set              (hp, ...
        'markersize',              6);
    colormap         gray
    set              (gca, ...
        'clim',                    [0 1]);
    xlim         ([-span span]);
    ylim         ([-span span]);
end


