% TRAN_TREE   translate the coordinates of a tree.
% (trees package)
%
% tree = tran_tree (intree, DD, options)
% --------------------------------------
%
% Translates the coordinates of a tree, per default sets tree root to
% origin (0, 0, 0).
%
% Input
% -----
% - intree   ::integer:index of tree in trees or structured tree
% - DD       ::3-tupel or single value: [dx dy dz] or index of node to
%     center the tree around.
%     {DEFAULT: node n.1 = root}
% - options  ::string:
%     '-s'   : show before and after
%     {DEFAULT: ''}
%
% Output
% -------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% tran_tree    (sample_tree, [20 0], '-s')
% tran_tree    (sample_tree, 5, '-s')
%
% See also scale_tree rot_tree flip_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function tree = tran_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
tree         = intree;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('DD', 1, @isnumeric) %TODO check for the size of DD
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {'DD'}, {'s'});
%==============================================================================%

if length (pars.DD) == 2
    pars.DD       = [pars.DD 0]; % add z = 0 if not defined
end


if numel (pars.DD)    > 1
    tree.X       = tree.X + pars.DD (1);      % center root to coordinates DD:
    tree.Y       = tree.Y + pars.DD (2);
    tree.Z       = tree.Z + pars.DD (3);
else
    tree.X       = tree.X - tree.X (pars.DD); % center around node DD:
    tree.Y       = tree.Y - tree.Y (pars.DD);
    tree.Z       = tree.Z - tree.Z (pars.DD);
end

if pars.s % show option
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
    title        ('move a tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]'); 
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

