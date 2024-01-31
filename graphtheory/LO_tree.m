% LO_TREE   Level order of all nodes of a tree.
% (trees package)
% 
% LO = LO_tree (intree, options)
% ------------------------------
% 
% Returns the summed topological path distance of all child branches to the
% root. The function is called level order and is useful to classify rooted
% trees into isomorphic classes. (see code below)
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - LO       ::vector N x 1: level order of each compartment.
%
% Example
% -------
% LO_tree      (sample_tree, '-s')
%
% See also   PL_tree BO_tree sortLO_tree
% Uses       PL_tree ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function  LO = LO_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
% use only directed adjacency for this function
dA           = intree.dA;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {}, {'s'});
%==============================================================================%

N                = size    (dA, 1);            % number of nodes in tree
PL               = PL_tree (intree);           % path length away from node
sdA              = spdiags (PL, 0, N, N) * dA; % dA-ordered path lengths
% calculating weighted path length:
counter          = 1;
resLO            = sdA;
LO               = sum (resLO)';
while sum (resLO (: ,1)) ~= 0
    counter      = counter + 1;
    % starting at the tips
    % use adjacency matrix to walk through tree accumulating LO:
    resLO        = resLO * dA;
    LO           = LO + sum (resLO)';
end
LO               = LO + PL;
LO               = full (LO);

if pars.s % show option
    clf;
    hold         on; 
    HP           = plot_tree (intree, LO, [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    title        ('level order');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
    colorbar;
end

