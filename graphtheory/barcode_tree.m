% BARCODE_TREE   Barcodes from persistence homology.
% (trees package)
%
% barcode = barcode_tree (intree, V, options)
% -------------------------------------------
%
% Returns the bars in intree according to persistence homology analysis.
% This starts with the longest branch and values in V are accumulated to
% determine longest branches. This is a META-FUNCTION and can lead to
% various applications.
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - V        ::Nx1 vector:   for each node a number to be accumulated
%     {DEFAULT: len}
% - options  ::string:
%     {DEFAULT: ''}
%
% Output
% -------
% - barcode  ::Nx1 vector: length values of each segment
%
% Example
% -------
% barcode      = barcode_tree (sample_tree)
%
% 
% Interpreted from Kanari et al., 2018 with help from Lida Kanari.
%
% See also BLO_tree 
% Uses BLO_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz

function barcode = barcode_tree (intree, V, options)

% trees : contains the tree structures in the trees package
global       trees

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees {intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (V)
    % {DEFAULT: length of segment in um, this way path length determines
    % order}
    V        = len_tree (tree);
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

[BLO, ~, clBLO]  = BLO_tree  (tree, V);
pV               = Pvec_tree (tree, V);
N                = max (BLO);
birth            = zeros (N, 1);
death            = zeros (N, 1);
for counter      = 1 : N
    death (counter) = max (pV (BLO == counter));
    birth (counter) = death (counter) - max (clBLO (BLO == counter));
end
barcode          = [birth death];


