% RPOINTS_TREE   Weighted distribution random points within a hull.
% (trees package)
%
% [X, Y, Z, HP] = rpoints_tree (M, N, c, x, y, z, thr, options)
% -------------------------------------------------------------
%
% Distributes N random points in accordance with the density matrix M. Only
% points within the sharp boundaries of a 2d contour are selected. Note
% that the number of resulting points is therefore typically smaller than
% N. The boundary can be further reduced by a distance thr, minimal
% distance that a point needs to be away from any point on the contour.
% This makes particularly sense if the contour was obtained using
% "hull_tree" in 2D. The contour (see "contourc") is defined by:
% c = [contour1         x1 x2 x3 ... contour2         x1 x2 x3 ...;
%      #number_of_pairs y1 y2 y3 ... #number_of_pairs y1 y2 y3 ...]'
%
%
% Inputs
% ------
% - M        ::2D/3D matrix: density matrix containing (horiz. dim. 2: x)
% - N        ::integer    :number of points to be distributed
% - c        ::matrix with two rows: contour as described above
% - x        ::vector:    if M is undefined x is 2-tupel with min max
%      limits
%      {DEFAULT [-500 500]}
%      otherwise x labels bins in M
%      {DEFAULT 1:size(M,2)}
% - y        ::vector:    same as x
% - z        ::vector:    same as x and y. If M is 2D who cares about z...
% - thr      ::value:     distance threshold away from contour
%     {DEFAULT: 0}
% - options  ::string:
%     '-s' : show
%     {DEFAULT: ''}
%
% Output
% ------
% - X, Y, Z  ::vertical vectors: X Y Z coordinates of randomly distributed
%    points
%
% Example
% -------
% % define a 65 point circular polygon with diameter 100 um:
% circlec    = [0 65;[ ...
%   (sin (0 : pi / 32 : 2 * pi)')
%   (cos (0 : pi / 32 : 2 * pi)')] * 100];
% % distribute 1000 points in the boundaries -100 to 100 um
% [X Y Z]    = rpoints_tree ([], 1000, ...
%   circlec, [-100 100], [-100 100], [], 20, '-s');
%
% See also gdens_tree
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [X, Y, Z, HP] = rpoints_tree (M, N, c, x, y, z, thr, options)

if (nargin < 1) || isempty (M)
    M        = [];
    % possibly:
    % sr     = 25; % sets the bin size for sampling the density
    % % calculates the density matrix M at points (dX, dY):
    % [M, dX, dY] = gdens_tree (intree, ...
    %    sr, B_tree (intree) | T_tree (intree));
end

if (nargin < 2) || isempty (N)
    N        = 1000;
end

if (nargin < 3) || isempty (c)
    c        = [];
end

if (nargin < 7) || isempty (thr)
    thr      = [];
end

if (nargin < 8) || isempty (options)
    options  = '-w';
end

if ~isempty      (M)
    if (nargin < 4) || isempty (x)
        % possibly go gdens_tree
        x        = 1 : size (M, 2);
    end
    if (nargin < 5) || isempty (y)
        y        = 1 : size (M, 1);
    end
    if (nargin < 6) || isempty (z)
        z        = 1 : size (M, 3);
    end
    if strfind   (options, '-w')
        HW       = waitbar (0, 'distributing points...');
        set      (HW, ...
            'Name',            '..PLEASE..WAIT..YEAH..');
    end
    if length (size (M)) == 2 % 2D density matrix
        R        = rand (1, N) * sum (sum (M));
        % weighting vector for the bins:
        CS       = cumsum (reshape (M, numel (M), 1));
        % apply CS on the random variable, (r1, r2) then correspond to the
        % bin for each value in R.
        r1       = zeros (length (R), 1);
        r2       = zeros (length (R), 1);
        for counter  = 1 : length (R)
            if strfind   (options, '-w')
                if mod (counter, 5000) == 1
                    waitbar  (counter / length (R), HW);
                end
            end
            [xr1, xr2] = ...
                ind2sub (size (M), sum (~((CS - R (counter)) > 0)));
            r1 (counter) = xr1;
            r2 (counter) = xr2;
        end
        % within that bin the point is randomly chosen (homogeneously):
        X        = x (r2)' + (rand (N, 1) - 0.5) .* (diff (x (1 : 2)));
        Y        = y (r1)' + (rand (N, 1) - 0.5) .* (diff (y (1 : 2)));
        Z        = zeros (N, 1);
    else    % 3D density matrix
        R        = rand (1, N) * sum (sum (sum (M)));
        % weighting vector for the bins:
        CS       = cumsum (reshape (M, numel (M), 1));
        % apply CS on the random variable, (r1, r2) then correspond to the
        % bin for each value in R.
        r1       = zeros (length (R), 1);
        r2       = zeros (length (R), 1);
        r3       = zeros (length (R), 1);
        for counter = 1 : length (R)
            if strfind (options, '-w')
                if mod (counter, 5000) == 1
                    waitbar (counter / length (R), HW);
                end
            end
            [xr1, xr2, xr3] = ...
                ind2sub (size (M), sum (~((CS - R (counter)) > 0)));
            r1 (counter) = xr1;
            r2 (counter) = xr2;
            r3 (counter) = xr3;
        end
        % within that bin the point is randomly chosen (homogeneously):
        X        = x (r2)' + (rand (N, 1) - 0.5) .* (diff (x (1 : 2)));
        Y        = y (r1)' + (rand (N, 1) - 0.5) .* (diff (y (1 : 2)));
        Z        = z (r3)' + (rand (N, 1) - 0.5) .* (diff (z (1 : 2)));
    end
    if strfind   (options, '-w')
        close    (HW);
    end
else % if no density matrix was defined do a fully homogeneous picking
    if (nargin < 4) || isempty (x)
        x        = [-500 500];
    end
    if (nargin < 5) || isempty (y)
        y        = x;
    end
    if diff (x) ~= diff (y)
        warning  ('TREES:construct', ...
            'If x and y are not same size points will be misdistributed');
    end
    R            = rand (N, 2);
    X            = R (:, 1) .* diff (x) + x (1);
    Y            = R (:, 2) .* diff (y) + y (1);
    Z            = zeros (N, 1);
end

if ~isempty      (c)
    IN           = find (in_c (X, Y, c));
    [PX, PY]     = cpoints (c);
    M            = eucdist (X (IN), PX, Y (IN), PY);
    IN2          = min     (M, [], 2) > thr;
    XR           = X;
    YR           = Y;
    X            = XR (IN (IN2));
    Y            = YR (IN (IN2));
    Z            = zeros (length (Y), 1);
end

if strfind       (options, '-s') % show option
    clf; hold on;
    if ~isempty  (c)
        cplotter (c);
    end
    HP           = plot3 (X, Y, Z, 'ko');
    set          (HP, ...
        'markersize',          3, ...
        'markerfacecolor',     [0 0 0]);
    legend       (HP, 'random points');
    title        ('distribute random points');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end



