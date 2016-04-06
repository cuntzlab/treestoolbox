% SWC_TREE   Export tree to swc-format.
% (trees package)
% 
% [name path] = swc_tree (intree, name)
% -------------------------------------
%
% exports a tree to the swc-format, a matrix with 7 columns:
% [inode R X Y Z D/2 idpar]
% node index inode is usually from 1..N and idpar is the direct parent index.
% The root has an idpar of -1. Fills in R if R is missing.
% 
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - name::string: name of file including the extension ".swc"
%     {DEFAULT : open gui fileselect}
%
% Output
% ------
% - name::string: name of output file; [] no file was selected -> no output
% - path::sting: path of the file, complete string is therefore:
%     [path name] 
%
% Example
% -------
% swc_tree (sample_tree)
%
% See also load_tree and start_trees
% Uses idpar_tree ver_tree X Y Z D
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [tname, path] = swc_tree (intree, tname)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length (trees); % {DEFAULT tree: last tree in trees cell array}
end;

ver_tree (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree),
    tree = trees {intree};
else
    tree = intree;
end

% defining a name for saved file
if (nargin < 2)||isempty(tname),
    [tname path] = uiputfile ('.swc', 'export to swc', 'tree.swc');
    if tname  == 0,
        tname = [];
        return
    end
else
    path = '';
end
% extract a sensible name from the filename string:
nstart = unique ([0 strfind(tname, '/') strfind(tname, '\')]);
nend   = [length(tname) strfind(tname, '.swc')];
name   = tname (nstart (end) + 1 : nend (end) - 1);

D = tree.D; % local diameter values of nodes on tree
N = size (D, 1); % number of nodes in tree
if isfield (tree, 'R'),
    R = tree.R; % region values on nodes in the tree
else
    R = ones (N, 1); % add a homogeneous regions field of all ones
end

idpar0 = idpar_tree (tree, '-0'); % vector containing index to direct parent
idpar0 (idpar0 == 0) = -1;

% then it is trivial:
swc = [(1 : N)' R tree.X tree.Y tree.Z tree.D/2 idpar0];
swcfile = fopen([path tname],'w'); % open file
fwrite  (swcfile, ['# TREES toolbox tree - ' name,   char(13), char(10)],'char');
fwrite  (swcfile, ['# written by an automatic procedure "swc_tree" part of the TREES package', char(13), char(10)], 'char');
fwrite  (swcfile, ['# in MATLAB',                    char(13), char(10)], 'char');
fwrite  (swcfile, ['# copyright 2009 Hermann Cuntz', char(13), char(10)], 'char');
fwrite  (swcfile, ['#',                              char(13), char(10)], 'char');
fwrite  (swcfile, ['# inode R X Y Z D/2 idpar',      char(13), char(10)], 'char');
fprintf (swcfile, '%d %d %12.8f %12.8f %12.8f %12.8f %d\n', swc');
fclose  (swcfile);