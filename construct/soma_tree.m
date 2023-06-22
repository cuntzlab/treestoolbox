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
%     '-r'   : give the added soma the region "soma"
%     '-b'   : make diameter after branch point in soma smaller by factor
%              sqrt (2) to account for overlapping surface 
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
% added -r and -b options by Marcel Beining   2017
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function varargout = soma_tree (intree, maxD, l, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

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

Plen             = Pvec_tree (tree);
indy             = find      (Plen < l / 2);
% % this used to be:
% dmaxD        = max       (tree.D (indy), ...
%     maxD / 4 * cos (pi * Plen (indy) / (l / 2)) + maxD / 4);

dmaxD            = max       ( ...
    tree.D (indy), ...
    maxD * cos (pi * Plen (indy) / l) );

if contains (options, '-b')
    flag         = 0;
    % check if branch point directly at soma..check if this branchpoint is
    % just the axon (angle should be wider than 90°):
    if 1 < numel (idchild_tree  (tree, 1))  
        dr       = direction_tree      (tree);
        ch       = idchild_tree (tree, 1);
        if abs   (rad2deg (atan2 ( ...
                norm (cross (dr (ch (1), :), dr (ch (2), :))), ...
                dot (dr (ch (1), :), dr (ch (2), :))))) > 90
            flag = 1;
        end
    end
    adj          = Pvec_tree (tree, B_tree (tree)); % get branch order
    % branch order at branch point - 1:
    adj (B_tree (tree)) = adj (B_tree (tree)) - 1; 
    % adjust value = after each branch point diameter is reduced by sqrt(2)
    % to have same summed surface as without branching (as NEURON/Matlab is
    % not aware of overlapping surfaces):
    adj          = sqrt (2).^(adj - flag);     
    dmaxD        = max (tree.D (indy), dmaxD./adj (indy));
end

tree.D (indy)    = dmaxD;

if contains (options, '-r')
    if ~any (strcmp (intree.rnames,'soma'))
        tree.rnames  = [tree.rnames, 'soma'];
    end
    tree.R (indy)    = find (strcmp (tree.rnames, 'soma'));
end

if contains      (options, '-s')
    clf;
    hold         on;
    HP           = plot_tree (intree);
    set          (HP, 'facealpha', .5);
    HP           = plot_tree (tree, [1 0 0]);
    set          (HP, 'facealpha', .5);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, {'before', 'after'});
    set          (HP, 'visible', 'off');
    title        ('add a soma to your tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

if (nargout == 1) || (isstruct (intree))
    varargout{1}  = tree;
else
    trees{intree} = tree;
end



