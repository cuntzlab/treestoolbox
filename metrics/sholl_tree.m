% SHOLL_TREE   Real sholl analysis.
% (trees package)
% 
% [s, dd, sd, XP, YP, ZP, iD] = sholl_tree (intree, dd, options)
% --------------------------------------------------------------
%
% calculates a sholl analysis counting the number of intersections of the
% tree with concentric circles of increasing diameters. Diameter 0 um is
% 1 intersection by definition but typically 4 points are still output into
% XP...
%
% NOTE ! for loop can be translated into matrix operation easily
%
% Input
% -----
% - intree::integer:index of tree in trees structure or structured tree
% - dd::integer: diameter difference of concentric circles {DEFAULT: 50} OR
%     ::vector: diameter values
% - options::string: {DEFAULT: '-e'}
%     '-s' : show intersections
%     '-3s' : show 3D-intersections
%     '-e' : echo how many double intersections are counted
%     '-o' : count only single intersections
%
% Output
% ------
% - s::vector: sholl intersections
% - dd::vector: diameters
% - sd::vector: double intersections
% - XP,YP,ZP::vectors: coordinates of intersection points
% - iD::vector: index of XP YP ZP in dd.
%
% Example
% -------
% sholl_tree (sample_tree, 20, '-s')
%
% See also dist_tree
% Uses ver_tree dA
%
% intersection points between sphere and line segments directly from
% Paul Bourke 1992
% see http://local.wasp.uwa.edu.au/~pbourke/geometry/sphereline/
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function [s, dd, sd, XP, YP, ZP, iD] = sholl_tree (intree, dd, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length (trees); % {DEFAULT tree: last tree in trees cell array} 
end;

ver_tree (intree); % verify that input is a tree structure

if (nargin < 2)||isempty(dd),
    dd = 50; % {DEFAULT diameter difference: every 50 um}
end

if (nargin < 3)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

if numel(dd)==1,
    % if dd is a single value make a vector
    eucl = eucl_tree (intree);
    dd = 0 : dd : (ceil (2 * max(eucl) ./ dd) * dd);
end

[X1 X2 Y1 Y2 Z1 Z2] = cyl_tree (intree); % starting and end points of tree segments
N = length (X1); % number of nodes in tree
% set sphere center to (0, 0, 0)
X3 = X1 (1); Y3 = Y1 (1); Z3 = Z1 (1);
s =  zeros (size (dd));
sd = zeros (size (dd));
XP = []; YP = []; ZP = []; iD = [];
for ward = 1 : length (dd),
    % feed line segments into sphere equation and obtain a quadratic
    % equation of the form au2 + bu + c = 0
    a = (X2 - X1).^2 + (Y2 - Y1).^2 + (Z2 - Z1).^2;
    b = 2 * ((X2 - X1).*(X1 - X3) + (Y2 - Y1).*(Y1 - Y3) + (Z2 - Z1).*(Z1 - Z3));
    c = X3.^2 + Y3.^2 + Z3.^2 + X1.^2 + Y1.^2 + Z1.^2 - ...
        2*(X3 .* X1 + Y3 .* Y1 + Z3 .* Z1) - (dd (ward) / 2)^2;
    squ = b .* b - 4 * a .* c;
    iu = squ >= 0;
    u1 = NaN (N, 1);
    u2 = NaN (N, 1);
    warning ('off','MATLAB:divideByZero');
    u1 (iu) = (-b (iu) + sqrt (squ (iu))) ./ (2 * a (iu));
    u2 (iu) = (-b (iu) - sqrt (squ (iu))) ./ (2 * a (iu));
    warning ('on','MATLAB:divideByZero');
    % when u1 or u2 is in [0, 1] then intersection between segment and
    % sphere exists. When both are in that interval then the segment
    % intersects twice.
    u1 ((u1 < 0) | (u1 > 1)) = NaN;
    u2 ((u2 < 0) | (u2 > 1)) = NaN;
    
    % u1 and u2 are then the solutions on the way from (X1, Y1, Z1) to
    % (X2, Y2, Z2)
    % first add u1 points:
    iu1 = ~isnan (u1);
    Xs1 = X1 (iu1) + u1 (iu1) .* (X2 (iu1) - X1 (iu1));
    Ys1 = Y1 (iu1) + u1 (iu1) .* (Y2 (iu1) - Y1 (iu1));
    Zs1 = Z1 (iu1) + u1 (iu1) .* (Z2 (iu1) - Z1 (iu1));
    XP = [XP; Xs1]; YP = [YP; Ys1]; ZP = [ZP; Zs1];
    iD = [iD; ward*ones(length (find (iu1)), 1)];
    % then u2 points:
    iu2 = ~isnan(u2);
    Xs2 = X1 (iu2) + u2 (iu2) .* (X2 (iu2) - X1 (iu2));
    Ys2 = Y1 (iu2) + u2 (iu2) .* (Y2 (iu2) - Y1 (iu2));
    Zs2 = Z1 (iu2) + u2 (iu2) .* (Z2 (iu2) - Z1 (iu2));
    XP = [XP; Xs2]; YP = [YP; Ys2]; ZP = [ZP; Zs2];
    iD = [iD; ward*ones(length (find (iu2)), 1)];

    s (ward)  = sum (iu1) + sum (iu2);
    sd (ward) = sum (iu1 &~ iu2);
end

s (dd == 0)  = 1;
sd (dd == 0) = 0;

if strfind (options, '-o'),
    s = s - sd;
end

if strfind (options, '-e'),
    if sum (sd) > 0,
        warning ('TREES:wrongcounts',[num2str(sum(sd)) ' segments were counted twice']);
    end
end

if strfind(options,'-s'), % show option
    clf; hold on; shine; HP = plot_tree (intree); set (HP, 'facealpha', 0.5);
    for ward = 1 : length (dd),
        plot (X1 (1) + dd (ward) .* sin (0 : pi / 16 : 2 * pi) / 2,...
            Y1 (1)   + dd (ward) .* cos (0 : pi / 16 : 2 * pi) / 2, 'r-');
    end
    ax = gca; grid on; axis image;
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); 
    ax2 = axes ('Position', get (ax, 'Position'), 'XAxisLocation', 'top', ...
           'YAxisLocation', 'right', 'Color', 'none', 'XColor', 'g', 'YColor', 'g');
    hold on; axis image; xlim (get (ax, 'xlim')); ylim (get (ax, 'ylim'));
    HP = plot (X1 (1) + dd / 2, Y1 (1) + .9 * dd (end) * s ./ (2 * max (s)), 'g-');
    set (HP, 'linewidth', 2);
    clear HP; HP (1) = plot (1, 1, 'r-'); HP (2) = plot (1, 1, 'g-');
    legend (HP, {'sphere diameter', 'intersections count'}, 'location', 'SouthWest');
    set (HP, 'visible', 'off');
    tix = 0 : round (max (s) / 3) : max (s);
    set (ax2, 'ytick', .9 * dd (end) * tix ./ (2 * max (s)), 'yticklabel', num2str (tix'));
    HT = ylabel ('sholl intersections'); set (HT, 'color', [0 1 0]);
end

if strfind (options, '-3s'), % 3D show option
    clf; hold on;
    plot_tree (intree);
    HP = plot3 (XP, YP , ZP, 'r.'); set (HP, 'markersize', 24);
    for ward = 1 : length (dd),
        [XS YS ZS] = sphere (20);
        p = patch (surf2patch ( ...
            X1 (1) + (XS .* dd (ward) / 2), ...
            Y1 (1) + (YS .* dd (ward) / 2), ...
            Z1 (1) + (ZS .* dd (ward) / 2)));
        set (p, 'facecolor', [1 0 0], 'facealpha', 0.01, 'edgecolor', 'none');
        plot (X1 (1) + dd (ward) .* sin (0 : pi / 16 : 2 * pi) / 2, ...
            Y1 (1)   + dd (ward) .* cos (0 : pi / 16 : 2 * pi) / 2, 'r-');
    end
    HP = plot3 (X1 (1) + dd/2, Y1 (1) + zeros (size (dd)), ...
        Z1 (1) + .9 * dd (end) * s ./ (2 * max (s)), 'g.-');
    set (HP, 'linewidth', 4);
    clear HP; HP (1) = plot (1, 1, 'r-'); HP (2) = plot (1, 1, 'r.'); HP (3) = plot (1, 1, 'g.-');
    legend (HP, {'sphere diameter', 'intersections', 'count'});
    set (HP, 'visible', 'off');
    title ('sholl intersections');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view (3); grid on; axis image;
end
