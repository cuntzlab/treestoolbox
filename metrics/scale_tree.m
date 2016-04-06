% SCALE_TREE   Scales a tree.
% (trees package)
%
% tree = scale_tree (intree, fac, options)
% ----------------------------------------
%
% Scales the entire tree by factor fac. If fac 3-tupel scaling factor can
% be different for X, Y and Z. By default, diameter is also scaled.
%
% Input
% -----
% - intree   ::integer:index of tree in trees or structured tree
% - fac      ::scalar or 3-tupel: multiplication factor
%     if scalar, diameter is also scaled
%     {DEFAULT: 2x}
% - options  ::string:
%     '-s'   : show before and after
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
% Copyright (C) 2009 - 2016  Hermann Cuntz

function varargout = scale_tree (intree, fac, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1)||isempty(intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

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

% scaling:
if numel (fac) > 1
    tree.X       = tree.X * fac (1);
    tree.Y       = tree.Y * fac (2);
    tree.Z       = tree.Z * fac (3);
else
    tree.X       = tree.X * fac;
    tree.Y       = tree.Y * fac;
    tree.Z       = tree.Z * fac;
    if isempty   (strfind (options, '-d'))
        tree.D   = tree.D * fac;
    end
end

if strfind       (options, '-s') % show option
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

if (nargout == 1)||(isstruct (intree))
    varargout {1}  = tree; % if output is defined then it becomes the tree
else
    trees {intree} = tree; % otherwise add to end of trees cell array
end


