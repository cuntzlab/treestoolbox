% PVEC_TREE   Cumulative summation along paths of a tree.
% (trees package)
% 
% Pvec = Pvec_tree (intree, v, options)
% -------------------------------------
%
% Cumulative vector, calculates the total path to the root cumulating
% elements of v (addition) of each node. This is a META-FUNCTION and can
% lead to various applications. NaN values now are ignored.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - v        ::Nx1 vector:   for each node a number to be cumulated
%     {DEFAULT: len}
% - options  ::string:
%     '-s'   : shows first column of matrix dist
%     {DEFAULT: ''}
%
% Output
% ------
% - Pvec     ::Nx1 vector:   cumulative v along path from the root
%
% Example
% -------
% Pvec_tree    (sample_tree, [], '-s')
%
% See also   ipar_tree child_tree morph_tree bin_tree
% Uses       ipar_tree len_tree ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function Pvec = Pvec_tree (intree, varargin)

ver_tree     (intree);                 % verify that input is a tree

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('v', len_tree (intree), @isnumeric) % TODO check the size and type of v
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {'v'}, {'s'});
%==============================================================================%

% parent index structure (see "ipar_tree"):
ipar             = ipar_tree (intree);
v0               = [0; pars.v];
v0 (isnan (v0))  = 0;

if size (ipar, 1) == 1
    Pvec         = pars.v;
else
    Pvec         = sum (v0 (ipar + 1), 2);
end

if pars.s       % show option
    clf;
    hold         on; 
    HP           = plot_tree (intree, Pvec, [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');    
    colorbar;
    title        ('path accumulation');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

