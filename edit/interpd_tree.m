% INTERPD_TREE   Interpolates the diameter between two nodes.
% (trees package)
%
% tree = interpd_tree (tree, ind)
% -------------------------------
%
% Linearly interpolates the node diameters between two nodes with indices
% ind.
%
% Input
% -----
% - tree     ::structure:   structured tree
% - ind      ::2x1 vector:  start and end node indices of the section which
%                           should get interpolated diamaters
%
% Output
% ------
% - tree     :: structured output tree
%
% Example
% -------
% tree        = sample_tree;
% tree.D (1)  = 20;
% treeD       = interpd_tree (tree, [1 10]);
%
% contributed function by Marcel Beining, 2017
%
% Uses ipar_tree Pvec_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function tree = interpd_tree (tree, varargin)

ver_tree         (tree)

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('ind', [], @isnumeric)
pars = parseArgs(p, varargin, {'ind'}, {});
%==============================================================================%

PL               = Pvec_tree (tree);
ipar             = ipar_tree (tree);

if     any (ipar (pars.ind (1), :) == pars.ind (2))
    pars.ind          = ipar (pars.ind (1), 1 : find (ipar (pars.ind (1), :) == pars.ind (2)));
elseif any (ipar (pars.ind (2), :) == pars.ind (1))
    pars.ind          = ipar (pars.ind (2), 1 : find (ipar (pars.ind (2), :) == pars.ind (1)));
else
    errordlg     ('Indices do not lie on the same path to the root');
    return
end

m                =  ...
    (tree.D (pars.ind (end)) - tree.D (pars.ind (1)))/ ...
    (    PL (pars.ind (end)) -     PL (pars.ind (1)));

tree.D(pars.ind)      = ...
    m * (PL (pars.ind) - PL (pars.ind (1))) + ...
    tree.D (pars.ind (1));



