% SCALE_TREE   Scales a tree.
% (trees package)
%
% tree = scale_tree (intree, fac, options)
% ----------------------------------------
%
% Scales the entire tree by factor fac at the location where it is.
% If fac 3-tupel scaling factor can be different for X, Y and Z. By
% default, diameter is also scaled (as average between X and Y scaling).
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
% Copyright (C) 2009 - 2024  Hermann Cuntz

function tree = scale_tree (intree, varargin)

tree         = intree;
ver_tree     (tree); % verify that input is a tree structure

%=============================== Parsing inputs ==========================%
p                = inputParser;
p.addParameter   ('fac', 2) % TODO check the size and type of fac
p.addParameter   ('o', false)
p.addParameter   ('d', false)
p.addParameter   ('s', false)
pars             = parseArgs (p, varargin, {'fac'}, {'o', 'd', 's'});
%=========================================================================%

if ~pars.o
    ORI          = [tree.X(1) tree.Y(1) tree.Z(1)];
    tree.X       = tree.X - ORI(1);
    tree.Y       = tree.Y - ORI(2);
    tree.Z       = tree.Z - ORI(3);
end

% scaling:
if numel(pars.fac) > 1
    tree.X       = tree.X * pars.fac(1);
    tree.Y       = tree.Y * pars.fac(2);
    tree.Z       = tree.Z * pars.fac(3);
    if ~pars.d
        tree.D   = tree.D * mean(pars.fac(1 : 2));
    end    
else
    tree.X       = tree.X * pars.fac;
    tree.Y       = tree.Y * pars.fac;
    tree.Z       = tree.Z * pars.fac;
    if ~pars.d
        tree.D   = tree.D * pars.fac;
    end
end

if ~pars.o
    tree.X       = tree.X + ORI(1);
    tree.Y       = tree.Y + ORI(2);
    tree.Z       = tree.Z + ORI(3);
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
    HP (1)       = plot      (1, 1, 'k-');
    HP (2)       = plot      (1, 1, 'r-');
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


