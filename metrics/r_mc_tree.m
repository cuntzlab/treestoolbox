% R_MC_TREE   Checks R value in given tree.
% (trees package)
%
% [R, Rmin, Rmax, r0, rE, rEmin, rEmax, rEstd, n, rEs] = ...
%     r_mc_tree (tree, alpha, n_mc, level, options)
% -------------------------------------------------------------
%
% Calculates the R value in a given tree using a Monte Carlo approach.
% It is possible to calculate the R value for all the points in the tree,
% only for branch points and termination points or only for branch points
% or only for termination points. By default, a volume correction is applied
% to prevent the R value from being positively biased. It is also possible
% to calculate confidence intervals for the R value.
%
% Inputs
% ------
% - tree     ::structured tree
% - alpha    ::value	  : shrink factor used to obtain the volume
%		supporting a given point cloud. alpha is a scalar between 0 and 1.
%		Setting alpha to 0 gives the convex hull, and setting alpha to 1
%		gives a compact boundary that envelops the points
%     	{DEFAULT: 0.5}
% - n_mc     :: integer   : maximum number of Monte Carlo iterations
%     	{DEFAULT: 100}
% - level    ::value	  : confidence intervals are obtained with
%		confidence level (1 - level)
%     	{DEFAULT: 0.05}
% - options  ::string:
%     	'-nv' : no volume correction
%     	'-c' : compute confidence intervals
%     	'-bt' : R value for branch points and termination points
%     	'-b' : R value for branch points
%     	'-t' : R value for termination points
%     	'-dim2' : 2D tree (Careful, it used to be '-2d')
%     	{DEFAULT: ''}
%
% Output
% ------
% - R:: R value (r0/rE) of the points of interest (all points in the tree, only
%		branch and termination points, only branch points or only termination points)
% - Rmin:: lower bound of the confidence interval for R (r0/rEmax)
% - Rmax:: upper bound of the confidence interval for R (r0/rEmin)
% - r0:: observed average nearest neighbor distance between the points
% - rE:: expected average nearest neighbor distance under the assumption
%		of a uniform random distribution (estimated via Monte Carlo)
% - rEmin:: lower bound of the confidence interval for rE
% - rEmax:: upper bound of the confidence interval for rE
% - rEstd:: standard deviation of the rE values obtained in the n_mc Monte Carlo
%		iterations
% - n:: number of analyzed points to obtain R
% - rEs:: average nearest neighbor distances under the assumption
%		of a uniform random distribution in the n_mc Monte Carlo iterations
%
% Example
% -------
% r_mc_tree (sample_tree);
%
% See also PP_generator_tree
% Uses
%
% Contributed by Laura Anton
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function out = r_mc_tree (tree, varargin)

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('alpha', 0.5, @isnumeric) % TODO check for the size adn type of alpha
p.addParameter('n_mc', 100, @isnumeric) % TODO check for the size adn type of n_mc
p.addParameter('level', 0.05, @isnumeric) % TODO check for the size adn type of level
p.addParameter('nv', false, @isBinary)
p.addParameter('c', false, @isBinary)
p.addParameter('bt', false, @isBinary)
p.addParameter('b', false, @isBinary)
p.addParameter('t', false, @isBinary)
p.addParameter('dim2', false, @isBinary)
pars = parseArgs(p, varargin, {'alpha', 'n_mc', 'level'}, ...
    {'nv', 'c', 'bt', 'b', 't', 'dim2'});
%==============================================================================%

X            = tree.X;
Y            = tree.Y;
Z            = tree.Z;
if pars.bt
    idx      = find (B_tree (tree) | T_tree (tree));
elseif pars.b
    idx      = find (B_tree (tree));
elseif pars.t
    idx      = find (T_tree (tree));
else
    idx      = 1 : numel (X);
end
% coordinates of the points to compute R
X            = X (idx);
Y            = Y (idx);
Z            = Z (idx);
out.n        = numel (idx);
bb           = [ ...
    (min (X)) (max (X)); ...
    (min (Y)) (max (Y)); ...
    (min (Z)) (max (Z))];

%bdRef: vector of point indices representing a single conforming 2D boundary around the points X Y
%	or triangulation representing a single conforming 3D boundary around the points X Y Z
%vRef: area (2D) or volume (3D) which boundary bdRef encloses
if pars.dim2
    [bdRef, vRef] = boundary(X, Y, pars.alpha);
    XYZ      = [X, Y];
else
    [bdRef, vRef] = boundary(X, Y, Z, pars.alpha);
    XYZ      = [X, Y, Z];
end

% r0 from tree
[~, d]           = knnsearch (XYZ, XYZ, 'k', 2);
distsRef         = d (:, 2)';
out.r0           = mean (distsRef);

% estimate rE via mc
n_bs             = 1000;
out.rEs          = zeros (pars.n_mc, 1);
rEcis            = nan   (pars.n_mc, 2);
pts              = random_in_boundary (X, Y, Z, ...
    bb, bdRef, vRef, out.n * pars.n_mc, pars.dim2);
for counter      = 1 : pars.n_mc
    s            = (counter - 1) * out.n + 1 : counter * out.n;
    p            = pts (s, :);
    if pars.nv % volume correction
        if pars.dim2
            [~, vMc] = boundary (p (:, 1), p (:, 2), pars.alpha);
            volscale = sqrt(vRef / vMc);
        else
            [~, vMc] = boundary (p (:, 1), p (:, 2), p (:, 3), pars.alpha);
            volscale = (vRef / vMc) ^ (1 / 3);
        end
        p        = p * volscale;
    end
    [~, d]       = knnsearch (p, p, 'k', 2);
    mu           = mean (d (:, 2));
    out.rEs (counter) = mu;
    if pars.c % confidence intervals
        muci     = bootci (n_bs, {@mean, d(:, 2)}, 'alpha', pars.level);
        rEcis (counter, :) = muci;
    end
end
out.rE           = mean (out.rEs);
out.rEstd        = std  (out.rEs);
out.rEmin        = mean (rEcis (:, 1));
out.rEmax        = mean (rEcis (:, 2));
out.R            = out.r0 / out.rE;
out.Rmin         = out.r0 / out.rEmax;
out.Rmax         = out.r0 / out.rEmin;

end

%==============================================================================%
%==============================================================================%
function points  = random_in_boundary (X, Y, Z, bb, bd, v, n, is2d)
if is2d
    bbvol    = prod (bb (1 : 2, 2) - bb (1 : 2, 1));
    bdX      = X (bd);
    bdY      = Y (bd);
else
    bbvol    = prod (bb (:, 2)     - bb (:, 1));
    XYZ      = [X, Y, Z];
    fv       = struct ('vertices', XYZ, 'faces', bd);
end
volfrac      = bbvol / v;
points       = [];
while (size (points, 1) < n)
    if size (points, 1) == 0
        ntilde = max (round (n * volfrac * 1.2), 1);
    else
        ntilde = max (round (n * volfrac * 0.1), 1);
    end
    pX       = bb (1, 1) + ...
        rand (ntilde, 1) * (bb (1, 2) - bb (1, 1));
    pY       = bb (2, 1) + ...
        rand (ntilde, 1) * (bb (2, 2) - bb (2, 1));
    if is2d
        pXYZ = [pX, pY];
        ds   = p_poly_dist(pX, pY, bdX, bdY, true);
        inside = ds <= 0 + (-1) * ds > 0;
    else
        pZ   = bb (3, 1) + ...
            rand (ntilde, 1) * (bb (3, 2) - bb (3, 1));
        pXYZ = [pX, pY, pZ];
        inside = inpolyhedron (fv, pXYZ);
    end
    idx      = find (inside == 1);
    if numel (idx) + size (points, 1) > n
        idx  = idx (1 : n - size (points, 1));
    end
    points   = [points; (pXYZ (idx, :))];
end
end
%==============================================================================%