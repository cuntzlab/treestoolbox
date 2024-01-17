% HULL_TREE   Isosurface/line at given distance from tree.
% (trees package)
%
% [c, M, HP] = hull_tree (intree, thr, bx, by, bz, options)
% ---------------------------------------------------------
%
% Calculates a space-filling 3D isosurface around the tree with a threshold
% distance of thr [in um]. In order to do this it creates a grid defined by
% the vectors bx, by and bz and calculates the closest node on the tree to
% any of the points on the grid. Higher resolution requires more computer
% power but results in higher accuracy of contour. Don't forget that the
% smaller the threshold distance thr the better spatial resolution you
% need. Reduce the resulting patch resolution with: reducepatch (HP, ratio)
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - thr      ::value:        threshold value for the isoline contour
%     {DEFAULT: 25 um}
% - bx       ::vector:       x values defining underlying grid or
%      single value, then interpreted as spatial resolution
%      {DEFAULT: 50}
% - by       ::vector:       y values defining underlying grid or
%      single value, then interpreted as spatial resolution
%      {DEFAULT: 50}
% - bz       ::vector:       z values defining underlying grid or
%      single value, then interpreted as spatial resolution
%      {DEFAULT: 50}
% - options  ::string:
%     '-s'   : show isosurface/line
%     '-w'   : waitbar, good for large bx and by and bz
%     '-F'   : output M is full distances matrix instead of binary
%     '-2d'  : 2D isoline instead of 3D isosurface
%     {DEFAULT: '-w -s -F'}
%
% Outputs
% -------
% - c        ::polygon:      representation depends on 2D / 3D
% - M        ::binary matrix: 1 means in, 0 means out
% - HP       ::handle:       handle to patches
%
% Example
% -------
% hull_tree    (sample_tree)
% hull_tree    (sample_tree, [], [], [], [], '-2d -s')
%
% See also   chull_tree vhull_tree
% Uses       cyl_tree ver_tree X Y (Z)
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [c, M, HP] = hull_tree (intree, thr, bx, by, bz, options)

if (nargin < 6) || isempty (options)
    % {DEFAULT: waitbar, show result and output full distance matrix}
    options  = '-w -s -F';
end

% use node position for this function
if isnumeric (intree) && numel (intree) > 1
    X        = intree (:, 1);
    Y        = intree (:, 2);
    Z        = intree (:, 3);
else
    ver_tree (intree);                   % verify that input is a tree
    X        = intree.X;
    Y        = intree.Y;
    if ~contains (options, '-2d')
        Z    = intree.Z;
    end
end

if (nargin < 2) || isempty (thr)
    % {DEFAULT: 25 um distance threshold}
    thr      = 25;
end

if (nargin < 3) || isempty (bx)
    % {DEFAULT: divide x axis in 50 pieces}
    bx       = 50;
end

if (nargin < 4) || isempty (by)
    % {DEFAULT: divide y axis in 50 pieces}
    by       = 50;
end

if (nargin < 5) || isempty (bz)
    % {DEFAULT: divide z axis in 50 pieces}
    bz       = 50;
end

% calculate bx / by / bz values for the grid:
if numel (bx)    == 1
    bx           = ...
        min (X) - 2 * thr : ...
        (4 * thr + max (X) - min (X)) / bx : ...
        max (X) + 2 * thr;
end
if numel (by)    == 1
    by           = ...
        min (Y) - 2 * thr : ...
        (4 * thr + max (Y) - min (Y)) / by : ...
        max (Y) + 2 * thr;
end

if ~contains (options, '-2d')  % 3D option
    if numel     (bz) == 1                   % only here do you need bz
        bz       = ...
            min (Z) - 2 * thr : ...
            (4 * thr + max (Z) - min (Z)) / bz : ...
            max (Z) + 2 * thr;
    end
    len          = length (by);              % line by line on y-axis
    M            = zeros  (len, length (bx), length (bz));
    [X1, X2, Y1, Y2, Z1, Z2] = ...
        cyl_tree (intree);               % start and end coord.
    % create N x len comparison matrices:
    X1           = repmat (X1, 1, len);
    X2           = repmat (X2, 1, len);
    Y1           = repmat (Y1, 1, len);
    Y2           = repmat (Y2, 1, len);
    Z1           = repmat (Z1, 1, len);
    Z2           = repmat (Z2, 1, len);
    if contains (options, '-w')           % waitbar option: initialization
        if length  (bz) > 9
            HW   = waitbar (0, 'building up distance matrix ...');
            set  (HW, 'Name', '..PLEASE..WAIT..YEAH..');
        end
    end
    for counterz = 1 : length (bz)
        if contains (options, '-w')     % waitbar option: update
            if mod   (counterz, 10) == 0
                waitbar  (counterz ./ length (bz), HW);
            end
        end
        for counterx = 1 : length (bx)
            XP   = ones (size (X1, 1), len) .* bx (counterx);
            YP   = repmat (by, size (X1, 1), 1);
            ZP   = ones (size (X1, 1), len) .* bz (counterz);
            % oh yeah it's the full palette, calculate distance from each
            % point to the line between two nodes of the tree:
            u    = ( ...
                (XP - X1) .* (X2 - X1) + ...
                (YP - Y1) .* (Y2 - Y1) + ...
                (ZP - Z1) .* (Z2 - Z1)) ./ ( ...
                (X2 - X1).^2 + ...
                (Y2 - Y1).^2 + ...
                (Z2 - Z1).^2);
            u (isnan (u)) = 0;
            ru   = (u > 1); %   u (u < 0) = 0; u (u > 1) = 1;
            u    = ((u .* (u > 0)) .* ~ru) + ru;
            Xu   = X1 + u .* (X2 - X1);
            Yu   = Y1 + u .* (Y2 - Y1);
            Zu   = Z1 + u .* (Z2 - Z1);
            dist = sqrt ( ...
                (XP - Xu).^2 + ...
                (YP - Yu).^2 + ...
                (ZP - Zu).^2);
            i1   = min (dist);
            % build up distance matrix:
            M (:, counterx, counterz)  = reshape (i1, len, 1, 1);
        end
    end
    if contains (options, '-w') % waitbar option: close
        if length    (bz) > 9
            close    (HW);
        end
    end
    c            = isosurface (bx, by, bz, M, thr);
    if contains (options, '-s') % show option
        HP       = patch (c);
        set      (HP, ...
            'FaceColor',       'red', ...
            'EdgeColor',       'none', ...
            'facealpha',       0.3);
        if sum   (get (gca, 'Dataaspectratio') == [1 1 1]) ~= 3
            axis     equal
        end
    end
else                                     % 2D option:
    [X1, X2, Y1, Y2] = ...
        cyl_tree (intree, '-2d');        % start and end coord.
    lenx         = length (bx);
    leny         = length (by);
    len2         = lenx * leny;          % estimate expense of calculation
    if len2      > 256                   % if that is large then split up:
        BX       = bx;
        M        = zeros (leny, lenx);
        lenx     = 1;
        len2     = leny;
        % create N x 1 x leny comparison matrices:
        X1       = repmat (X1, 1, len2);
        Y1       = repmat (Y1, 1, len2);
        X2       = repmat (X2, 1, len2);
        Y2       = repmat (Y2, 1, len2);
        if contains (options, '-w')
            if length (BX) > 9
                HW   = waitbar (0, 'building up distance matrix ...');
                set  (HW, 'Name', 'please wait...');
            end
        end
        for counterx = 1 : length (BX)
            if contains (options, '-w')
                if mod   (counterx, 10) == 0
                    waitbar (counterx ./ length (BX), HW);
                end
            end
            bx   = BX (counterx);
            XP   = repmat (reshape (repmat (bx,  leny, 1),    1, len2), ...
                size (X1, 1), 1);
            YP   = repmat (reshape (repmat (by', 1,    lenx), 1, len2), ...
                size (X1, 1), 1);
            % oh yeah it's the full palette, calculate distance from each
            % point to the line between two nodes of the tree:
            u    = ( ...
                (XP - X1) .* (X2 - X1) + ...
                (YP - Y1) .* (Y2 - Y1)) ./ ( ...
                (X2 - X1).^2 + ...
                (Y2 - Y1).^2);
            u (isnan (u)) = 0;
            ru   = (u > 1); %   u (u < 0) = 0; u (u > 1) = 1;
            u    = ((u .* (u > 0)) .* ~ru) + ru;
            Xu   = X1 + u .* (X2 - X1);
            Yu   = Y1 + u .* (Y2 - Y1);
            dist = sqrt ( ...
                (XP - Xu).^2 + ...
                (YP - Yu).^2);
            i1   = min (dist);
            % build up distance matrix:
            M (:, counterx)  = reshape (i1, leny, lenx);
        end
        bx       = BX;
        if contains (options, '-w')
            if length    (BX) > 9
                close    (HW);
            end
        end
    else
        % create full N x 1 x len2 comparison matrices:
        X1       = repmat (X1, 1, len2);
        Y1       = repmat (Y1, 1, len2);
        X2       = repmat (X2, 1, len2);
        Y2       = repmat (Y2, 1, len2);
        XP       = repmat (reshape (repmat (bx,  leny, 1),    1, len2), ...
            size (X1, 1), 1);
        YP       = repmat (reshape (repmat (by', 1,    lenx), 1, len2), ...
            size (X1, 1), 1);
        % oh yeah it's the full palette, calculate distance from each
        % point to the line between two nodes of the tree:
        u        = ( ...
            (XP - X1) .* (X2 - X1) + ...
            (YP - Y1) .* (Y2 - Y1)) ./ ( ...
            (X2 - X1).^2 + ...
            (Y2 - Y1).^2);
        u (isnan (u)) = 0;
        ru       = (u > 1); %   u (u < 0) = 0; u (u > 1) = 1;
        u        = ((u .* (u > 0)) .* ~ru) + ru;
        Xu       = X1 + u.*(X2 - X1);
        Yu       = Y1 + u.*(Y2 - Y1);
        dist     = sqrt ( ...
            (XP - Xu).^2 + ...
            (YP - Yu).^2);
        i1       = min (dist);
        M        = reshape (i1, leny, lenx); % build up distance matrix
    end
    % use contour to find isoline:
    c            = contourc (bx, by, M, [thr thr]);
    % checkout "cpoints" and "cplotter" to find out more about contour
    % convention:
    c            = c';
    if contains (options, '-s')
        HP       = cplotter (c);
        if sum   (get (gca, 'Dataaspectratio') == [1 1 1]) ~= 3
            axis equal;
        end
    end
end

if ~contains (options, '-F') % threshold distance matrix
    M            = M < thr;
end

