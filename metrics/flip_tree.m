% FLIP_TREE   Flips a tree around one axis.
% (trees package)
%
% tree = flip_tree (intree, dim, options)
% ---------------------------------------
%
% Flips tree around dimension DIM.
%
% Input
% -----
% - intree  ::integer:   index of tree in trees or structured tree
% - dim     ::1, 2 or 3: dimension to be flipped
%     {DEFAULT: 1, x-axis}
% - options ::string:
%     '-s' : show before and after
%     {DEFAULT: ''}
%
% Output
% -------
% if no output is declared the tree is changed in the trees structure
% - tree     :: structured output tree
%
% Example
% -------
% flip_tree    (sample_tree, [], '-s')
%
% See also tran_tree rot_tree scale_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function tree = flip_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
tree         = intree;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('dim', 1, @isnumeric) % TODO check the size of the fac input
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {'dim'}, {'s'});
%==============================================================================%

switch pars.dim
    case 1
        tree.X   = 2 * tree.X (1) - tree.X;
    case 2
        tree.Y   = 2 * tree.Y (1) - tree.Y;
    case 3
        tree.Z   = 2 * tree.Z (1) - tree.Z;
    otherwise % TODO remove the otherwise condition as dim is checked earlier
        warning  ( ...
            'TREES:wronginputs', ...
            'DIM not the right number');
end

if pars.s % show option
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
    title        ('flip a tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]'); 
    zlabel       ('z [\mum]');
    if pars.dim  == 3
        view     ([0 0]);
    else
        view     (2);
    end
    grid         on;
    axis         image;
end

