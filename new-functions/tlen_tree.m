% TLEN_TREE   Total length of structered tree
%
% tlen = tlen_tree (intree)
% --------------------------------------
%
% Input
% -----
% - intree   ::integer: (index of tree in trees or) structured tree
%
% Output
% ------
% tlen       ::integer: total length of tree
%
% Example
% -------
% tlen_tree (sample_tree)
%
% Uses       len_tree 

function tlen = tlen_tree (intree)
tlen = sum (len_tree (intree));