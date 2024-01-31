% T_TREE   Termination point index in a tree.
% (trees package)
% 
% T = T_tree (intree, options)
% ----------------------------
%
% Returns a binary vector which is one only where there is a termination
% node (exactly none child). Termination point indices are then find (T).
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
% - T        ::Nx1 logical vector: Terminals are 1, others 0
%
% Example
% -------
% T_tree       (sample_tree, '-s')
%
% See also C_tree B_tree typeN_tree BCT_tree isBCT_tree
% Uses ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function T = T_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
% use only directed adjacency for this function
dA           = intree.dA;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {}, {'s'});
%==============================================================================%

% sum(dA) (actually faster than sum(dA)) ;-):
T                = ((ones (1, size (dA, 1)) * dA) == 0)';
% (termination points have zero entries in dA)

if pars.s % show option
    clf;
    hold         on; 
    plot_tree    (intree, [], [], [], [], '-b');
    pointer_tree (intree, find (T), 50);
    title        ('termination points');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

