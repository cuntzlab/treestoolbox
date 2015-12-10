% ROT_TREE   Rotate a tree.
% (trees package)
%
% tree = rot_tree (intree, DEG, options)
% --------------------------------------
%
% rotates a cell's anatomy by multiplying each point in space with a simple
% 3by3 (3D) or 2x2 (2D) rotation-matrix. Rotation along principal
% components is also possible. Then first pc is in x, second pc is in y,
% third pc is in z. It helps to center the tree with tran_tree beforehand
% except if rotation around a different point is required.
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - DEG::1/3-tupel: degrees of rotation around resp. axis (0-360). The
%     sequence is as defined in rotation_matrix: x then y then z-axis. If
%     1-tupel rotation is in XY plane. {DEFAULT: [0 0 90]}
% - options::string: {DEFAULT: ''}
%     '-s'    : show before and after
%     '-pc2d' : directs in principal components, 2-dimensional
%     '-pc3d' : directs in principal components, 3-dimensional
%     '-m3dX' : mean axis, 3-dimensional, central axis lays on x-axis
%     '-m3dY' : mean axis, 3-dimensional, central axis lays on y-axis
%     '-m3dZ' : mean axis, 3-dimensional, central axis lays on z-axis
%     m3d was implemented by Marcel Beining, 22 March 2012
%     NOTE! pc implementation does not work!
%     For the case of m3d and pc rotation first input DEG becomes index of
%     subset of nodes to be used for obtaining PCs
%
% Output
% -------
% if no output is declared the tree is changed in trees
% - tree:: structured output tree
%
% Example
% -------
% rot_tree (sample_tree, [0 30 0], '-s')
%
% See also tran_tree scale_tree flip_tree
% Uses ver_tree X Y Z
%
% Requires statistics toolbox for "princomp"
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function varargout = rot_tree (intree, DEG, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length(trees); % {DEFAULT tree: last tree in trees cell array}
end;

ver_tree (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree),
    tree = trees {intree};
else
    tree = intree;
end

if (nargin < 3)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

if (nargin < 2)||isempty(DEG),
    if strfind (options, '-pc'),
        DEG = (1 : length (tree.X))'; % {DEFAULT: use all nodes for PCs}
    else
        DEG = [0 0 90]; % {DEFAULT: rotate 90deg in z}
    end
end

if strfind (options, '-pc'),
    if strfind (options, '-pc2d'),
        XY = [tree.X tree.Y];
        p = princomp (XY (DEG, :));
        while sum (diag (p)) ~= size (p, 1),
            XY = XY * p';
            p = princomp (XY (DEG, :));
        end
        tree.X = XY (:, 1);
        tree.Y = XY (:, 2);
    else
        XYZ = [tree.X tree.Y tree.Z];
        p = princomp (XYZ (DEG, :));
        while sum (diag (p)) ~= size (p, 1),
            XYZ = XYZ * p';
            p = princomp (XYZ (DEG, :));
        end
        tree.X = XYZ (:, 1);
        tree.Y = XYZ (:, 2);
        tree.Z = XYZ (:, 3);
    end
elseif strfind (options, '-m3d')
    % define axis to which tree is aligned: 1=x 2=y 3=z
    if     strfind (options, '-m3dX')
        e = [0 1 0];
        raxis = 1;
        sigcos = 3;
    elseif strfind (options, '-m3dY')
%         e = [0 0 1];
        e = [1 0 0];
        raxis = 2;
        sigcos = 2;
    else
        e = [1 0 0];
        raxis = 3;
        sigcos = 2;
    end
    XYZ0       = [tree.X(1) tree.Y(1) tree.Z(1)];
    tree       = tran_tree (tree); % translate tree to coordinate origin
    d = [3 2];

    for ward   = 1 : 2      % first rotate to x axis
        mXYZ   = [mean(tree.X) mean(tree.Y) mean(tree.Z)];
        mXYZ (d (1)) = 0; % make 2D norm vector orthogonal to current rotation axis
        mXYZ   = mXYZ / sqrt (sum (mXYZ.^2));
        rangle = zeros (3, 1);
        % simple angle calculation by dot product and corrections for left
        % hand rotation
        rangle (d (1)) = sign(d(1)-2.5) * sign(mXYZ(d(2))) * acosd (dot ([1 0 0], mXYZ));
        tree   = rot_tree (tree, rangle);
        d      = fliplr (d); % for next turn rotate around the 2nd axis
    end
    
    if raxis > 1 % if tree should be rotated to axis other than x, do that
        rangle = zeros(3,1);
        rangle(d(raxis-1)) = sign(raxis-2.5) * 90;  % define left hand rotation around corresponding axis
        tree = rot_tree (tree,rangle);
    end

    % rotate tree to have maximum variation in xy (axis x and y) or xz
    % (axis z) direction using principal component analysis
    XYZ = [tree.X tree.Y tree.Z];
    XYZ(:,raxis)= 0;    % delete information along aligned axis
%         coeff = princomp(XYZ); % requires statistics toolbox
    [~,~,v] = svd (XYZ);
    coeff = v;
    rangle = zeros(3,1);
    rangle(raxis)=  sign(coeff(sigcos,1)) * acosd(dot(coeff(:,1),e));
    tree= rot_tree(tree,rangle);
    
    tree       = tran_tree (tree, XYZ0);
    
else
    if numel (DEG) == 1,
        RM =  [cos(DEG) -sin(DEG);sin(DEG) cos(DEG)]; % rotation matrix 2D
        RXY = [tree.X tree.Y] * RM;
        tree.X = RXY (:, 1);
        tree.Y = RXY (:, 2);
    else
        if length (DEG) == 2,
            DEG = [DEG 0];
        end
        % rotation matrix 3D see "rotation_matrix"
        RM = rotation_matrix (deg2rad( DEG (1)), deg2rad (DEG (2)), deg2rad (DEG (3)));
        RXYZ = [tree.X tree.Y tree.Z] * RM;
        tree.X = RXYZ (:, 1);
        tree.Y = RXYZ (:, 2);
        tree.Z = RXYZ (:, 3);
    end
end

if strfind (options, '-s') % show option
    clf; shine; hold on; plot_tree (intree); plot_tree (tree, [1 0 0]);
    HP (1) = plot (1, 1, 'k-'); HP (2) = plot (1, 1, 'r-');
    legend (HP, {'before', 'after'}); set (HP, 'visible', 'off');
    title  ('rotate tree');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view (3); grid on; axis image;
end

if (nargout > 0||(isstruct(intree)))
    varargout {1}  = tree; % if output is defined then it becomes the tree
else
    trees {intree} = tree; % otherwise add to end of trees cell array
end