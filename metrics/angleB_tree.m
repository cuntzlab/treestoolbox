% ANGLEB_TREE   Angle values at branch points in a tree.
% (trees package)
%
% angleB = angleB_tree (intree, options)
% --------------------------------------
%
% Returns for each branching point an angle value corresponding to the
% branching angle within the branching plane. Tree must be BCT (at least
% trifurcations are forbidden of course), use "repair_tree" if necessary.
% NOTE !!this function is not yet opimized for speed and readability!!
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - options  ::string:
%     '-m'   : movie
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% angleB     ::vertical vector: angle value for each branching point
%
% Example
% -------
% angleB_tree  (sample_tree, '-m -s')
%
% See also   asym_tree B_tree
% Uses       ipar_tree B_tree ver_tree dA X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function angleB = angleB_tree (intree, options)

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

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

iB               = find  (B_tree (intree));  % branch point indices
angleB           = zeros (length (iB), 1);   % angle values for each BP
for counter      = 1 : length (iB)      % walk through all branch points:
    % indices of BP daughters:
    BB           = find (tree.dA (:, iB (counter)));
    Pr           = [ ...                     % coordinates of BP
        (tree.X (iB (counter))) ...
        (tree.Y (iB (counter))) ...
        (tree.Z (iB (counter)))];
    P1           = [ ...                     % coordinates of daughter 1
        (tree.X (BB (1))) ...
        (tree.Y (BB (1))) ...
        (tree.Z (BB (1)))];
    P2           = [ ...                     % coordinates of daughter 2
        (tree.X (BB (2))) ...
        (tree.Y (BB (2))) ...
        (tree.Z (BB (2)))];
    V1           = P1 - Pr;                  % daughter branch 1
    V2           = P2 - Pr;                  % daughter branch 2
    % normalized vectors:
    nV1          = V1 / sqrt (sum (V1.^2));
    nV2          = V2 / sqrt (sum (V2.^2));
    % the angle between two vectors in 3D is simply the inverse cosine of
    % their dot-product.
    if all       (nV1 == nV2)
        % otherwise strange imaginary parts might occur
        angleB (counter) = 0;
    else
        angleB (counter) = acos (dot (nV1, nV2));
    end    
    if strfind   (options, '-m') % show movie option
        clf; hold on;
        HP       = plot_tree (intree, [], [], [], [], '-b');
        set      (HP, ...
            'facealpha',     0.2, ...
            'edgecolor',     'none');
        L (1)    = line ( ...
            [(Pr (1)) (Pr (1) + V1 (1))], ...
            [(Pr (2)) (Pr (2) + V1 (2))], ...
            [(Pr (3)) (Pr (3) + V1 (3))]);
        L (2)    = line ( ...
            [(Pr (1)) (Pr (1) + V2 (1))], ...
            [(Pr (2)) (Pr (2) + V2 (2))], ...
            [(Pr (3)) (Pr (3) + V2 (3))]);
        set      (L, ...
            'linewidth',     4, ...
            'color',         [1 0 0]);
        text     ( ...
            tree.X (iB (counter)), ...
            tree.Y (iB (counter)), ...
            tree.Z (iB (counter)), num2str (angleB (counter)));
        title    ('angle at b-points');
        xlabel   ('x [\mum]');
        ylabel   ('y [\mum]');
        zlabel   ('z [\mum]');
        view     (2);
        grid     on;
        axis     image;
        pause    (0.3);
    end
end
% map angle on a Nx1 vector, rest becomes NaN:
tangleB          = angleB;
angleB           = NaN (size (tree.dA, 1), 1);
angleB (iB)      = tangleB;

if strfind       (options, '-s') % show option
    clf;
    hold         on;
    HP           = plot_tree ( ...
        intree, [], [], find (~B_tree (intree)), [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    axis         equal;
    iB           = find (B_tree (intree));
    plot_tree    (intree, angleB (iB), [], iB);
    title        ([ ...
        'angle at BP, mean: ' ...
        (num2str (nanmean (angleB)))]);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         equal;
    colorbar;
end
