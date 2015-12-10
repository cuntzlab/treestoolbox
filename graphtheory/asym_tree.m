% ASYM_TREE   Branch point asymmetry.
% (trees package)
% 
% asym = asym_tree (intree, v, options)
% -------------------------------------
%
% Calculates for each branching point the ratio of the sums of the two
% daughter branches. The summed values are given by v which attributes a
% value to each node. Typically this can be the count of terminals
% (default) or the cable length etc... For v1 is smaller summed value of
% sub-trees and v2 the other one: v1/(v1 + v2). Reports NaN where there is
% no branch point. Tree must be BCT (at least trifurcations are forbidden
% of course), use "repair_tree" if necessary.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - v        ::vertical vector: values to be summed and ratioed
%     {DEFAULT: count child terminals (== "T_tree")}
% - options  ::string:
%     '-s'   : show
%     '-m'   : explanatory movie 
%     {DEFAULT: ''}
% 
% Output
% ------
% - asym     ::vector:       ratios for each branching points
%
% Example
% -------
% asym_tree    (sample_tree, [], '-m -s')
%
% See also   child_tree sub_tree
% Uses       ipar_tree B_tree ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2015  Hermann Cuntz

function asym = asym_tree (intree, v, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: : last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree); % verify that input is a tree structure

% use only directed adjacency for this function
if ~isstruct (intree)
    dA       = trees{intree}.dA;
else
    dA       = intree.dA;
end

if (nargin < 2) || isempty (v)
    % {DEFAULT vector: count termination points}
    v        = T_tree (intree);
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

% index of branching points:
iB           = find      (B_tree (intree));
% parent index paths (see "ipar_tree"):
ipar         = ipar_tree (intree);
% vector containing asymmetry values for each BP:
asym         = zeros     (length (iB), 1);

for counter      = 1 : length (iB)
    BB           = find (dA (:, iB (counter)));
    % sub-tree1:
    [sub1, ~]    = ind2sub (size (ipar), find (ipar == BB (1)));
    % sub-tree2:
    [sub2, ~]    = ind2sub (size (ipar), find (ipar == BB (2)));
    % summed values for sub-trees:
    v1           = sum (v (sub1));
    v2           = sum (v (sub2));
    % calculation of asymmetry:
    if v1 <= v2
        asym (counter) = v1 / (v1 + v2);
    else
        asym (counter) = v2 / (v1 + v2);
    end
    if strfind   (options, '-m')       % movie option
        clf; hold on;
        HP       = plot_tree (intree);
        set      (HP, ...
            'facealpha', 0.2);
        plot_tree    (intree, [1 0 0], [], sub1);
        plot_tree    (intree, [0 1 0], [], sub2);
        HT       = text (0, 0, num2str (asym (counter)));
        set      (HT,...
            'fontsize',        12,...
            'color',           [1 0 0]);
        title    ('asymmetry at branch points');
        xlabel   ('x [\mum]');
        ylabel   ('y [\mum]');
        zlabel   ('z [\mum]');
        view     (2);
        grid     on;
        axis     image;
        pause    (0.4);
    end
end
% map asym on a Nx1 vector, rest becomes NaN:
tasym        = asym;
asym         = NaN (size (dA, 1), 1);
asym (iB)    = tasym;

if strfind   (options, '-s') % show option
    clf; hold on;
    HP       = plot_tree (intree, [], [], find (~B_tree (intree)));
    set      (HP, ...
            'facealpha', 0.2);
    iB       = find (B_tree (intree));
    plot_tree    (intree, asym (iB), [], iB);
    title    ([...
            'asymmetry at branch points, mean: ' ...
            (num2str (nanmean (asym)))]);
    xlabel   ('x [\mum]');
    ylabel   ('y [\mum]');
    zlabel   ('z [\mum]');
    view     (2);
    grid     on;
    axis     image;
    set      (gca,...
            'clim',[0 0.5]);
    colorbar;
end
