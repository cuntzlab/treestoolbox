% TRAN_TREE   translate the coordinates of a tree.
% (trees package)
%
% tree = tran_tree (intree, DD, options)
% --------------------------------------
%
% translates the coordinates of a tree, per default centers tree around its
% root -> (0,0,0)
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - DD::3-tupel or single value: [dx dy dz] or index of node to center the
%     tree around {DEFAULT: node n.1 = root}
% - options::string: {DEFAULT: ''}
%     '-s'    : show before and after
%
% Output
% -------
% if no output is declared the tree is changed in trees
% - tree:: structured output tree
%
% Example
% -------
% tran_tree (sample_tree, [20 0], '-s')
% tran_tree (sample_tree, 5, '-s')
%
% See also scale_tree rot_tree flip_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function varargout = tran_tree (intree, DD, options)

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

if (nargin < 2)||isempty(DD),
    DD = 1; % {DEFAULT: center to root}
end

if length (DD) == 2,
    DD = [DD 0]; % add z = 0 if not defined
end

if (nargin < 3)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

if numel (DD) > 1,
    tree.X = tree.X + DD (1); % center root to coordinates DD:
    tree.Y = tree.Y + DD (2);
    tree.Z = tree.Z + DD (3);
else
    tree.X = tree.X - tree.X (DD); % center around node DD:
    tree.Y = tree.Y - tree.Y (DD);
    tree.Z = tree.Z - tree.Z (DD);
end

if strfind (options, '-s') % show option
    clf; shine; hold on; HP = plot_tree (intree); set (HP, 'facealpha', .5);
    HP = plot_tree (tree, [1 0 0]); set (HP, 'facealpha', .5);
    HP (1) = plot (1, 1, 'k-'); HP (2) = plot (1, 1, 'r-');
    legend (HP, {'before', 'after'}); set (HP, 'visible', 'off');
    title  ('move a tree');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view (2); grid on; axis image;
end

if (nargout == 1)||(isstruct(intree)),
    varargout {1}  = tree; % if output is defined then it becomes the tree
else
    trees {intree} = tree; % otherwise add to end of trees cell array
end
