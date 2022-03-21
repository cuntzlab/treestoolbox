% BOUNDARY_TREE Produces spanning boundary of a tree.
% (trees package)
%
% [bound] = boundary_tree (intree, c, options)
% --------------------------------------------
%
% returns a boundary structure in two- or three- dimensions.
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options::string: {DEFAULT: '-3d'}
%     '-3d'  : three-dimensional triangulation
%     '-2d'  : two-dimensional polygon
%     '-s'   : Show boundary mesh
% - c        : convexity of intree: 
%    {DEFAULT: Unknown, calculated using convexity_tree}
%
% Output
% -------
% bound::structure: in two dimensions an ordered set of vertices (xv, yv)
% of the bounding polygon and the area bounded (V). In three dimensions the
% Faces and Vertices of the triangulation and the volume bounded (V).

% Example
% -------
% boundary_tree (sample_tree, '-3d')
%
% See also convexity_tree
% Uses convexity_tree
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009 - 2022 Hermann Cuntz

function [bound] = boundary_tree (intree,options,c)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '-3d';
end

if (nargin < 3) || isempty (c)
    % {DEFAULT: convexity unknown}
    c = convexity_tree (intree, options);
end

S                = 1 - c; % Optimal shrink factor
if contains (options, '-2d') % Two-dimensional case    
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
    
    [k,V]=boundary(X,Y,Z,S);
    
    figure
    F=gcf;
    h=trisurf(k,X,Y,Z);
    [rh]=reducepatch(h,0.5);
    rh.Vertices=rh.vertices;
    rh.Faces=rh.faces;
    bound=rh;
    bound.V=V;
    close(F)
end
end

