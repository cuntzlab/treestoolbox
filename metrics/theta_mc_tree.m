% THETA_MC_TREE   Space filling measure - MC version.
% (trees package)
%
% [theta, hB] = theta_mc_tree (intree, NN, alpha, options)
% --------------------------------------------------------
%
% Statistical version for theta_tree that works for 3D cells. Uses tight
% boundary (alpha 0.5) and external function inpolyhedron.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - NN       ::integer: number of monte carlo points
%     {DEFAULT 250000 for 2d and 500000 for 3d}
% - alpha    ::value between 0..1: convexity for boundary function
%     {DEFAULT 0.5}
% - options  ::string:
%     '-2d   : 2d version
%     '-s'   : show before and after
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - theta    :: distance covering ~90%
% - hB       :: distance values
%
% Example
% -------
% theta_mc_tree   (sample_tree, 10000, 0.5, '-s -2d')
%
% See also theta_tree scale_tree tran_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz

function [theta, cyax] = theta_mc_tree (intree, NN, alpha, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 3) || isempty (alpha)
    % {DEFAULT: 0.5 boundary between convex and tight}
    alpha    = 0.5;
end

if (nargin < 4) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

if (nargin < 2) || isempty (NN)
    % {DEFAULT: 250000 Monte Carlo points in 2D}
    if contains (options, '-2d')
        NN   = 250000;
    else
        NN   = 500000;
    end
end

if contains (options, '-2d')
    X            = intree.X;
    Y            = intree.Y;
    bd           = boundary (X, Y, alpha);
    bdX          = X (bd);
    bdY          = Y (bd);
    rangeX       = range (intree.X);
    rangeY       = range (intree.Y);
    meanX        = min   (intree.X) + rangeX / 2;
    meanY        = min   (intree.Y) + rangeY / 2;
    ranger       = round (max ([rangeX rangeY]) * 1.1);
    pX           = meanX + (rand (NN, 1) - 0.5) * ranger;
    pY           = meanY + (rand (NN, 1) - 0.5) * ranger;
    inside       = inpolygon (pX, pY,bdX, bdY);
    inside       = find (inside);
    eucl         = zeros (1, length (inside));
    for counter  = 1 : length (inside)
        eucl (counter) = min (sqrt( ...
            (intree.X - pX (inside (counter))).^2 + ...
            (intree.Y - pY (inside (counter))).^2));
    end
    xax          = 0 : 0.01 : ceil (max (Pvec_tree (intree)));
    yax          = histax (eucl, xax);
    cyax         = cumsum (yax./sum (yax));
    theta        = find   (cyax < 0.9069, 1, 'last') / 100;
else
    X            = intree.X;
    Y            = intree.Y;
    Z            = intree.Z;
    bd           = boundary (X, Y, Z, alpha);
    fv           = struct ( ...
        'vertices',            [X Y Z], ...
        'faces',               bd);
    rangeX       = range (intree.X);
    rangeY       = range (intree.Y);
    rangeZ       = range (intree.Z);
    meanX        = min   (intree.X) + rangeX / 2;
    meanY        = min   (intree.Y) + rangeY / 2;
    meanZ        = min   (intree.Z) + rangeZ / 2;
    ranger       = round (max ([rangeX rangeY rangeZ]) * 1.1);
    pX           = meanX + (rand (NN, 1) - 0.5) * ranger;
    pY           = meanY + (rand (NN, 1) - 0.5) * ranger;
    pZ           = meanZ + (rand (NN, 1) - 0.5) * ranger;
    pXYZ         = [pX, pY, pZ];
    inside       = inpolyhedron (fv, pXYZ);
    inside       = find (inside);
    eucl         = zeros (1, length (inside));
    for counter  = 1 : length (inside)
        eucl (counter) = min ( ...
            eucl_tree ( ...
            intree, ...
            pXYZ (inside (counter), :)));
    end
    xax          = 0 : 0.01 : ceil (max (Pvec_tree (intree)));
    yax          = histax (eucl, xax);
    cyax         = cumsum (yax./sum (yax));
    theta        = find (cyax < 0.9069, 1, 'last') / 100;
end

if contains (options, '-s') % show option
    clf;
    hold         on;
    if contains (options, '-2d')
        hp       = plot_tree (intree, [], [], [], [], '-2l');
        set      (hp, ...
            'linewidth',       0.5);
        hp       = plot ( ...
            pX (inside (eucl > theta)), ...
            pY (inside (eucl > theta)), 'r.');
        set      (hp, ...
            'markersize', 6);
        hp       = patch (bdX, bdY, [0 0 0]);
        set      (hp, ...
            'facealpha',       0.2, ...
            'linestyle',       'none');
        xlabel   ('x [\mum]');
        ylabel   ('y [\mum]');
        view     (2);
    else
        hp       = plot_tree (intree, [], [], [], [], '-3l');
        set      (hp, ...
            'linewidth',           0.5);
        hp       = plot3 (...
            pX (inside (eucl > theta)), ...
            pY (inside (eucl > theta)), ...
            pZ (inside (eucl > theta)), ...
            'r.');
        set      (hp, ...
            'markersize', 2);
        xlabel   ('x [\mum]');
        ylabel   ('y [\mum]');
        zlabel   ('z [\mum]');
        view     (3);
    end
    title        ('spacefilling theta');
    grid         on;
    axis         image;
end


