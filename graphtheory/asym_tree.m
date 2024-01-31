% ASYM_TREE   Branch point asymmetry.
% (trees package)
%
% asym = asym_tree (intree, vec, options)
% -------------------------------------
%
% Calculates for each branching point the ratio of the sums of the two
% daughter branches. The summed values are given by vec which attributes a
% value to each node. Typically this can be the count of terminals
% (default) or the cable length etc... For v1 is smaller summed value of
% sub-trees and v2 the other one: v1/(v1 + v2). Reports NaN where there is
% no branch point. Tree must be BCT (at least trifurcations are forbidden
% of course), use "repair_tree" if necessary.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - vec      ::vertical vector: values to be summed and ratioed
%     {DEFAULT: count child terminals (== "T_tree")} (Used to be called v)
% - options  ::string:
%     '-s'   : show
%     '-m'   : explanatory movie
%     '-v'   : use van Pelt definition of tree asymmetry, see
%              Van Pelt, Jaap, et al. "Tree asymmetry—a sensitive and 
%              practical measure for binary topological trees." Bulletin 
%              of mathematical biology 54.5 (1992): 759-784.
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
% Copyright (C) 2009 - 2023  Hermann Cuntz

function asym = asym_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
% use only directed adjacency for this function
dA           = intree.dA;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('vec', T_tree (intree)) % TODO check the size and type of vec
p.addParameter('s', false, @isBinary)
p.addParameter('m', false, @isBinary)
p.addParameter('v', false, @isBinary)
pars = parseArgs(p, varargin, {'vec'}, {'s', 'm', 'v'});
%==============================================================================%

% index of branching points:
iB               = find      (B_tree (intree));
% parent index paths (see "ipar_tree"):
ipar             = ipar_tree (intree);
% vector containing asymmetry values for each BP:
asym             = zeros     (length (iB), 1);

for counter      = 1 : length (iB)
    BB           = find      (dA (:, iB (counter)));
    % sub-tree1:
    [sub1, ~]    = ind2sub   (size (ipar), find (ipar == BB (1)));
    % sub-tree2:
    [sub2, ~]    = ind2sub   (size (ipar), find (ipar == BB (2)));
    % summed values for sub-trees:
    v1           = sum       (pars.vec (sub1));
    v2           = sum       (pars.vec (sub2));
    % calculation of asymmetry:
    if pars.v
        if v1 + v2 > 2
            asym(counter) = abs(v1 - v2) / (v1 + v2 - 2);
        else
            asym(counter) = 0;
        end
    else
        if v1 <= v2
            asym (counter) = v1 / (v1 + v2);
        else
            asym (counter) = v2 / (v1 + v2);
        end
    end
    if pars.m       % movie option
        clf;
        hold     on;
        HP       = plot_tree (intree);
        set      (HP, ...
            'facealpha', 0.2);
        if numel (sub1) > 1
            plot_tree (intree, [1 0 0], [], sub1);
        end
        if numel (sub2) > 1
            plot_tree (intree, [0 1 0], [], sub2);
        end
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
tasym            = asym;
asym             = NaN (size (dA, 1), 1);
asym (iB)        = tasym;

if pars.s % show option
    clf;
    hold         on;
    HP           = plot_tree (intree, [], [], find (~B_tree (intree)));
    set          (HP, ...
        'facealpha',           0.2);
    iB           = find (B_tree (intree));
    plot_tree    (intree, asym (iB), [], iB);
    title        ([...
        'asymmetry at branch points, mean: ' ...
        (num2str (mean (asym, 'omitnan')))]);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
    set          (gca, ...
        'clim',                [0 0.5]);
    colorbar;
end

