% SCALE_TREE   Scales a tree.
% (trees package)
%
% tree = scale_tree (intree, fac, options)
% ----------------------------------------
%
% Scales the entire tree by factor fac at the location where it is (NEW!).
% If fac 3-tupel scaling factor can be different for X, Y and Z. By
% default, diameter is also scaled (as average between X and Y scaling,
% NEW!).
%
% Input
% -----
% - intree   ::integer:index of tree in trees or structured tree
% - fac      ::scalar or 3-tupel: multiplication factor
%     if scalar, diameter is also scaled
%     {DEFAULT: 2x}
% - options  ::string:
%     '-s'   : show before and after
%     '-o'   : do not translate tree to origin before scaling
%     (so: also scale position)
%     '-d'   : do not scale diameter
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% scale_tree   (sample_tree, 1.2, '-s')
%
% See also tran_tree rot_tree flip_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function varargout = scale_tree (intree, fac, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1)||isempty(intree)
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

if (nargin < 2) || isempty (fac)
    % {DEFAULT: 2x}
    fac      = 2; 
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

if ~contains (options, '-o')
    ORI          = [tree.X(1) tree.Y(1) tree.Z(1)];
    tree.X       = tree.X - ORI (1);
    tree.Y       = tree.Y - ORI (2);
    tree.Z       = tree.Z - ORI (3);
end

% scaling:
if numel (fac) > 1
    tree.X       = tree.X * fac (1);
    tree.Y       = tree.Y * fac (2);
    tree.Z       = tree.Z * fac (3);
    if ~contains (options, '-d')
        tree.D   = tree.D * mean (fac (1 : 2));
    end    
else
    tree.X       = tree.X * fac;
    tree.Y       = tree.Y * fac;
    tree.Z       = tree.Z * fac;
    if ~contains (options, '-d')
        tree.D   = tree.D * fac;
    end
end

if ~contains (options, '-o')
    tree.X       = tree.X + ORI (1);
    tree.Y       = tree.Y + ORI (2);
    tree.Z       = tree.Z + ORI (3);
end

if contains (options, '-s') % show option
    clf;
    hold         on;
    HP           = plot_tree (intree, [], [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    HP           = plot_tree (tree, [1 0 0], [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, ...
        {'before',             'after'});
    set          (HP, ...
        'visible',             'off');
    title        ('scale a tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]'); 
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

if (nargout == 1) || (isstruct (intree))
    varargout {1}  = tree; % if output is defined then it becomes the tree
else
    trees {intree} = tree; % otherwise add to end of trees cell array
end


