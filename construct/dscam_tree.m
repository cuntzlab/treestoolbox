% DSCAM_TREE   Simulates an oversimplified DSCAM mutation.
% (trees package)
%
% tree = dscam_tree (intree, iterations, options)
% ----------------------------------------------
%
% See Bird, Deters, Cuntz 2021. The iterations move branches closer to each
% other thereby affecting the optimal wiring. Resample carefully!
%
% Input
% ----
% - intree     ::struct: input tree
% - iterations ::number: N iterations
% Output
% ------
%  - tree      ::struct: output   tree
%
%
% Example
% -------
% dscam_tree (sample2_tree, 40, '-s')
%
% See also
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function tree = dscam_tree (intree, varargin)

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('iterations', length(intree.X)*5)
p.addParameter('s', false)
pars = parseArgs(p, varargin, {'iterations'}, {'s'});
%==============================================================================%

tree             = intree;

%How far should a node be moved to closest node?
movePercent      = 0.1;
for counter      = 1 : pars.iterations

    % create index vector
    iVector 	 = true (length (tree.X), 1);

    % find a node that to start from
    iStart       = randi (length (tree.X) - 1) + 1;

    %find parentnodes of iStart and mark them
    iParent 			   = ipar_tree (tree);
    iParent         	   = iParent   (iStart, :)';
    iParent (iParent == 0) = [];
    iVector (iParent)  	   = 0;

    %find subtree of iStart and mark it
    iChild                 = logical (sub_tree (tree, iStart));
    iVector (iChild) 	   = 0;

    % calculate distance from iStart to all other nodes
    distance     = sqrt ( ...
        (tree.X - tree.X (iStart)).^2 + ...
        (tree.Y - tree.Y (iStart)).^2 + ...
        (tree.Z - tree.Z (iStart)).^2);

    % cluster nodes
    iVector (distance < 2) = 0;

    % if all nodes are marked (e.g. root is iStart) skip iterations
    if (sum (iVector) == 0)
        continue
    end

    %find the closest node that is not parent or iChildtree
    iClose       = find (distance == min (distance (iVector)));
    iClose       = iClose (1);

    %move nodes  10 percent closer together
    XYZMove      = [ ...
        (tree.X (iClose)) - (tree.X (iStart));...
        (tree.Y (iClose)) - (tree.Y (iStart));...
        (tree.Z (iClose)) - (tree.Z (iStart))]...
        .* movePercent;

    tree.X (iStart) = tree.X (iStart) + XYZMove (1);
    tree.Y (iStart) = tree.Y (iStart) + XYZMove (2);
    tree.Z (iStart) = tree.Z (iStart) + XYZMove (3);

    %move subtree with node
    tree.X (iChild) = tree.X (iChild) + XYZMove (1);
    tree.Y (iChild) = tree.Y (iChild) + XYZMove (2);
    tree.Z (iChild) = tree.Z (iChild) + XYZMove (3);
end

if pars.s
    clf;
    hold         on;
    plot_tree    (intree, [],      [], [], [], '-3l');
    plot_tree    (tree,   [1 0 0], [], [], [], '-3l');
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, {'before', 'after'});
    set          (HP, ...
        'visible',             'off');
    title        ('DSCAM tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end



