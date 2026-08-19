% RANDOM_TREE   Uses MST to make toy trees
% (trees package)
%
% trees = random_tree (N, R, bf, ANI, options)
% ----------------------------------------------
%
% Creates a set of num trees similar to an input set of trees
% intrees by distributing points randomly in the spanning fields of the
% average intrees, scaling them within the variance of intrees and
% connecting them with "MST_tree", the minimum spanning tree constructor.
% "MST_tree" requires the balancing factor bf between minimization of path
% length and total wire length. Regions are defined as "soma", "spines"
% (ignored) and others with an additional "primary" region that can be
% grown first (so in 2 steps).
%
% Input
% -----
% - N        ::integer: Number of targets for MST_tree.
%     {DEFAULT: 100}
% - R        ::double:  Radius of the area covered by targets.
%     {DEFAULT: 100 um}
% - bf       ::number between 0 .. 1: balancing factor
%     {DEFAULT: 0.5}
% - ANI      ::number between 0 .. 1: isotropy of spanning area
%     {DEFAULT: 0.5}
% - options  ::string:
%     '-2d': Planar tree
%     '-sphere': circular instead of square
%     '-b'   : option for MST_tree
%     {DEFAULT '-w'}
%
% Output
% ------
%
% - tree     ::structured output trees
%
% Example
% -------
% tree = random_tree   (100, 100, 0.4, 1, '-2d -sphere')
%
% See also MST_tree
% Uses MST_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz


function tree = random_tree (N, R, bf, ANI, options)

if nargin < 1
    N = 100;
end

if nargin < 2
    R = 100;
end

if nargin < 3
    bf = 0.5;
end

if nargin < 4
    ANI = 1;
end

if nargin < 5
    options = '-3d -sphere';
end

X                = rand (N * 10, 1) * 2 * R - R;
X (1)            = 0;
Y                = rand (N * 10, 1) * 2 * R - R;
Y (1)            = 0;
Z                = rand (N * 10, 1) * 2 * R - R;
Z (1)            = 0;

if contains (options, '-2d')
    Z            = Y * 0;
end

if contains (options, '-sphere')
    eucl             = eucl_tree ([X Y Z]);
    X                = X (eucl < R);
    Y                = Y (eucl < R);
    Z                = Z (eucl < R);
end
X                = X (1 : N) * (1 / ANI);
Y                = Y (1 : N) * ANI;
Z                = Z (1 : N);

if contains (options, '-b')
    MSToptions   = '-b';
else
    MSToptions   = 'none';
end

tree             = MST_tree ( ...
    1, X, Y, Z, bf, 10000, 10000, [], MSToptions);



