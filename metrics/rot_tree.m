% ROT_TREE   Rotate a tree.
% (trees package)
%
% tree = rot_tree (intree, DEG, options)
% --------------------------------------
%
% Rotates a cell's anatomy by multiplying each point in space with a simple
% 3by3 (3D) or 2x2 (2D) rotation-matrix. Rotation along principal
% components is also possible. It helps to center the tree with tran_tree
% beforehand except if rotation around a different point is required.
%
% Input
% -----
% - intree   ::integer:index of tree in trees or structured tree
% - DEG      ::1/3-tupel: degrees of rotation around resp. axis (0-360).
%     The sequence is as defined in rotation_matrix: x then y then z-axis.
%     If 1-tupel rotation is in XY plane. {DEFAULT: [0 0 90]}
% - options  ::string:
%     '-s'    : show before and after
%     '-pcaX' : rotate using PCA, sorting X Y Z axes in decreasing order
%               of geometrical extent
%     '-pcaY' : rotate using PCA, sorting Y X Z axes in decreasing order
%               of geometrical extent
%     '-pcaZ' : rotate using PCA, sorting Z Y X axes in decreasing order
%               of geometrical extent
%     '-m3dX' : mean axis, 3-dimensional, central axis lays on x-axis
%     '-m3dY' : mean axis, 3-dimensional, central axis lays on y-axis
%     '-m3dZ' : mean axis, 3-dimensional, central axis lays on z-axis
%     '-al'   : align region borders
%     m3d was implemented by Marcel Beining 2012, modified 2017
%     For the case of m3d first input DEG becomes index of
%     subset of nodes to be used for obtaining PCs
%     {DEFAULT: ''}
%
% Output
% -------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% rot_tree     (sample_tree, [0 30 0], '-s')
%
% See also tran_tree scale_tree flip_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2017  Hermann Cuntz

function varargout = rot_tree (intree, DEG, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees{intree};
else
    tree     = intree;
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

if strfind       (options, '-m3d')
    % define axis to which tree is aligned: 1=x 2=y 3=z
    if     strfind (options, '-m3dX')
        e        = [0 1 0];
        raxis    = 1;
        d = [2 3];
        %         sigcos   = 3;
    elseif strfind (options, '-m3dY')
        e        = [1 0 0];
        raxis    = 2;
        d = [3 1];
        %         sigcos   = 2;
    else
        e        = [1 0 0];
        raxis    = 3;
        d = [1 2];
        %         sigcos   = 2;
    end
    XYZ0         = [ ...
        (tree.X (1)) ...
        (tree.Y (1)) ...
        (tree.Z (1))];
    tree         = tran_tree (tree); % translate tree to coordinate origin 
    a            = zeros (1, 3);
    a (raxis)    = 1;
    angout       = zeros (3, 3);
    raxon        = find (strcmpi (tree.rnames, 'axon'));
    if isempty   (raxon)
        raxon    = 0;
    end
    for counter  = 1 : 2      % first rotate to x axis
        mXYZ     = [ ...
            (mean (tree.X (tree.R ~= raxon))) ...
            (mean (tree.Y (tree.R ~= raxon))) ...
            (mean (tree.Z (tree.R ~= raxon)))];
        % make 2D norm vector orthogonal to current rotation axis:
        mXYZ (d (1)) = 0; 
        mXYZ     = mXYZ / sqrt (sum (mXYZ.^2));
        rangle   = zeros (3, 1);
        % simple angle calculation by dot product and corrections for left
        % hand rotation
        % cross product checks if mXYZ is in clockwise direction of axis
        % vector or not 
        rangle (d (1)) = ...
            sign (sum (cross (a, mXYZ))) * acosd (dot (a, mXYZ));   
        angout (counter, d (1)) = rangle (d (1));
        tree     = rot_tree (tree, rangle);
        d        = fliplr   (d); % for next turn rotate around the 2nd axis
    end
    % rotate tree to have maximum variation in xy (axis x and y) or xz
    % (axis z) direction using principal component analysis
    XYZ          = [ ...
        (tree.X (tree.R ~= raxon)) ...
        (tree.Y (tree.R ~= raxon)) ...
        (tree.Z (tree.R ~= raxon))];
    XYZ (:, raxis) = 0;    % delete information along aligned axis
    [coeff, ~, latent] = pca (XYZ);
    % defining quality of alignment (zero is bad because dendrites
    % distributed equally in 2 dim):
    qual         = latent (1) / latent (2) - 1; 
    rangle       = zeros  (3, 1);
    ang (1)      = real   (sign (sum (cross ( e, coeff (:, 1)))) * ...
        acosd (dot (coeff (:, 1),  e)));
    ang (2)      = real   (sign (sum (cross (-e, coeff (:, 1)))) * ...
        acosd (dot (coeff (:, 1), -e)));
    [~, angout(3, raxis)] = min (abs (ang));
    angout (3, raxis)  = ang (angout (3, raxis));
    rangle (raxis)     = angout (3, raxis);
    % rotate tree to have maximum variation onto that axis:
    tree         = rot_tree (tree, rangle);    
    rangle (raxis) = 0;
    % only for y or x alignment:
    if ~isempty (regexpi (options,'-al')) && raxis < 3
        % get index of region to which tree should be aligned:
        if numel (options) >= regexpi (options, '-al') + 3  
            ind  = str2num (options (regexpi (options, '-al') + 3));
        else
            ind  = 5;
        end
        idpar    = idpar_tree (tree);   % get parent node indices
        % find points at border of region:
        in       = find (tree.R == ind  & tree.R (idpar) == ind - 1);
        if isempty  (in)
            warning (['No points between region %s and %s found.' ...
                ' Alignment could not be done'], ...
                tree.rnames{ind}, tree.rnames{ind-1})
        else
            allpoints  = [    ... % creacte a plane of points
                (tree.X (in)) ...
                (tree.Y (in)) ...
                (tree.Z (in))]; 
            allp_mean  = mean (allpoints, 1);
            % Subtract "mean" point:
            allp_subsmean = bsxfun (@minus, allpoints, allp_mean);
            [~, ~, V]  = svd (allp_subsmean, 0);
            n          = V (:, 3)';  % get vector orthogonal to plane
            n (setdiff (d, 3)) = [];
            n          = n / norm (n);
            if n (1)   < 0
                n      = -n;
            end
            % get angle between plane and axis vector:
            rangle (setdiff (d, 3)) = ...
                sign (n (2)) * acosd (dot ([1 0], n, 2));  
            % correct tree rotation for that angle:
            angout (:, end + 1) = rangle (setdiff (d, 3));
            tree = rot_tree (tree, rangle);
        end
    end
    tree         = tran_tree (tree, XYZ0);
elseif strfind   (options, '-pca')
    tree         = tran_tree (tree); % translate tree to coordinate origin
    XYZ          = [tree.X tree.Y tree.Z];
    [~, XYZp]    = pca (XYZ);
    if strfind   (options, '-pcaX')
        Xp       = XYZp (:, 1);
        Yp       = XYZp (:, 2);
        Zp       = XYZp (:, 3);
    elseif strfind (options, '-pcaY')
        Xp       = XYZp (:, 2);
        Yp       = XYZp (:, 1);
        Zp       = XYZp (:, 3);
    else
        Xp       = XYZp (:, 3);
        Yp       = XYZp (:, 2);
        Zp       = XYZp (:, 1);
    end
    tree.X       = Xp;
    tree.Y       = Yp;
    tree.Z       = Zp;
else
    if numel (DEG) == 1
        RM       =  [ ...        % rotation matrix 2D
            (cos (DEG)) (-sin (DEG)); ...
            (sin (DEG)) ( cos (DEG))];
        RXY      = [tree.X tree.Y] * RM;
        tree.X   = RXY (:, 1);
        tree.Y   = RXY (:, 2);
    else
        if length (DEG) == 2
            DEG  = [DEG 0];
        end
        % rotation matrix 3D see "rotation_matrix"
        RM       = rotation_matrix ( ...
            deg2rad (DEG (1)), ...
            deg2rad (DEG (2)), ...
            deg2rad (DEG (3)));
        RXYZ     = [tree.X tree.Y tree.Z] * RM;
        tree.X   = RXYZ (:, 1);
        tree.Y   = RXYZ (:, 2);
        tree.Z   = RXYZ (:, 3);
    end
end

if strfind       (options, '-s') % show option
    clf;
    hold         on;
    plot_tree    (intree);
    plot_tree    (tree, [1 0 0]);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, ...
        {'before', 'after'});
    set          (HP, ...
        'visible',             'off');
    title        ('rotate tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (3);
    grid         on;
    axis         image;
end

if (nargout > 0 || (isstruct (intree)))
    varargout{1}   = tree; % if output is defined then it becomes the tree
else
    trees{intree}  = tree; % otherwise add to end of trees cell array
end


