% EUCL_TREE   Euclidean distances of all nodes of a tree to a point.
% (trees package)
% 
% eucl = eucl_tree (intree, point, options)
% -----------------------------------------
%
% Returns the Euclidean (as the bird flies) distance between all points on
% the tree and the root or any other point.
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
%       alternatively, intree can be a Nx3 matrix XYZ of points
% - point    ::XYZ 3-tupel horizontal: XYZ coordinates of reference point
%     or node index
%     {DEFAULT: root, i.e. index 1}
% - options  ::string:
%     '-dim3'  : three-dimensional option
%     '-dim2'  : two-dimensional option
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% eucl       ::Nx1 vector: euclidean distance values for each node
%
% Example
% -------
% eucl_tree    (sample_tree, [], '-s')
%
% See also Pvec_tree len_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function eucl = eucl_tree (intree, varargin)

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('point', 1, @isnumeric) %TODO check for the size of point
p.addParameter('dim2', false, @isBinary)
p.addParameter('dim3', true, @isBinary)
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {'point'}, {'dim2', 'dim3', 's'});
%==============================================================================%

% use only node position for this function
if isnumeric (intree) && numel (intree) > 1
    X        = intree (:, 1);
    Y        = intree (:, 2);
    Z        = intree (:, 3);
else
    ver_tree (intree); % verify that input is a tree structure
    X    =   intree.X;
    Y    =   intree.Y;
    if pars.dim3
        Z  = intree.Z;
    end
end

if numel (pars.point) == 1
    % coordinates for selected node:
    pars.point        = [(X (pars.point)) (Y (pars.point)) (Z (pars.point))];
end

if pars.dim3 % 3D option
    eucl         = sqrt ( ...
        (X - pars.point (1)).^2 + ...
        (Y - pars.point (2)).^2 + ...
        (Z - pars.point (3)).^2);
else
    eucl         = sqrt ( ...
        (X - pars.point (1)).^2 + ...
        (Y - pars.point (2)).^2);
end

if pars.s % show option
    clf;
    hold         on;
    HP           = plot_tree (intree, eucl, [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    colorbar;
    title        ('euclidean distance [\mum]');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]'); 
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

