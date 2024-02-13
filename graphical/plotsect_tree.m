% PLOTSECT_TREE   Plots a selected path along a tree.
% (trees package)
%
% [HP, indy] = plotsect_tree (intree, sect, color, DD, ipar, options)
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
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [HP, indy] = plotsect_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('sect', [])
p.addParameter('color', [0 0 0])
p.addParameter('DD', [0 0 0])
p.addParameter('ipar', ipar_tree (intree))
pars = parseArgs(p, varargin, {'sect', 'color', 'DD', 'ipar'}, {''});
%==============================================================================%

if length    (pars.DD) < 3
    % append 3-tupel with zeros:
    pars.DD       = [pars.DD (zeros (1, 3 - length (pars.DD)))];
end

% use only node position for this function
X                = intree.X;
Y                = intree.Y;
Z                = intree.Z;

hold             on;
indy             = pars.ipar  ( ...
    pars.sect (1, 2), ...
    1 : find (pars.ipar (pars.sect (1, 2), :) == pars.sect (1, 1)));
HP               = plot3 ( ...
    X (indy) + pars.DD (1), ...
    Y (indy) + pars.DD (2), ...
    Z (indy) + pars.DD (3), 'k-');
set              (HP, ...
    'color',                   pars.color);

