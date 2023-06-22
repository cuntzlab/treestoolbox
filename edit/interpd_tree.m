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
% treeD       = interpd_tree (tree, [1 10], '-s');
%
% contributed function by Marcel Beining, 2017
%
% Uses ipar_tree Pvec_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function tree = interpd_tree (tree, ind)

ver_tree         (tree)

PL               = Pvec_tree (tree);
ipar             = ipar_tree (tree);

if     any (ipar (ind (1), :) == ind (2))
    ind          = ipar (ind (1), 1 : find (ipar (ind (1), :) == ind (2)));
elseif any (ipar (ind (2), :) == ind (1))
    ind          = ipar (ind (2), 1 : find (ipar (ind (2), :) == ind (1)));
else
    errordlg     ('Indices do not lie on the same path to the root');
    return
end

m                =  ...
    (tree.D (ind (end)) - tree.D (ind (1)))/ ...
    (    PL (ind (end)) -     PL (ind (1)));

tree.D(ind)      = ...
    m * (PL (ind) - PL (ind (1))) + ...
    tree.D (ind (1));



