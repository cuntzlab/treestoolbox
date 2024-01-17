% RINDEX_TREE   Region-specific indexation of nodes in a tree.
% (trees package)
%
% rindex = rindex_tree (intree, options)
% --------------------------------------
%
% Returns the region specific index for each region individually increasing
% in order of appearance within that region.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - rindex   ::Nx1 vector: region specific index for each node
%
% Example
% -------
% rindex_tree  (sample2_tree, '-s')
%
% See also load_tree start_trees
% Uses ver_tree R
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function rindex = rindex_tree (intree, options)

ver_tree     (intree); % verify that input is a tree structure
% use only region vector for this function
R            = intree.R;

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

uR               = unique (R);  % sorted regions
luR              = length (uR); % number of regions

rindex           = zeros  (length (R), 1);
rindex (1)       = 1;

for counter      = 1 : luR
    G            = R == uR (counter);
    rindex (G)   = 1 : sum (G);
end

if contains (options, '-s') % show option
    clf;
    hold         on;
    colorbar;
    HP           = plot_tree  (intree, R, [], [], [], '-b');
    set          (HP, ...
        'facealpha',           0.5, ...
        'edgecolor',           'none');
    T            = vtext_tree (intree, rindex, [], [0 0 5]);
    set          (T, ...
        'fontsize',            14);
    title        ('regional index (color - region)');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

