% PETERS_TREE  Calculates candidate synapses oftwo trees.
% (trees package)
%
% syn = peters_tree (intree1, intree2, spinedis, synapsedis, options)
% -------------------------------------------------------------------
%
% Finds putative synapses of two trees. Loops through all nodes of tree2 to
% find all nodes of tree1 closer than a certian threshold (spinedis). Just
% the closest opposition of the two trees within a certain radius 
% (synapse distance) is kept as a putative synapse. Ouput are the node
% indices of both trees and the distance.
%
% Input
% -----
% - intree1  ::tree: index of tree 1 in trees or structured tree
% - intree2  ::tree: index of tree 2 in trees or structured tree
% - spinedis ::number:  threshold distance 
%     {DEFAULT: 3}
% - synapsedis ::number:  threshold maximum distance between synapses
%     {DEFAULT: 3}
% - options  ::
%     '-r'    : resample to 1 um, each tree 
% 
% Output
% ------
% % - nsyn     ::matrix:    Nx3 for all candidate synapses node index tree1,
%                           tree1 and distance
%
% Example
% -------
% sample1    = peters_tree (tree1, tree2, 3, 10);
%
% Uses  ver_tree
%
%
% Contributed by Lisa Deters and Alexander Bird (modified for TREES)
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function csyns = peters_tree (intree1, intree2, varargin)

ver_tree     (intree1); % verify that input 1 is a tree structure
tree1        = intree1;
ver_tree     (intree2); % verify that input 2 is a tree structure
tree2        = intree2;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('spinedis', 3, @isnumeric) % TODO check for the size of v
p.addParameter('synapsedis', 3, @isnumeric)
p.addParameter('r', true, @isBinary)
pars = parseArgs(p, varargin, {'spinedis', 'synapsedis'}, {'r'});
%==============================================================================%

if pars.r
    tree1    = resample_tree (tree1, 1);
    tree2    = resample_tree (tree2, 1);
end

lastnode         = length (tree1.X);
syns1            = [];
% loop through all nodes of tree1 (axon)
for node1        = 1 : lastnode
    % distance from one tree1 node to all nodes in tree2 (dendrite)
    distance     = sqrt ( ...
        (tree2.X - tree1.X (node1)).^2 + ...
        (tree2.Y - tree1.Y (node1)).^2 + ...
        (tree2.Z - tree1.Z (node1)).^2);
    %find all nodes that are closer then spinedistance and
    %store the amount of these nodes in c
    inodes       = find   (distance < pars.spinedis);
    syns1        = [syns1; ...
        [(node1 + zeros(length (inodes), 1)) inodes (distance (inodes))]];
end

% Sorts the values of syns1 for the third coloumn (the distance of the
% nodes):
syns1            = sortrows (syns1, 3);
csyns            = [];

while ~isempty (syns1)
    csyns            = [csyns; (syns1 (1, :))];
    itree1           = syns1 (2 : end, 1);
    % Distance of nodes (possible synapses) of tree1 to each other:
    distance1        = sqrt ( ...
        (tree1.X (syns1 (1, 1)) - tree1.X (itree1)).^2 + ...
        (tree1.Y (syns1 (1, 1)) - tree1.Y (itree1)).^2 + ...
        (tree1.Z (syns1 (1, 1)) - tree1.Z (itree1)).^2); 
    itree2           = syns1 (2 : end, 2);
    distance2        = sqrt ( ...
        (tree2.X (syns1 (1, 2)) - tree2.X (itree2)).^2 + ...
        (tree2.Y (syns1 (1, 2)) - tree2.Y (itree2)).^2 + ...
        (tree2.Z (syns1 (1, 2)) - tree2.Z (itree2)).^2);
    syns1 (1, :)     = [];
    syns1 ((distance1 < pars.synapsedis) & (distance2 < pars.synapsedis), :) = [];
end

format           short g

