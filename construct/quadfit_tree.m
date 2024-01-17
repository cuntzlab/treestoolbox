% QUADFIT_TREE   Fit quadratic diameter taper to tree.
% (trees package)
% 
% [P0, tree] = quadfit_tree (intree, options)
% -------------------------------------------
%
% To a given tree with diameter values fits a quadratic tapering according
% to "quaddiameter_tree". The output is a scaling and an offset value in P0
% for direct use in "quaddiameter_tree".
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options  ::string: 
%    '-s'    : show
%    '-w'    : waitbar
%    {DEFAULT ''}
%
% Output
% ------
% - P0       ::pair of values: scaling and an offset value
%     (see "quaddiameter_tree")
% - tree::   structured output tree
%
% Example
% -------
% P0         = quadfit_tree (sample_tree, '-s')
%
% See also quaddiameter_tree
% Uses quaddiameter_tree fminsearch
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function  [P0, tree] = quadfit_tree (intree, options)

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

if contains  (options, '-w')   % waitbar option: initialization
    HW       = waitbar (0.3, 'fitting quad diameter...');
    set      (HW, ...
        'Name',                '..PLEASE..WAIT..YEAH..');
end

P0               = fminsearch (@(P) qfit (P, intree), rand (1, 2));

if contains      (options, '-w')   % waitbar option: close
    close        (HW);
end

if (nargout > 1) || contains (options, '-s')
    tree         = quaddiameter_tree (intree, P0 (1), P0 (2), 'none');
end

if contains      (options, '-s') % show option
    clf;
    hold         on;
    plot_tree    (tree,   [1 0 0]);
    plot_tree    (intree, [0 0 0], 20);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, {'before', 'after'});
    title        ('fitted quadratic diameter taper');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         equal;
end

end

function err     = qfit (P, intree)
qtree            = quaddiameter_tree (intree, P (1), P (2));
err              = norm (intree.D - qtree.D);
end

