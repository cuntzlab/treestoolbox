% FLATTEN_TREE   flattens tree onto XY plane.
% (trees package)
%
% tree = flatten_tree (intree, options)
% -------------------------------------
%
% flattens tree into the XY plane by conserving the lengths of the
% individual compartments. (quite similar to morph_tree but not similar
% enough to make one function)
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - options::string: {DEFAULT: '-w'}
%     '-s' : show
%     '-w' : waitbar
%     '-m' : demo movie
%
% Output
% -------
% if no output is declared the tree is changed in trees
% - tree:: structured output tree
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
global trees

if (nargin < 1)||isempty(intree),
    intree = length(trees); % {DEFAULT tree: last tree in trees cell array}
end;

ver_tree (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree),
    tree = trees {intree};
else
    tree = intree;
end

if (nargin < 2)||isempty(options),
    options = '-w'; % {DEFAULT: waitbar}
end;

ipar = ipar_tree (tree); % parent index structure (see "ipar_tree")
tree = tran_tree (tree, [0 0 -tree.Z(1)]); % set root Z to 0

if strfind (options, '-m'), % show movie option
    clf; shine; HP = plot_tree (tree); title ('flatten a tree');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view (3); grid on; axis image;
end

if findstr (options, '-w'), % waitbar option: initialization
    HW = waitbar (0, 'flattening ...');
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end

for ward = 2 : length (tree.X), % walk through tree
    if findstr (options, '-w'), % waitbar option: update
        waitbar (ward ./ length (tree.X), HW);
    end
    dX = tree.X (ward) - tree.X (ipar (ward, 2)); % node to parent node differences
    dY = tree.Y (ward) - tree.Y (ipar (ward, 2));
    dZ = tree.Z (ward) - tree.Z (ipar (ward, 2));
    XY  = sqrt ((dX.^2) + (dY.^2)); % 2D segment length
    XYZ = sqrt ((dX.^2) + (dY.^2) + (dZ.^2)); % 3D segment length
    if XY ~= 0,
        u = XYZ ./ XY; % correct for 3D to 2D loss of length, move sub-tree
        [sub i2] = ind2sub (size (ipar), find (ipar == ward));
        tree.X (sub)  = tree.X (sub) + (u - 1).*dX;
        tree.Y (sub)  = tree.Y (sub) + (u - 1).*dY;
        tree.Z (sub)  = tree.Z (sub) - dZ;
        tree.Z (ward) = 0;
    else
        warning('TREES:metricconsistency','zero length XY element, going horizontal only');
        % horizontal move when zero length XY:
        [sub i2] = ind2sub(size(ipar),find(ipar==ward));
        tree.X (sub)  = tree.X (sub) + XYZ;
        tree.Y (sub)  = tree.Y (sub);
        tree.Z (sub)  = tree.Z (sub) - dZ;
        tree.Z (ward) = 0;
    end
    if strfind (options, '-m'), % show movie option: update
        set (HP, 'visible', 'off'); HP = plot_tree (tree); drawnow;
    end
end
if findstr (options, '-w'), % waitbar option: close
    close (HW);
end

if strfind (options, '-s'), % show option
    clf; shine; hold on; plot_tree (intree); plot_tree (tree, [1 0 0]);
    HP(1) = plot (1, 1, 'k-'); HP(2) = plot (1, 1, 'r-');
    legend (HP, {'before', 'after'}); set (HP, 'visible', 'off');
    title  ('flatten a tree');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view(3); grid on; axis image;
end

if (nargout >0)||(isstruct(intree)),
    varargout {1}  = tree; % if output is defined then it becomes the tree
else
    trees {intree} = tree; % otherwise add to end of trees cell array
end
