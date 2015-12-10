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
% - intree::integer:index of tree in trees or structured tree
% - options::string: {DEFAULT: ''}
%     '-s' : show
%
% Output
% ------
% - rindex::Nx1 vector: region specific index for each node
%
% Example
% -------
% rindex_tree (sample2_tree, '-s')
%
% See also load_tree start_trees
% Uses ver_tree R
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function rindex = rindex_tree (intree, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length(trees); % {DEFAULT tree: last tree in trees cell array}
end;

ver_tree (intree); % verify that input is a tree structure

% use only region vector for this function
if ~isstruct(intree),
    R = trees{intree}.R;
else
    R = intree.R;
end

if (nargin < 2)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

uR = unique(R); % sorted regions
luR = length(uR); % number of regions

rindex = zeros(length(R),1);
rindex(1) = 1;

for ward = 1:luR;
    G = R == uR(ward);
    rindex(G) = 1:sum(G);
end
    
if strfind(options,'-s'), % show option
    clf; hold on; shine; colorbar;
    HP = plot_tree (intree, R); set(HP,'facealpha',.2);
    T = vtext_tree (intree, rindex, [], [0 0 5]); set (T, 'fontsize',14);
    title ('regional index (color - region)');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view(2); grid on; axis image;
end
