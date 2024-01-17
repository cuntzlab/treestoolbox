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
%     '-0'   : the root node is 0 instead of itself, careful this is NEW!!
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
% Copyright (C) 2009 - 2023  Hermann Cuntz

function idpar = idpar_tree (intree, options)

ver_tree     (intree);                 % verify that input is a tree
% use only directed adjacency for this function
dA           = intree.dA;

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

% index to direct parent:
% simple graph theory: feature of adjacency matrix:
idpar            = dA * (1 : size (dA, 1))';

if ~contains (options, '-0')
    % null-compartment (root) becomes index to itsself
    idpar (idpar == 0) = find ((idpar == 0));
end

if contains (options,'-s')            % show option
    clf; 
    HP           = plot_tree  (intree, [], [], [], [], '-b');
    set          (HP, ...
        'facealpha',           0.2, ...
        'edgecolor',           'none');
    
    T            = vtext_tree (intree, [], [0 1 0], [-2 3 5]);
    set          (T, ...
        'fontsize',            14);
    T            = vtext_tree (intree, idpar,      [],  [0 0 5]);
    set          (T, ...
        'fontsize',            14);
    title        ('direct parend ID');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

