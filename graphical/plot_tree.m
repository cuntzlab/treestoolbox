% PLOT_TREE   Plots a tree.
% (trees package)
%
% HP = plot_tree (intree, color, DD, ipart, res, options)
% -------------------------------------------------------
%
% Plots a directed graph contained in intree. Many settings allow to play
% with the output results. Colour handling is different on line plots than
% on patchy '-b' or '-p'. Even if metrics are nonexistent plot_tree will
% plot its best guess for a reasonable tree (see "xdend_tree"). Line plots
% are always slower than any patch display.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - color    ::RGB 3-tupel:  RGB values
%     if vector then values are treated in colormap (must contain one value
%     per node then!).
%     if matrix (N x 3) then individual colors are mapped to each
%     element, works only on line-plots
%     {DEFAULT [0 0 0]}
% - DD       :: 1x3 vector:  coordinates offset
%     {DEFAULT no offset [0,0,0]}
% - ipart    ::index:        index to the subpart to be plotted
%     {DEFAULT: all nodes}
% - res      ::integer>1:    resolution for cylinders. Does not affect line
%     and quiver or blatt.
%     {DEFAULT: 8}
% - options  ::string: has to be one of the following:
%     '-b'   : 2D pieces are displayed on a 3D grid (-b stands for -blatt)
%     showing the diameter but not as real cylinders. Output is a
%     series of patches. Fastest representation.
%       '-b1': patches are mapped on x y 
%       '-b2': patches are mapped on x z
%       '-b3': patches are mapped on y z
%     '-p'   : correct cylinder representation but not yet flawless and a
%             bit slower than "blatt" representation.
%     '-2l'  : 2D (using only X and Y). forces line output (2D), no diameter
%             (slower), color is mapped independently of matlab, always
%             min to max.
%     '-3l'  : 3D. forces line output (2D), no diameter (slower, as '-2l')
%     '-2q'  : 2D (using only X and Y). edges are represented as arrows
%             (using quiver) . Color vectors do not work.
%     '-3q'  : 3D. edges are represented as arrows (using quiver, as '-q')
%   additional options:
%     '-thin'  : all diameters   1um, for line and quiver linewidth 0.25
%     '-thick' : all diameters + 3um, for line and quiver linewidth 3
%     {DEFAULT '-p'}
%
% Output
% ------
% - HP       ::handles:      links to the graphical objects.
%
% Example
% -------
% plot_tree    (sample_tree)
%
% See also   vtext_tree xplore_tree
% Uses       cyl_tree ver_tree
%
% directly adapted for TREES toolbox, code for correct cylinders from:
% Friedrich Forstner
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2017  Hermann Cuntz

function HP  = plot_tree (intree, color, DD, ipart, res, options)

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

if (~isfield (tree, 'X')) || (~isfield (tree, 'Y'))
    % if metrics are missing replace by equivalent tree:
    [~, tree] = xdend_tree (intree);
end

N            = size (tree.X, 1); % number of nodes in tree

if (nargin < 4) || isempty (ipart)
    % {DEFAULT index: select all nodes/points}
    ipart    = (1 : N)';
end

if (nargin < 2) || isempty (color)
    % {DEFAULT color: black}
    color    = [0 0 0];
end

if (size (color, 1) == N) && (size (ipart, 1) ~= N)
    color    = color  (ipart);
end
color        = double (color);

if (nargin < 3) || isempty (DD)
    % {DEFAULT 3-tupel: no spatial displacement from the root}
    DD       = [0 0 0];
end
if length (DD) < 3
    % append 3-tupel with zeros:
    DD       = [DD (zeros (1, 3 - length (DD)))];
end

if (nargin < 5) || isempty (res)
    % {DEFAULT: 8 points around cylinder}
    res      = 8;
end

if (nargin < 6) || isempty (options)
    % {DEFAULT: full cylinder representation}
    options  = '-p';
end

if strfind       (options, '-b')
    if isfield   (tree, 'D')
        D        = tree.D (ipart);
    else
        D        = ones (length (ipart), 1);
    end
    if strfind   (options, '-thin')
        D        = ones (length (ipart), 1);
    end
    if strfind   (options, '-thick')
        D        = D + 3;
    end
    [X1, X2, Y1, Y2, Z1, Z2] = ...
        cyl_tree (intree);
    X1           = X1 (ipart) + DD (1);
    X2           = X2 (ipart) + DD (1);
    Y1           = Y1 (ipart) + DD (2);
    Y2           = Y2 (ipart) + DD (2);
    Z1           = Z1 (ipart) + DD (3);
    Z2           = Z2 (ipart) + DD (3);
    % direction vectors:
    dP           = [   ...
        (X2 - X1)      ...
        (Y2 - Y1)      ...
        (Z2 - Z1)] ./  ...
        repmat (sqrt ( ...
        (X2 - X1).^2 + ...
        (Y2 - Y1).^2 + ...
        (Z2 - Z1).^2), 1, 3);
    a1           = strfind (options, '-b');
    if length    (options) > a1 + 1
        typ      = str2double (options (a1 + 2));
        if isnan (typ)
            typ  = 1;
        end
    else
        typ      = 1;
    end
    if isfield (tree, 'frustum') && (tree.frustum == 1)
        idpar    = idpar_tree (tree);
        parD     = D (idpar);
    end
    switch       typ    % draw plates (4 coordinates for one cylinder):
        case     2
            dP       = dP (:, [1 3]);
            % use rotation matrix to rotate the data
            V1       = (dP * [0 -1;  1 0]) .* (repmat (D,    1, 2) ./ 2);
            V2       = (dP * [0  1; -1 0]) .* (repmat (D,    1, 2) ./ 2);
            if isfield (tree,   'frustum') && (tree.frustum == 1)
                V3   = (dP * [0 -1;  1 0]) .* (repmat (parD, 1, 2) ./ 2);
                V4   = (dP * [0  1; -1 0]) .* (repmat (parD, 1, 2) ./ 2);
                MX   = [ ...
                    (X1 + V4 (:, 1)) ...
                    (X1 + V3 (:, 1)) ...
                    (X2 + V1 (:, 1)) ...
                    (X2 + V2 (:, 1))]';
                MY   = [Y1 Y1 Y2 Y2]';
                MZ   = [ ...
                    (Z1 + V4 (:, 2)) ...
                    (Z1 + V3 (:, 2)) ...
                    (Z2 + V1 (:, 2)) ...
                    (Z2 + V2 (:, 2))]';
            else
                MX   = [ ...
                    (X1 + V2 (:, 1)) ...
                    (X1 + V1 (:, 1)) ...
                    (X2 + V1 (:, 1)) ...
                    (X2 + V2 (:, 1))]';
                MY   = [Y1 Y1 Y2 Y2]';
                MZ   = [ ...
                    (Z1 + V2 (:, 2)) ...
                    (Z1 + V1 (:, 2)) ...
                    (Z2 + V1 (:, 2)) ...
                    (Z2 + V2 (:, 2))]';
            end
        case     3
            dP       = dP (:, [2 3]);
            % use rotation matrix to rotate the data
            V1       = (dP * [0 -1;  1 0]) .* (repmat (D,    1, 2) ./ 2);
            V2       = (dP * [0  1; -1 0]) .* (repmat (D,    1, 2) ./ 2);
            if isfield (tree,   'frustum') && (tree.frustum == 1)
                V3   = (dP * [0 -1;  1 0]) .* (repmat (parD, 1, 2) ./ 2);
                V4   = (dP * [0  1; -1 0]) .* (repmat (parD, 1, 2) ./ 2);
                MX   = [X1 X1 X2 X2]';
                MY   = [ ...
                    (Y1 + V4 (:, 1)) ...
                    (Y1 + V3 (:, 1)) ...
                    (Y2 + V1 (:, 1)) ...
                    (Y2 + V2 (:, 1))]';
                MZ   = [ ...
                    (Z1 + V4 (:, 2)) ...
                    (Z1 + V3 (:, 2)) ...
                    (Z2 + V1 (:, 2)) ...
                    (Z2 + V2 (:, 2))]';
            else
                MX   = [X1 X1 X2 X2]';
                MY   = [ ...
                    (Y1 + V2 (:, 1)) ...
                    (Y1 + V1 (:, 1)) ...
                    (Y2 + V1 (:, 1)) ...
                    (Y2 + V2 (:, 1))]';
                MZ   = [ ...
                    (Z1 + V2 (:, 2)) ...
                    (Z1 + V1 (:, 2)) ...
                    (Z2 + V1 (:, 2)) ...
                    (Z2 + V2 (:, 2))]';
            end
        otherwise
            dP       = dP (:, [1 2]);
            % use rotation matrix to rotate the data
            V1       = (dP * [0 -1;  1 0]) .* (repmat (D,    1, 2) ./ 2);
            V2       = (dP * [0  1; -1 0]) .* (repmat (D,    1, 2) ./ 2);
            if isfield (tree,   'frustum') && (tree.frustum == 1)
                V3   = (dP * [0 -1;  1 0]) .* (repmat (parD, 1, 2) ./ 2);
                V4   = (dP * [0  1; -1 0]) .* (repmat (parD, 1, 2) ./ 2);
                MX   = [ ...
                    (X1 + V4 (:, 1)) ...
                    (X1 + V3 (:, 1)) ...
                    (X2 + V1 (:, 1)) ...
                    (X2 + V2 (:, 1))]';
                MY   = [ ...
                    (Y1 + V4 (:, 2)) ...
                    (Y1 + V3 (:, 2)) ...
                    (Y2 + V1 (:, 2)) ...
                    (Y2 + V2 (:, 2))]';
                MZ   = [Z1 Z1 Z2 Z2]';
            else
                MX   = [ ...
                    (X1 + V2 (:, 1)) ...
                    (X1 + V1 (:, 1)) ...
                    (X2 + V1 (:, 1)) ...
                    (X2 + V2 (:, 1))]';
                MY   = [...
                    (Y1 + V2 (:, 2)) ...
                    (Y1 + V1 (:, 2)) ...
                    (Y2 + V1 (:, 2)) ...
                    (Y2 + V2 (:, 2))]';
                MZ   = [Z1 Z1 Z2 Z2]';
            end
    end
    if (size (color, 1) > 1) && (size (color, 2) == 1)
        HP       = patch (MX, MY, MZ, color');
    else
        HP       = patch (MX, MY, MZ, 0);
        if (size (color, 2) == 3) && (size (color, 1) == 1)
            set  (HP, ...
                'facecolor',   color); % map color
        elseif (size (color, 2) == 3) && (size (color, 1) == numel(tree.X))
            C = repmat (color, 1, 4); C = reshape (C', numel (C), 1);
            C = reshape (C, 3,numel (C)/3)';
            set (HP, 'facecolor','flat','edgecolor','flat','FaceVertexCData',C);
        end
    end
end

if ~isempty      ([ ...
        (strfind (options, '-2')) ...
        (strfind (options, '-3'))])
    % if color values are mapped:
    if size (color, 1) > 1
        if size (color, 2) ~= 3
            if islogical (color)
                color  = double (color);
            end
            crange     = [(min (color)) (max (color))];
            % scaling of the vector
            if diff (crange) == 0
                color  = ones (size (color, 1), 1);
            else
                color  = floor ( ...
                    (color - crange (1)) ./ ...
                    ((crange (2) - crange (1)) ./ 64));
                color (color <  1) =  1;
                color (color > 64) = 64;
            end
            map        = colormap;
            colors     = map (color, :);
        end
    end
    if ~isempty  ([ ...
            (strfind (options, '-2l')) ...
            (strfind (options, '-3l'))])
        if   strfind (options, '-2l')
            [X1, X2, Y1, Y2] = cyl_tree (intree, '-2d');
            HP         = line ( ...
                [(X1 (ipart)) (X2 (ipart))]' + DD (1), ...
                [(Y1 (ipart)) (Y2 (ipart))]' + DD (2));
        end
        if   strfind (options, '-3l')
            [X1, X2, Y1, Y2, Z1, Z2] = cyl_tree (intree);
            HP         = line ( ...
                [(X1 (ipart)) (X2 (ipart))]' + DD (1), ...
                [(Y1 (ipart)) (Y2 (ipart))]' + DD (2),...
                [(Z1 (ipart)) (Z2 (ipart))]' + DD (3));
        end
        if size (color, 1) > 1
            for counter   = 1 : length (ipart)
                set    (HP (counter), ...
                    'color',   colors (counter, :));
            end
        else
            set        (HP, ...
                'color',       color);
        end
    end
    if strfind (options, '-2q')
        [X1, X2, Y1, Y2] = cyl_tree (intree, '-2d');
        HP             = quiver ( ...
            X1 (ipart) + DD (1), ...
            Y1 (ipart) + DD (2), ...
            X2 (ipart) - X1 (ipart), ...
            Y2 (ipart) - Y1 (ipart), 0);
        if size (color, 1) > 1
            color      = [0 0 0];
        end
        set            (HP, ...
            'color',           color);
    end
    if strfind (options, '-3q')
        [X1, X2, Y1, Y2, Z1, Z2] = ...
            cyl_tree (intree);
        HP             = quiver3 ( ...
            X1 (ipart) + DD (1), ...
            Y1 (ipart) + DD (2), ...
            Z1 (ipart) + DD (3), ...
            X2 (ipart) - X1 (ipart), ...
            Y2 (ipart) - Y1 (ipart), ...
            Z2 (ipart) - Z1 (ipart), 0);
        if size (color, 1) > 1
            color      = [0 0 0];
        end
        set            (HP, ...
            'color', color);
    end
    if strfind (options, '-thin')
        set            (HP, ...
            'linewidth', 0.25);
    end
    if strfind (options, '-thick')
        set            (HP, ...
            'linewidth', 3);
    end
end

if strfind       (options, '-p')
    [X1, X2, Y1, Y2, Z1, Z2] = cyl_tree (intree);
    X1           = X1 (ipart) + DD (1);
    X2           = X2 (ipart) + DD (1);
    Y1           = Y1 (ipart) + DD (2);
    Y2           = Y2 (ipart) + DD (2);
    Z1           = Z1 (ipart) + DD (3);
    Z2           = Z2 (ipart) + DD (3);
    P            = [X1 Y1 Z1]; % location of starting nodes
    dP           = [ ...
        (X2 - X1) ...
        (Y2 - Y1) ...
        (Z2 - Z1)]; % direction vector
    N            = size     (X1, 1); % number of nodes in tree
    % initialize sampling angles, remove duplicate angles (0 and 2*pi)
    theta        = linspace (0, 2 * pi, res + 1);
    theta        = theta    (1 : end - 1);
    % initialize storage arrays
    b1           = zeros    (N, 3);
    b2           = zeros    (N, 3);
    % calculate orthonormal vectors to the direction vector of each
    % compartment
    for counter  = 1 : N
        % singular value decomposition
        v        = null     (dP (counter, :)); %%% BOTTLENECK
        % orthogonal bases setup
        b1 (counter, :) = v (:, 2);
        b2 (counter, :) = v (:, 1);
    end
    % replicate vectors and reshape
    b1           = repmat  (b1,  1, 2 * res);
    b1           = reshape (b1', 3, 2 * res * size (b1, 1))';
    b2           = repmat  (b2,  1, 2 * res);
    b2           = reshape (b2', 3, 2 * res * size (b2, 1))';
    
    % this is the first translation vector list to move the cylinder
    % terminals away from null
    dP           = cat     (2, ...
        zeros  (N, 3 * res), ...
        repmat (dP (1 : end, :), 1, res));
    dP           = reshape (dP', 3, N * 2 * res)';
    % second translation list to move each cylinder to it's final
    % destination
    P            = repmat  (P (1 : end, :), 1, 2 * res);
    P            = reshape (P',             3, 2 * res * N)';
    
    % setup diameters:
    % use frustums for ratio (radius/parent) >$threshold and < 1/treshhold
    % to avoid strange visualization results of thin branches leaving
    % from bigger ones, else: use cylinders
    if isfield   (tree, 'D')
        D        = tree.D;
    else
        D        = ones (length (X1),    1);
    end
    if strfind   (options, '-thin')
        D        = ones (length (ipart), 1);
    end
    if strfind   (options, '-thick')
        D        = D + 3;
    end
    
    % if tree consists of only one point, plot a sphere instead of cylinder
    if N == 1
        [XS, YS, ZS] = sphere (16);
        HP = surface (X1 + D * XS + DD (1),...
            Y1 + D * YS + DD (2),...
            Z1 + D * ZS + DD (3));
        set (HP, 'edgecolor', 'none', 'facecolor', color);
        return
    elseif isfield (tree, 'frustum') && (tree.frustum == 1)
        threshold  = 0.15;
        % vector containing index to direct parent:
        idpar    = idpar_tree (intree);
        parD     = D (idpar (1 : end));
        D        = D (ipart);
        parD     = parD (ipart);
        use_parD = double ( ...
            (D (1 : end) ./ parD) > threshold & ...
            (D (1 : end) ./ parD) < (1 / threshold));
        diff_rad = parD - D (1 : end);
        D        = cat   (2, ...
            repmat (D (1 : end) + (use_parD .* diff_rad), 1, res), ...
            repmat (D (1 : end), 1, res));
        D        = reshape (D',  1, res * 2 * N)';
    else
        D        = D (ipart);
        D        = repmat  (D,   1, res * 2);
        D        = reshape (D',  numel (D), 1);
    end
    % replicate angular sampling
    theta_sin    = repmat (sin (theta)', N * 2, 3);
    theta_cos    = repmat (cos (theta)', N * 2, 3);
    % create final vertex list
    vertex_array = dP + P + ...
        (theta_cos .* b1 + theta_sin .* b2) .* ...
        repmat (D / 2, 1, 3);
    % face index creation, start with the two points on the base level and
    % then connect them to the two others on the terminal level
    % start with a standard poly list for a cylinder then replicate and
    % shift
    first_col    = (1       : 1 : res - 1)';
    second_col   = (2       : 1 : res)';
    third_col    = (res + 2 : 1 : 2 * res)';
    fourth_col   = (res + 1 : 1 : 2 * res - 1)';
    poly_array   = [ ...
        first_col, ...
        second_col, ...
        third_col, ...
        fourth_col];
    poly_array   = [poly_array; [res, 1, (res + 1), (2 * res)]];
    poly_array   = repmat  (poly_array, N, 1);
    shift_vec    = repmat  ( ...
        (0 : 2 * res : (2 * res * N) - 1)', ...
        1, res * 4);
    shift_vec    = reshape (shift_vec', 4, res * N)';
    poly_array   = poly_array + shift_vec;
    if  (...
            (size (color, 1) == numel(tree.X)) && (size (color, 2) == 1)) ||  ...
            (size (color, 2) == numel(tree.X)) && (size (color, 1) == 1)
        if (size (color, 2) > 1) && (size (color, 1) == 1)
           color = color'; 
        end        
        C        = repmat  (color, 1, res * 2);
        C        = reshape (C', numel (C), 1);
        HP       = patch   ( ...
            'Faces',           poly_array, ...
            'Vertices',        vertex_array, ...
            'cdata',           C', ...
            'facecolor',       'interp', ...
            'linestyle',       'none');
    else
        if (size (color, 1) > 1)
            C    = repmat  (color, 1, res * 2);
            C    = reshape (C',   numel (C), 1);
            C    = reshape (C, 3, numel (C) / 3)';
        else
            C    = repmat  (color, size (vertex_array, 1), 1);
        end
        HP       = patch (...
            'Faces',           poly_array, ...
            'Vertices',        vertex_array, ...
            'faceVertexCData', C, ...
            'faceColor',       'interp', ...
            'linestyle',       'none');
    end
end

if ~(sum (get (gca, 'DataAspectRatio') == [1 1 1]) == 3)
    axis         equal
end



