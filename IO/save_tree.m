% SAVE_TREE   save tree/trees into a file
% (trees package)
%
% [name path] = save_tree (intree, name)
% --------------------------------------
%
% save trees into a matlab type file
%
% Input
% -----
% - intree::can contain more than one tree, up to 2 depth from e.g.
%     cgui_tree: {{treei1, treei2,... }, {treej1, treej2,...}, ...}
%     or e.g. from trees structure: {tree1, tree2, ...}
%     or just a tree structure.
% - name::string: name of file including the extension ".mtr"
%     {DEFAULT : open gui fileselect} spaces and other weird symbols not
%     allowed!
%
% Output
% ------
% name::string: file name
%
% Example
% -------
% save_tree (sample_tree)
%
% See also
% Uses
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function [tname path]  = save_tree (intree, tname)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    tree = trees; % {DEFAULT: save entire trees cell array}
else
    tree = intree;
end;

% defining a name for the povray-tree
if (nargin < 2)||isempty(tname),
    [tname path] = uiputfile ('.mtr', 'save trees', 'tree.mtr');
    if tname  == 0,
        tname = [];
        return
    end
else
    path = '';
end
% extract a sensible name from the filename string:
nstart = unique ([0 strfind(tname, '/') strfind(tname, '\')]);
if nstart (end) > 0,
    path = [path tname(1 : nstart (end))];
    tname(1 : nstart (end)) = '';
end

save ([path tname], 'tree');




