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
%     '-dim2'  : 2D isoline instead of 3D isosurface (Careful, it used to be called '-2d')
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

function [c, M, HP] = hull_tree (intree, varargin)

%=============================== Parsing inputs ==========================%
p            = inputParser;
p.addParameter ('thr',  25)
p.addParameter ('bx',   50)
p.addParameter ('by',   50)
p.addParameter ('bz',   50)
p.addParameter ('s',    true)
p.addParameter ('w',    true)
p.addParameter ('F',    true)
p.addParameter ('dim2', false)
pars         = parseArgs (p, varargin, ...
    {'thr', 'bx', 'by', 'bz'}, ...
    {'s', 'w', 'F', 'dim2'});
%=========================================================================%

% use node position for this function
if isnumeric (intree) && numel (intree) > 1
    X        = intree (:, 1);
    Y        = intree (:, 2);
    Z        = intree (:, 3);
else
    ver_tree (intree);                   % verify that input is a tree
    X        = intree.X;
    Y        = intree.Y;
    if ~pars.dim2
        Z    = intree.Z;
    end
end

% calculate bx / by / bz values for the grid:
if isscalar (pars.bx)
    pars.bx           = ...
        min (X) - 2 * pars.thr : ...
        (4 * pars.thr + max (X) - min (X)) / pars.bx : ...
        max (X) + 2 * pars.thr;
end
if isscalar (pars.by)
    pars.by           = ...
        min (Y) - 2 * pars.thr : ...
        (4 * pars.thr + max (Y) - min (Y)) / pars.by : ...
        max (Y) + 2 * pars.thr;
end

if ~pars.dim2  % 3D option
    if isscalar     (pars.bz)                   % only here do you need bz
        pars.bz       = ...
            min (Z) - 2 * pars.thr : ...
            (4 * pars.thr + max (Z) - min (Z)) / pars.bz : ...
            max (Z) + 2 * pars.thr;
    end
    len          = length (pars.by);              % line by line on y-axis
    M            = zeros  (len, length (pars.bx), length (pars.bz));
    [X1, X2, Y1, Y2, Z1, Z2] = ...
        cyl_tree (intree);               % start and end coord.
    % create N x len comparison matrices:
    X1           = repmat (X1, 1, len);
    X2           = repmat (X2, 1, len);
    Y1           = repmat (Y1, 1, len);
    Y2           = repmat (Y2, 1, len);
    Z1           = repmat (Z1, 1, len);
    Z2           = repmat (Z2, 1, len);
    if pars.w           % waitbar option: initialization
        if length  (pars.bz) > 9
            HW   = waitbar (0, 'building up distance matrix ...');
            set  (HW, 'Name', '..PLEASE..WAIT..YEAH..');
        end
    end
    for counterz = 1 : length (pars.bz)
        if pars.w     % waitbar option: update
            if mod   (counterz, 10) == 0
                waitbar  (counterz ./ length (pars.bz), HW);
            end
        end
        for counterx = 1 : length (pars.bx)
            XP   = ones (size (X1, 1), len) .* pars.bx (counterx);
            YP   = repmat (pars.by, size (X1, 1), 1);
            ZP   = ones (size (X1, 1), len) .* pars.bz (counterz);
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
    if pars.w % waitbar option: close
        if length    (pars.bz) > 9
            close    (HW);
        end
    end
    c            = isosurface (pars.bx, pars.by, pars.bz, M, pars.thr);
    if pars.s % show option
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
        cyl_tree (intree, '-dim2');        % start and end coord.
    lenx         = length (pars.bx);
    leny         = length (pars.by);
    len2         = lenx * leny;          % estimate expense of calculation
    if len2      > 256                   % if that is large then split up:
        BX       = pars.bx;
        M        = zeros (leny, lenx);
        lenx     = 1;
        len2     = leny;
        % create N x 1 x leny comparison matrices:
        X1       = repmat (X1, 1, len2);
        Y1       = repmat (Y1, 1, len2);
        X2       = repmat (X2, 1, len2);
        Y2       = repmat (Y2, 1, len2);
        if pars.w
            if length (BX) > 9
                HW   = waitbar (0, 'building up distance matrix ...');
                set  (HW, 'Name', 'please wait...');
            end
        end
        for counterx = 1 : length (BX)
            if pars.w
                if mod   (counterx, 10) == 0
                    waitbar (counterx ./ length (BX), HW);
                end
            end
            pars.bx   = BX (counterx);
            XP   = repmat (reshape (repmat (pars.bx,  leny, 1),    1, len2), ...
                size (X1, 1), 1);
            YP   = repmat (reshape (repmat (pars.by', 1,    lenx), 1, len2), ...
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
        pars.bx  = BX;
        if pars.w
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
        XP       = repmat (reshape (repmat (pars.bx,  leny, 1),    1, len2), ...
            size (X1, 1), 1);
        YP       = repmat (reshape (repmat (pars.by', 1,    lenx), 1, len2), ...
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
    c            = contourc (pars.bx, pars.by, M, [pars.thr pars.thr]);
    % checkout "cpoints" and "cplotter" to find out more about contour
    % convention:
    c            = c';
    if pars.s
        HP       = cplotter (c);
        if sum   (get (gca, 'Dataaspectratio') == [1 1 1]) ~= 3
            axis equal;
        end
    end
end

if ~pars.F % threshold distance matrix
    M            = M < pars.thr;
end

