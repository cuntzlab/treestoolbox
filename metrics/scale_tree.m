% SCALE_TREE   Scales a tree.
% (trees package)
%
% tree = scale_tree (intree, fac, options)
% ----------------------------------------
%
% scales the entire tree by factor fac. If fac 3-tupel scaling factor can
% be different for X, Y and Z.
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - fac::scalar or 3-tupel: multiplication factor {DEFAULT: 2x}
%     if scalar, diameter is also scaled
% - options::string: {DEFAULT: ''}
%     '-s' : show before and after
%     '-d' : do not scale diameter
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree:: structured output tree
%
% Example
% -------
% scale_tree (sample_tree, 1.2, '-s')
%
% See also tran_tree rot_tree flip_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function varargout = scale_tree (intree, fac, options)

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

if (nargin < 2)||isempty(fac),
    fac = 2; % {DEFAULT: no option}
end

if (nargin < 3)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

% ORI = [tree.X(1) tree.Y(1) tree.Z(1)];
% tree.X = tree.X - ORI (1);
% tree.Y = tree.Y - ORI (2);
% tree.Z = tree.Z - ORI (3);

% scaling:
if numel(fac)>1,
    tree.X = tree.X * fac (1);
    tree.Y = tree.Y * fac (2);
    tree.Z = tree.Z * fac (3);
else
    tree.X = tree.X * fac;
    tree.Y = tree.Y * fac;
    tree.Z = tree.Z * fac;
    if isempty (strfind (options, '-d')),
        tree.D = tree.D * fac;
    end
end

% tree.X = tree.X + ORI (1);
% tree.Y = tree.Y + ORI (2);
% tree.Z = tree.Z + ORI (3);


if strfind (options, '-s') % show option
    clf; shine; hold on; HP = plot_tree (intree); set (HP,'facealpha', .5);
    HP = plot_tree (tree, [1 0 0]); set (HP, 'facealpha', .5);
    HP (1) = plot (1, 1, 'k-'); HP (2) = plot (1, 1, 'r-');
    legend (HP, {'before', 'after'}); set (HP, 'visible', 'off');
    title  ('scale a tree');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view (2); grid on; axis image;
end

if (nargout == 1)||(isstruct(intree)),
    varargout {1}  = tree; % if output is defined then it becomes the tree
else
    trees {intree} = tree; % otherwise add to end of trees cell array
end
