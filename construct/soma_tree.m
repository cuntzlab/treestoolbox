% SOMA_TREE   Adds a soma to a tree.
% (trees package)
%
% tree = soma_tree (intree, maxD, l, options)
% -------------------------------------------
%
% Changes the diameter in all locations closer than l/2 from the root to a
% sort of circular (cosine) soma shape.
% Note! This function was recently corrected to match maxD and l!
%
% Inputs
% ------
% - intree   ::integer: index of tree in trees or structured tree
% - maxD     ::value:   target diameter of the soma
%     {DEFAULT: 30 um}
% - l        ::value:   length of the soma
%     {DEFAULT: 3/2 maxD}
% - options  ::string:
%     '-s'   : show before and after
%     {DEFAULT: ''}
%
% Output
% -------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% soma_tree  (resample_tree (sample_tree, 1), 30, 45, '-s')
%
% See also scale_tree rot_tree and flip_tree
% Uses ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function varargout = soma_tree (intree, maxD, l, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree);

if ~isstruct (intree)
    tree     = trees{intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (maxD)
    maxD     = 30;
end

if (nargin < 3) || isempty (l)
    l        = 1.5 * maxD;
end

if (nargin < 4) || isempty (options)
    options  = '';
end

Plen         = Pvec_tree (tree);
indy         = find      (Plen < l / 2);
% % this used to be:
% dmaxD        = max       (tree.D (indy), ...
%     maxD / 4 * cos (pi * Plen (indy) / (l / 2)) + maxD / 4);

dmaxD        = max       (tree.D (indy), ...
    maxD * cos (pi * Plen (indy) / l) );

tree.D (indy) = dmaxD;

if strfind (options, '-s')
    clf; hold on;
    HP       = plot_tree (intree);
    set      (HP, 'facealpha', .5);
    HP       = plot_tree (tree, [1 0 0]);
    set      (HP, 'facealpha', .5);
    HP (1)   = plot (1, 1, 'k-');
    HP (2)   = plot (1, 1, 'r-');
    legend   (HP, {'before', 'after'});
    set      (HP, 'visible', 'off');
    title    ('add a soma to your tree');
    xlabel   ('x [\mum]');
    ylabel   ('y [\mum]');
    zlabel   ('z [\mum]');
    view     (2);
    grid     on;
    axis     image;
end

if (nargout == 1) || (isstruct (intree))
    varargout{1}  = tree;
else
    trees{intree} = tree;
end
