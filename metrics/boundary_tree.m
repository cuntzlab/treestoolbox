% BOUNDARY_TREE Produces spanning boundary of a tree.
% (trees package)
%
% [bound] = boundary_tree (intree, c, options)
% --------------------------------------------
%
% Returns a boundary structure in two- or three- dimensions.
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - c        : convexity of intree:
%    {DEFAULT: Unknown, calculated using convexity_tree}
% - options  ::string: {DEFAULT: '-dim3'}
%     '-dim3'  : three-dimensional triangulation (Careful, it used to be '-3d')
%     '-dim2'  : two-dimensional polygon (Careful, it used to be '-2d')
%     '-s'   : Show boundary mesh % NOT IMPLEMENTS
%
% Output
% -------
% - bound    ::structure: in two dimensions an ordered set of vertices (xv, yv)
% of the bounding polygon and the area bounded (V). In three dimensions the
% Faces and Vertices of the triangulation and the volume bounded (V).
%
% Example
% -------
% boundary_tree (sample_tree, '-dim3')
%
% See also convexity_tree
% Uses convexity_tree
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009 - 2023 Hermann Cuntz

function bound = boundary_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('c', []) %TODO check for the size and type of c
p.addParameter('dim2', false, @isBinary)
p.addParameter('dim3', true, @isBinary)
pars = parseArgs(p, varargin, {'c'}, {'dim2', 'dim3', 's'});
%==============================================================================%

if isempty (pars.c)
    % {DEFAULT: convexity unknown}
    pars         = convexity_tree (intree, 'dim2', pars.dim2, 'dim3', pars.dim3);
end

S                = 1 - pars.c; % Optimal shrink factor

if pars.dim2 % Two-dimensional case
    X            = intree.X;
    Y            = intree.Y;

    [k, V]       = boundary (X, Y, S);

    xv           = X (k);
    yv           = Y (k);

    bound.xv     = xv;
    bound.yv     = yv;
    bound.V      = V;
else
    X            = intree.X;
    Y            = intree.Y;
    Z            = intree.Z;

    [k, V]       = boundary (X, Y, Z, S);

    figure
    F            = gcf;
    h            = trisurf (k, X, Y, Z);
    rh           = reducepatch (h, 0.5);
    rh.Vertices  = rh.vertices;
    rh.Faces     = rh.faces;
    bound        = rh;
    bound.V      = V;
    close        (F)
end

