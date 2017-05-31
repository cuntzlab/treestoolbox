% VHULL_TREE   Voronoi based subdivision of a tree.
% (trees package)
%
% [HP, VO, KK, vol] = vhull_tree (intree, v, points, ipart, DD, options)
% ----------------------------------------------------------------------
%
% Subdivides a tree in convex polygons using the voronoi-algorithm. Returns
% 1 patch around each point. Patches can be colored with vector v.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
%       alternatively, intree can be a Nx3 matrix XYZ of points
% - v        ::vector:       values to be color-coded
% - points   ::2/3-column vector: X Y (Z) coordinates of boundary points
%     {DEFAULT is hull vertices, see "hull_tree"}
% - ipart    ::vector:       subset index of the points in tree to be used
% - DD       :: XYZ-tupel:   coordinates offset
%     {DEFAULT [0, 0, 0]}
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     '-r'   : lower resolution with reducepatch by 10x (for 3D)
%     '-2d'  : 2D voronoi in 2D boundary
%     {DEFAULT: ''}
%
% Output
% ------
% - HP       ::handle:       patch elements, note that adding transparency
%     is visually appealing
% - VO and KK::cell array of polygons: coordinates and convex hull indices
%     of individual polygons
% - vol      ::vector:       volume/area values for each polygon
%
% Example
% -------
% vhull_tree   (sample_tree)
%
% See also   hull_tree chull_tree
% Uses       ver_tree X Y (Z)
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2017  Hermann Cuntz

function [HP, VO, KK, vol] = vhull_tree (intree, ...
    v, points, ipart, DD, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 6) || isempty (options)
    % {DEFAULT: waitbar and show result}
    options  = '-w -s';
end

if (nargin < 1) || isempty(intree)
    % {DEFAULT: last tree in trees}
    intree   = length (trees);
end

% use only node position for this function
if isnumeric (intree) && numel (intree) > 1
    X            = intree (:, 1);
    Y            = intree (:, 2);
    Z            = intree (:, 3);
else
    ver_tree     (intree);             % verify that input is a tree
    if ~isstruct (intree)
        X        = trees{intree}.X;
        Y        = trees{intree}.Y;
        if isempty (strfind (options, '-2d'))
            Z    = trees{intree}.Z;
        end
    else
        X        = intree.X;
        Y        = intree.Y;
        if isempty (strfind (options, '-2d'))
            Z    = intree.Z;
        end
    end
end
N            = size (X, 1);            % number of nodes in tree

if (nargin < 4) || isempty (ipart)
    % {DEFAULT index: do on all, but only topological points makes sense}
    ipart    = (1 : N)';
end

if (nargin < 2) || isempty (v)
    % {DEFAULT vector: no color mapped on individual polygons}
    v        = [];
end
if (size (v, 1) == N) && (size (ipart, 1) ~= N)
    v        = v (ipart);
end

if (nargin < 3) || isempty (points)
    % avoid showing the distance hull as well but conserve waitbar and 2D
    i1           = strfind   (options, '-s');
    options2     = options;
    options2 (i1 : i1 + 1) = '';
    c            = hull_tree (intree, [], [], [], [], options2);
    if strfind   (options, '-2d')
        [Xt, Yt] = cpoints (c);
        points   = [Xt Yt];
    else
        points   = c.vertices;
    end
end

if (nargin < 5) || isempty (DD)
    % {DEFAULT 3-tupel: no spat. displac.}
    DD       = [0 0 0];
end

X            = [(X (ipart)); (points (:, 1))] + DD (1);
Y            = [(Y (ipart)); (points (:, 2))] + DD (2);
HP           = zeros (length (ipart), 1);

if strfind       (options, '-2d')
    % voronoi doesn't like duplicate points
    warning      ('off', 'MATLAB:voronoin:DuplicateDataPoints');
    [V, C]       = voronoin (double ([X, Y]));
    warning      ('on',  'MATLAB:voronoin:DuplicateDataPoints');
    VI           = V;
    if numel     (points) > 0
        [IN, ON] = inpolygon ( ...
            V (:, 1), ...
            V (:, 2), ...
            points (:, 1) + DD (1), ...
            points (:, 2) + DD (2));
        VI (~IN & ~ON) = NaN;
    end
    parea        = zeros (length (ipart), 1);
    for counter  = 1 : length (ipart)
        parea (counter) = polyarea ( ...
            VI (C {counter}, 1), ...
            VI (C {counter}, 2));
    end
    indy         = find ((~isnan (parea) & (parea ~= 0)));
    if ~isempty (v)
        v        = v (indy);
    end
    vol          = parea (indy);
    KK           = C (indy);
    VO           = VI;
    if strfind       (options, '-s') % show option: update
        for counter  = 1 : length (KK)
            if isempty (v)
                HP (counter) = patch ( ...
                    VI (KK {counter}, 1), ...
                    VI (KK {counter}, 2), [1 1 1]);
            else
                HP (counter) = patch ( ...
                    VI (KK {counter}, 1), ...
                    VI (KK {counter}, 2), v (counter));
            end
        end
    end
    HP (HP == 0) = [];
else
    Z            = [(Z (ipart)); (points (:, 3))] + DD (3);
    % voronoin doesn't like duplicate points
    warning      ('off', 'MATLAB:voronoin:DuplicateDataPoints');
    [V, C]       = voronoin (double ([X, Y, Z]));
    warning      ('on',  'MATLAB:voronoin:DuplicateDataPoints');
    VO           = cell  (length (ipart), 1);
    KK           = cell  (length (ipart), 1);
    vol          = zeros (length (ipart), 1);
    vox          = cell  (length (ipart), 1);
    voy          = cell  (length (ipart), 1);
    voz          = cell  (length (ipart), 1);
    for counter  = 1 : length (ipart)
        vo       = V (C{counter}, :);
        VO{counter} = vo;
        if find  (isnan (vo) | isinf (vo))
            vol  (counter) = NaN;
        else
            [K, vol(counter)] = convhulln (vo, {'Qt', 'Pp', 'QbB'});
        end
        KK{counter}  = K;
        vox{counter} = vo (:, 1);
        voy{counter} = vo (:, 2);
        voz{counter} = vo (:, 3);
    end
    indy         = find ((~isnan (vol) & (vol ~= 0)));
    if ~isempty  (v)
        v        = v (indy);
    end
    vol          = vol (indy);
    KK           = KK  (indy);
    VO           = VO  (indy);
    vox          = vox (indy);
    voy          = voy (indy);
    voz          = voz (indy);
    if strfind   (options, '-s') % show option: update
        for counter = 1 : length (KK)
            if isempty (v)
                p    = patch ( ...
                    vox{counter} (KK{counter})', ...
                    voy{counter} (KK{counter})', ...
                    voz{counter} (KK{counter})', [1 1 1]);
                HP (counter) = p;
            else
                p    = patch ( ...
                    vox{counter} (KK{counter})', ...
                    voy{counter} (KK{counter})', ...
                    voz{counter} (KK{counter})', v (counter));
                HP (counter) = p;
            end
        end
    end
    
end

if strfind       (options, '-r') % reduce the complexity of the output patch
    for counter  = 1 : length (HP)
        reducepatch  (HP (counter), 0.1);
    end
end

if strfind       (options, '-s') % show option
    if ~isempty  (v)
        shading  flat;
    end
    axis         equal
end


