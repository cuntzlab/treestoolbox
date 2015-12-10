% IDPAR_TREE   Index to direct parent node in a tree.
% (trees package)
% 
% idpar = idpar_tree (intree, options)
% ------------------------------------
%
% Returns the index to the direct parent node of each individual node in
% the tree.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - options  ::string:
%     '-0'   : the root node is 0 instead of 1 
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - idpar    ::N x 1 vector: index of direct parent node to each node
%
% Example
% -------
% idpar_tree   (sample_tree, '-s')
%
% See also     ipar_tree child_tree
% Uses         ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2015  Hermann Cuntz

function idpar = idpar_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree);                 % verify that input is a tree

% use only directed adjacency for this function
if ~isstruct (intree)
    dA       = trees{intree}.dA;
else
    dA       = intree.dA;
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

% index to direct parent:
% simple graph theory: feature of adjacency matrix:
idpar        = dA * (1 : size (dA, 1))';

if isempty   (strfind (options, '-0'))
    % null-compartment (root) becomes one
    idpar    (idpar == 0) = 1;
end

if strfind   (options,'-s')            % show option
    clf; 
    HP       = plot_tree(intree);
    set      (HP,'facealpha',0.2);
    T        = vtext_tree (intree, idpar, []);
    set      (T, 'fontsize',14);
    title    ('direct parend ID');
    xlabel   ('x [\mum]');
    ylabel   ('y [\mum]');
    zlabel   ('z [\mum]');
    view     (2);
    grid     on;
    axis     image;
end





