% FLATTEN_TREE   Flattens tree onto XY plane.
% (trees package)
%
% tree = flatten_tree (intree, options)
% -------------------------------------
%
% Flattens tree into the XY plane by conserving the lengths of the
% individual compartments. (quite similar to morph_tree but not similar
% enough to make one function)
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     '-m'   : demo movie
%     {DEFAULT: ''}
%
% Output
% -------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% flatten_tree (sample_tree, '-s -m')
%
% See also morph_tree zcorr_tree
% Uses ipar_tree tran_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function tree = flatten_tree (intree, options)

ver_tree     (intree); % verify that input is a tree structure
tree         = intree;

if (nargin < 2) || isempty (options)
    % {DEFAULT: waitbar}
    options  = ''; 
end

% parent index structure (see "ipar_tree"):
ipar             = ipar_tree (tree); 
% set root Z to 0:
tree             = tran_tree (tree, [0 0 (-tree.Z (1))]);

eps              = 1e-3;
if all (tree.Z < eps)
    tree.Z (:)   = 0;
    warning      ('tree already flat, nothing to do'); % TODO return the tree
    return;
end

if contains      (options, '-m') % show movie option
    clf;
    HP           = plot_tree (tree);
    title        ('flatten a tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (3);
    grid         on;
    axis         image;
end

if contains      (options, '-w') % waitbar option: initialization
    if length    (tree.X) > 998
        HW       = waitbar (0, 'flattening ...');
        set      (HW, 'Name', '..PLEASE..WAIT..YEAH..');
    end
end

domovie          = contains   (options, '-m');
dowaitbar        = contains   (options, '-w');

for counter      = 2 : length (tree.X) % walk through tree
    if dowaitbar % waitbar option: update
        if  (mod (counter, 1000) == 999)
            waitbar  (counter ./ length (tree.X), HW);
        end
    end
    % node to parent node differences:
    dX           = tree.X (counter) - tree.X (ipar (counter, 2));
    dY           = tree.Y (counter) - tree.Y (ipar (counter, 2));
    dZ           = tree.Z (counter) - tree.Z (ipar (counter, 2));
    XY           = sqrt ((dX.^2) + (dY.^2));           % 2D segment length
    XYZ          = sqrt ((dX.^2) + (dY.^2) + (dZ.^2)); % 3D segment length
    if XY        ~= 0
        % correct for 3D to 2D loss of length, move sub-tree:
        u        = XYZ ./ XY;
        [sub, ~] = ind2sub (size (ipar), find (ipar == counter));
        tree.X (sub) = tree.X (sub) + (u - 1) .* dX;
        tree.Y (sub) = tree.Y (sub) + (u - 1) .* dY;
        tree.Z (sub) = tree.Z (sub) - dZ;
        tree.Z (counter) = 0;
    else
        warning  ( ...
            'TREES:metricconsistency', ...
            'zero length XY element, going horizontal only');
        % horizontal move when zero length XY:
        [sub, ~] = ind2sub (size (ipar), find (ipar == counter));
        tree.X (sub) = tree.X (sub) + XYZ;
        tree.Y (sub) = tree.Y (sub);
        tree.Z (sub) = tree.Z (sub) - dZ;
        tree.Z (counter) = 0;
    end
    if domovie % show movie option: update
        set      (HP, ...
            'visible',         'off');
        HP       = plot_tree (tree);
        drawnow;
    end
end
if contains (options, '-w') % waitbar option: close
    if length    (tree.X) > 998
        close    (HW);
    end
end

if contains (options, '-s') % show option
    clf;
    hold         on;
    HP           = plot_tree (intree);
    set          (HP, ...
        'facealpha',           0.5);
    HP           = plot_tree (tree, [1 0 0]);
    set          (HP, ...
        'facealpha',           0.5);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, ...
        {'before',             'after'});
    set          (HP, ...
        'visible',             'off');
    title        ('flatten a tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]'); 
    zlabel       ('z [\mum]');
    view         (3);
    grid         on;
    axis         image;
end

