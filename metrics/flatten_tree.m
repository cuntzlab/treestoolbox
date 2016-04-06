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
%     {DEFAULT: '-w'}
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
% Copyright (C) 2009 - 2016  Hermann Cuntz

function varargout = flatten_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees); 
end

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees {intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: waitbar}
    options  = '-w'; 
end

% parent index structure (see "ipar_tree"):
ipar             = ipar_tree (tree); 
% set root Z to 0:
tree             = tran_tree (tree, [0 0 (-tree.Z (1))]);

if strfind       (options, '-m') % show movie option
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

if strfind       (options, '-w') % waitbar option: initialization
    if length    (tree.X) > 998
        HW       = waitbar (0, 'flattening ...');
        set      (HW, 'Name', '..PLEASE..WAIT..YEAH..');
    end
end

for counter      = 2 : length (tree.X) % walk through tree
    if strfind   (options, '-w') % waitbar option: update
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
    if strfind   (options, '-m') % show movie option: update
        set      (HP, ...
            'visible',         'off');
        HP       = plot_tree (tree);
        drawnow;
    end
end
if strfind       (options, '-w') % waitbar option: close
    if length    (tree.X) > 998
        close    (HW);
    end
end

if strfind       (options, '-s') % show option
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

if (nargout > 0) || (isstruct (intree))
    varargout{1}   = tree; % if output is defined then it becomes the tree
else
    trees{intree}  = tree; % otherwise add to end of trees cell array
end
