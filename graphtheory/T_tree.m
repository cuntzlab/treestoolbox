% T_TREE   Termination point index in a tree.
% (trees package)
% 
% T = T_tree (intree, options)
% ----------------------------
%
% returns a binary vector which is one only where a node is a terminal.
%
% Input
% -----
% - intree::integer:index of tree in trees structure or structured tree
% - options::string: {DEFAULT: ''}
%     '-s' : show
%
% Output
% ------
% T::Nx1 logical vector: terminals are 1, others 0
%
% Example
% -------
% T_tree (sample_tree, '-s')
%
% See also C_tree B_tree typeN_tree BCT_tree isBCT_tree
% Uses ver_tree dA
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function T = T_tree (intree, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length(trees); % {DEFAULT tree: last tree in trees cell array} 
end;

ver_tree (intree); % verify that input is a tree structure

% use only directed adjacency for this function
if ~isstruct(intree),
    dA = trees{intree}.dA;
else
    dA = intree.dA;
end

if (nargin < 2)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

% sum(dA) (actually faster than sum(dA)) ;-):
T = ((ones(1,size(dA,1))*dA)==0)'; % continuation points have zero entries in dA

if strfind(options,'-s'), % show option
    clf; hold on; shine; plot_tree (intree);
    HP = pointer_tree (intree, find(T), 50); set(HP, 'facealpha',0.1);
    T = title ('termination points');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view(2); grid on; axis image;
end