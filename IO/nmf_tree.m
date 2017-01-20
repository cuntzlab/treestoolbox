% NMF_TREE   Export tree to nmf-format, our extended swc format.
% (trees package)
% 
% [name path] = nmf_tree (intree, name)
% -------------------------------------
%
% Exports a tree to the nmf-format (HDF5), for now only swc info gets
% exported, a matrix with 7 columns:
% [inode R X Y Z D/2 idpar]
% node index inode is usually from 1..N and idpar is the direct parent
% index. The root has an idpar of -1. Fills in R if R is missing.
% 
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - name     ::string:  name of file including the extension ".nmf"
%     {DEFAULT : open gui fileselect}
%
% Output
% ------
% - name     ::string: name of output file; 
%                      [] no file was selected -> no output
% - path     ::sting:  path of the file, 
%                      complete string is therefore: [path name] 
%
% Example
% -------
% nmf_tree     (sample_tree)
%
% See also swc_tree load_tree and start_trees
% Uses idpar_tree ver_tree X Y Z D
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [tname, path] = nmf_tree (intree, tname)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees {intree};
else
    tree     = intree;
end

% defining a name for saved file
if (nargin < 2) || isempty (tname)
    [tname, path]  = uiputfile ('.nmf', 'export to nmf', 'tree.nmf');
    if tname       == 0
        tname      = [];
        return
    end
else
    path           = '';
end

% extract a sensible name from the filename string:
nstart           = unique ( ...
    [0 (strfind (tname, '/')) (strfind (tname, '\'))]);
nend             = [(length (tname)) (strfind (tname, '.nmf'))];
name             = tname (nstart (end) + 1 : nend (end) - 1);
nmffile          = [path tname];

N                = length (tree.X);
idpar            = idpar_tree (tree);
idpar (1)        = -1;
h5create         (nmffile, ...
    '/swc/index', [N 1]);
h5writeatt       (nmffile, '/swc', 'soma_type', 'Multiple cylinders');
h5writeatt       (nmffile, '/swc', 'info', ['TREES toolbox tree - ' name]);

h5write          (nmffile, '/swc/index', (1 : N)');

h5create         (nmffile, ...
    '/swc/parent_index', [N 1]);
h5write          (nmffile, '/swc/parent_index', idpar);

h5create         (nmffile, ...
    '/swc/r',                  [N 1]);
h5write          (nmffile, '/swc/r', tree.D / 2);

h5create         (nmffile, ...
    '/swc/type',               [N 1]);
h5write          (nmffile, '/swc/type', tree.R);

h5create         (nmffile, ...
    '/swc/x',                  [N 1]);
h5write          (nmffile, '/swc/x', tree.X);

h5create         (nmffile, ...
    '/swc/y',                  [N 1]);
h5write          (nmffile, '/swc/y', tree.Y);

h5create         (nmffile, ...
    '/swc/z',                  [N 1]);
h5write          (nmffile, '/swc/z', tree.Z);


