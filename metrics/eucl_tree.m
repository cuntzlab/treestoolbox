% EUCL_TREE   Euclidean distances of all nodes of a tree to a point.
% (trees package)
% 
% eucl = eucl_tree (intree, point, options)
% -----------------------------------------
%
% returns the euclidean (as the bird flies) distance between all points on
% the tree and the root or any other point.
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
%       alternatively, intree can be a Nx3 matrix XYZ of points
% - point::XYZ 3-tupel horizontal: XYZ coordinates of reference point or
%     node index {DEFAULT: root, i.e. index 1}
% - options::string: {DEFAULT: ''}
%     '-s' : show
%
% Output
% ------
% eucl::Nx1 vector: euclidean distance values for each node
%
% Example
% -------
% eucl_tree (sample_tree, [], '-s')
%
% See also Pvec_tree len_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function eucl = eucl_tree (intree, point, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length(trees); % {DEFAULT tree: last tree in trees cell array} 
end;

if (nargin < 3)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

% use only node position for this function
if isnumeric(intree) && numel(intree)>1,
    X = intree (:, 1);
    Y = intree (:, 2);
    Z = intree (:, 3);
else
    ver_tree (intree); % verify that input is a tree structure
    if ~isstruct (intree),
        X =     trees {intree}.X;
        Y =     trees {intree}.Y;
        if isempty (strfind (options, '-2d')),
            Z = trees {intree}.Z;
        end
    else
        X = intree.X;
        Y = intree.Y;
        if isempty (strfind (options, '-2d')),
            Z = intree.Z;
        end
    end
end

if (nargin <2)||isempty(point),
    point = 1; % {DEFAULT: comparison point is the root}
end

if numel (point) == 1,
    point = [X(point) Y(point) Z(point)]; % coordinates for selected node
end

if isempty (strfind (options, '-2d')), % 3D option
    eucl = sqrt((X - point(1)).^2+ (Y - point(2)).^2 + (Z - point(3)).^2);
else
    eucl = sqrt((X - point(1)).^2+ (Y - point(2)).^2);
end

if strfind (options, '-s'), % show option
    clf; hold on; shine; plot_tree (intree, eucl); colorbar;
    title  ('euclidean distance [\mum]');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view(2); grid on; axis image;
end
