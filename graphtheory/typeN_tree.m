% TYPEN_TREE   Tree node B-C-T info.
% (trees package)
% 
% typeN = typeN_tree (intree, options)
% ------------------------------------
% 
% Returns the BCT string in a vector. This is just the sum of the columns
% in the adjacency matrix and >2 => 2.
% 0 means terminal
% 1 means continuation
% 2 means branch.
%
% Input
% -----
% - intree   ::integer:index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     '-bct' : output as string
%     {DEFAULT: ''}
%
% Output
% ------
% - typeN    ::Nx1 vector: type tree structure
%     (2 branch 1 continue 0 termin.)
%
% Example
% -------
% typeN_tree   (sample_tree, '-s -bct')
%
% See also C_tree T_tree B_tree BCT_tree isBCT_tree
% Uses dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function  typeN = typeN_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
% use only directed adjacency for this function
dA           = intree.dA;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('s', false, @isBinary)
p.addParameter('bct', false, @isBinary)
pars = parseArgs(p, varargin, {}, {'s', 'bct'});
%==============================================================================%

% sum(dA) (actually faster than sum(dA)) ;-):
typeN            = (ones (1, size (dA, 1)) * dA)';
typeN (typeN > 2) = 2;

if pars.bct % give a string output
    typeN        = 68 - typeN;
    typeN (typeN == 68) = 84;
    typeN        = char (typeN);
end

if pars.s % show option
    clf;
    hold         on;
    HP           = plot_tree   (intree, [0 0 0], [], [], [], '-b');
    set          (HP, ...
        'facealpha',           0.2, ...
        'edgecolor',           'none');
    T            = vtext_tree  (intree, typeN, [0 0 0]);
    set          (T, ...
        'fontsize',            8);
    ydim         = ceil (length (typeN) / 50);
    if ischar    (typeN)
        str      = typeN';
    else
        str      = num2str (typeN');
        str (isspace (str)) = [];
    end
    str          = reshape ([ ...
        str,  ...
        (char (zeros (1, ydim * 50 - length (typeN))))], ...
        50, ydim)';
    T            = title (char ('branching gene:', str));
    set          (T, 'fontsize',8,'color',[0 0 0]);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

