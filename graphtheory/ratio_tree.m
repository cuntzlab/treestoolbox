% RATIO_TREE   Ratio between parent and daughter segments in a tree.
% (trees package)
% 
% ratio = ratio_tree (intree, v, options)
% ---------------------------------------
%
% Returns ratio values between daughter nodes and parent nodes for any
% values given in vector v. Typically this is applied on diameter, but:
% This is a META-FUNCTION and can lead to various applications.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - v        ::Nx1 vector:   for each node a number to be ratioed
%     {DEFAULT: D, diameter}
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - ratio    ::Nx1 vector:   ratios of v-values child node to parent node
%
% Example
% -------
% ratio_tree   (sample_tree, [], '-s')
%
% See also   child_tree
% Uses       idpar_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function ratio = ratio_tree (intree, v, options)

ver_tree     (intree);                 % verify that input is a tree

if (nargin < 2) || isempty (v)
    % {DEFAULT vector: diameter values from the tree}
    v = intree.D;
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

 % vector containing index to direct parent:
idpar            = idpar_tree (intree);
% well yes, is this worth an extra function?:
ratio            = v ./ v (idpar);      

if contains (options, '-s')       % show option
    clf;
    hold         on; 
    HP           = plot_tree (intree, ratio, [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    colorbar;
    title        ('parent daughter ratios');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

