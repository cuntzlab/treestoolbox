% TYPEN_TREE   Tree node B-C-T info.
% (trees package)
% 
% typeN = typeN_tree (intree, options)
% ------------------------------------
% 
% returns the BCT string in a vector. This is just the sum of the columns in
% the adjacency matrix and >2 => 2. 0 means terminal, 1 means continuation,
% 2 means branch.
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - options::string: {DEFAULT: ''}
%     '-s' : show
%     '-bct' : output as string
%
% Output
% ------
% - typeN::Nx1 vector: type tree structure (2 branch 1 continue 0 termin.)
%
% Example
% -------
% typeN_tree (sample_tree, '-s -bct')
%
% See also C_tree T_tree B_tree BCT_tree isBCT_tree
% Uses dA
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function  typeN = typeN_tree (intree, options)

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
typeN = (ones(1,size(dA,1))*dA)';
typeN(typeN>2) = 2;

if strfind(options,'-bct'), % give a string output
    typeN = 68 - typeN; typeN(typeN==68) = 84; typeN = char(typeN);
end

if strfind(options,'-s'), % show option
    clf; hold on; shine; HP = plot_tree (intree, [0 1 0]); set(HP,'facealpha',.5);
    T = vtext_tree (intree, typeN, [0 0 0], [0 0 10]); set (T, 'fontsize',14);
    ydim = ceil(length(typeN)/50);
    if ischar(typeN),
        str = reshape([typeN',char(zeros(1,ydim*50-length(typeN)))],50,ydim)';
    else
        str = num2str(typeN'); str(isspace(str)) = [];
        str = reshape([str,char(zeros(1,ydim*50-length(typeN)))],50,ydim)';
    end
    T = title (strvcat('branching gene:',str));%('termination points');
    set (T, 'fontsize',14,'color',[0 0 0]);
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view(2); grid on; axis image;
end

