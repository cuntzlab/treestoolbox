% CONSTRUCT
%
% functions to generate synthetic trees
%
% Files
%   allBCTs_tree      - Outputs all possible trees with N nodes.
%   allBTs_tree       - Outputs all possible binary trees with N nodes.
%   BCT_tree          - Creates a tree from a BCT string.
%   cap_tree          - Adds a cap to the soma of a tree.
%   clean_tree        - Cleans a tree from nodes inside of main branches.
%   clone_tree        - Cloning a tree type using the MST constructor.
%   cplotter          - Plots a contour.
%   cpoints           - Returns points on a contour.
%   dscam_tree        - Simulates an oversimplified DSCAM mutation.
%   finetune_fix_tree 
%   fix_tree          - Minimum spanning tree based tree repair tool.
%   gscale_tree       - Scales trees from a set of trees to mean tree size.
%   in_c              - Applies inpolygon on contour.
%   isBCT_tree        - Checks if tree is sorted to be BCT conform.
%   jitter_tree       - Jitters coordinates of a tree.
%   MST_tree          - Minimum spanning tree based tree constructor.
%   PP_generator_tree - Distributes points with given R value.
%   quaddiameter_tree - Map quadratic diameter tapering to tree.
%   quadfit_tree      - Fit quadratic diameter taper to tree.
%   rpoints_tree      - Weighted distribution random points within a hull.
%   smooth_tree       - Smoothes a tree along its longest paths.
%   smoothbranch      - Smoothen points along one path.
%   soma_tree         - Adds a soma to a tree.
%   spines_tree       - Add spines to an existing tree.
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

