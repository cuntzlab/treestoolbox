% MORPH_TREE   morph a tree's metrics without changing angles or topology
% (trees package)
%
% tree = morph_tree (intree, v, options)
% --------------------------------------
%
% morphs a tree's metrics without changing angles or topology. Attributes
% length values from v to the individual segments but keeps the branching
% structure otherwise intact. This can result in a huge mess (overlap
% between previously non-overlapping segments) or extreme sparseness
% depending on the tree. This is a META-FUNCTION and can lead to various
% applications. This funciton provides universal application to all
% possible morpho-electrotonic transforms and much much more. If the
% original lengths of segments are backed up in a vector len, the original
% tree can simply be regrown by:
% originaltree = morph_tree (morphedtree, len);
% HOWEVER: 0-length elements cannot be regrown.
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - v::vertical vector: values to map on the length of the segments
%     {DEFAULT: 10 um pieces}
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
% morph_tree (sample_tree, [], '-s -m')
%
% See also flatten_tree zcorr_tree
% Uses ipar_tree tran_tree ver_tree
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function varargout = morph_tree (intree, v, options)

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

if (nargin < 2)||isempty(v),
    v = ones (size (tree.dA, 1), 1) .* 10; % {DEFAULT vector: 10 um pieces between all nodes}
end;

if (nargin < 3)||isempty(options),
    options = '-w'; % {DEFAULT: waitbar}
end;

ipar = ipar_tree (tree); % parent index structure (see "ipar_tree")
X0 = tree.X(1); Y0 = tree.Y(1); Z0 = tree.Z(1); % root coordinates
tree = tran_tree (tree); % center on root
len  = len_tree  (tree); % vector containing length values of tree segments [um]

if strfind (options, '-m'), % show movie option
    clf; shine; HP = plot_tree (tree);
    title  ('morph a tree');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view(3); grid on; axis image;
end

if strfind (options, '-w'), % waitbar option: initialization
    HW = waitbar (0, 'morphing ...');
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end
for ward = 2 : length (tree.X),
    if findstr (options, '-w'), % waitbar option: update
        if mod (ward, 500) == 0,
            waitbar (ward ./ length (tree.X), HW);
        end
    end
    if len (ward) ~= v (ward),
        dX = tree.X (ward) - tree.X (ipar (ward, 2)); % node to parent node differences
        dY = tree.Y (ward) - tree.Y (ipar (ward, 2));
        dZ = tree.Z (ward) - tree.Z (ipar (ward, 2));
        XYZ = sqrt((dX.^2) + (dY.^2) + (dZ.^2)); % 3D segment length
        [sub i2] = ind2sub (size (ipar), find (ipar == ward)); % find sub-tree indices
        % correct for change loss of length, move sub-tree
        if XYZ == 0, % if original length is zero no direction is given ->random
            R = rand (1, 3); R = R ./ sqrt (sum (R.^2));
            dX = R (1, 1); dY = R (1, 2); dZ = R (1, 3); XYZ = 1;
        end
        tree.X (sub) = tree.X (sub) - dX + v (ward) .* (dX ./ XYZ);
        tree.Y (sub) = tree.Y (sub) - dY + v (ward) .* (dY ./ XYZ);
        tree.Z (sub) = tree.Z (sub) - dZ + v (ward) .* (dZ ./ XYZ);
        if strfind (options, '-m'), % show movie option: update
            set (HP, 'visible', 'off'); HP = plot_tree (tree); axis tight;
            drawnow;
        end
    end
end
if strfind (options, '-w'), % waitbar option: close
    close (HW);
end

tree = tran_tree (tree, [X0 Y0 Z0]); % move back the tree

if strfind (options,'-s'), % show option
    clf; shine; hold on; plot_tree (intree); plot_tree (tree, [1 0 0]);
    HP (1) = plot (1, 1, 'k-'); HP (2) = plot (1, 1, 'r-');
    legend (HP, {'before', 'after'});
    set (HP, 'visible', 'off');
    title  ('morph a tree');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view (3); grid on; axis image;
end

if (nargout > 0||(isstruct(intree)))
    varargout {1}  = tree; % if output is defined then it becomes the tree
else
    trees {intree} = tree; % otherwise add to end of trees cell array
end