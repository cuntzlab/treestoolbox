% PLOTSECT_TREE   Plots a selected path along a tree.
% (trees package)
%
% [HP, indy] = plotsect_tree (intree, sect, color, DD, options, ipar)
% -------------------------------------------------------------------
%
% Draws a line through a section out of a tree. The section must be a
% directed path away from the root.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - sect     ::2-tupel:      start and end nodes of a section.
%     {NOTE!! NO DEFAULT}
% - color    ::3-tupel:      RGB values
%     {DEFAULT: black [0 0 0]}
% - DD       :: XY-tupel or XYZ-tupel: coordinates offset
%     {DEFAULT no offset [0,0,0]}
% - options  ::string:
%     {DEFAULT: ''}
% - ipar     ::matrix: ipar from ipar_tree, slow part of this function
%
% Output
% ------
% - HP       ::handle:       graphics handle to resulting line
% - indy     ::vector:       indices to nodes in branch
%
% Example
% -------
% sample       = sample_tree;
% plotsect_tree (sample, [1 (size (sample.dA, 1))], [1 0 0]);
%
% See also   dissect_tree delete_tree
% Uses       ipar_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [HP, indy] = plotsect_tree ( ...
    intree, sect, color, DD, options, ipar)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 3) || isempty (color)
    % {DEFAULT color: black}
    color    = [0 0 0];
end

if (nargin < 4) || isempty (DD)
    % {DEFAULT 3-tupel: no spatial displacement from the root}
    DD       = [0 0 0];
end
if length    (DD) < 3
    % append 3-tupel with zeros:
    DD       = [DD (zeros (1, 3 - length (DD)))];
end

if (nargin < 5) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

if nargin < 6
    % out of computation time this is a parameter; in this way it does not
    % need to be recalculated everytime for each path.
    % parent index structure (see "ipar_tree"):
    ipar     = ipar_tree (intree);
end

% use only node position for this function
if ~isstruct     (intree)
    X            = trees{intree}.X;
    Y            = trees{intree}.Y;
    Z            = trees{intree}.Z;
else
    X            = intree.X;
    Y            = intree.Y;
    Z            = intree.Z;
end

hold on;
indy             = ipar  ( ...
    sect (1, 2), ...
    1 : find (ipar (sect (1, 2), :) == sect (1, 1)));
HP               = plot3 ( ...
    X (indy) + DD (1), ...
    Y (indy) + DD (2), ...
    Z (indy) + DD (3), 'k-');
set              (HP, ...
    'color',                   color);




