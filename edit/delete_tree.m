% DELETE_TREE   Delete nodes from a tree.
% (trees package)
%
% tree = delete_tree (intree, pars.inodes, options)
% --------------------------------------------
%
% Deletes nodes in a tree. Trifurcations occur when deleting any branching
% point following directly another branch point. Region numbers are changed
% and region name array is trimmed.
% Alters the topology! Root deletion can lead to unexpected results (when
% root is a branch point the output is multiple trees!)
%
% Input
% -----
% - intree   ::integer:   index of tree in trees or structured tree
% - pars.inodes   ::vector:    node indices
%     {DEFAULT: nothing!! (this used to be: last node)}
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     '-r'   : do not trim regions array
%     '-x'   : append children nodes
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% delete_tree (sample_tree, 5 : 2 : 8, '-s')
%
% See also insert_tree cat_tree
% Uses idpar_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function tree = delete_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
tree         = intree;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('inodes', [])
p.addParameter('w', false, @isBinary)
p.addParameter('r', false, @isBinary)
p.addParameter('x', false, @isBinary)
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {'inodes'}, {'w', 'r', 'x', 's'});
%==============================================================================%

dA           = tree.dA;      % directed adjacency matrix of tree
N            = size (dA, 1); % number of nodes in tree

if islogical (pars.inodes) && numel (pars.inodes) == N
    pars.inodes   = find (pars.inodes);
end

if size (pars.inodes, 1) == N
    % all nodes are deleted, return empty vector:
    tree = [];
    return
end

if pars.x
    append_children = false;
else
    append_children = true;
end

% nodes get deleted one by one, therefore new index has to be calculated
% each time, using sindex:
sindex           = 1 : N;

if pars.w      % waitbar option: initialization
    if length    (pars.inodes) > 499
        HW       = waitbar (0, 'deleting nodes...');
        set      (HW, 'Name', '..PLEASE..WAIT..YEAH..');
    end
end
for counter      = 1 : length (pars.inodes)
    if pars.w  % waitbar option: update
        if mod   (counter, 500) == 0
            waitbar (counter / length (pars.inodes), HW);
        end
    end
    % find the node index corresponding to the pruned tree:
    inode        = find (pars.inodes (counter) == sindex);
    % delete this node from the index list
    sindex (inode) = [];
    % find the column in dA corresponding to this node
    ydA          = dA (:, inode);
    % this column contains ones at the node's child indices
    % find the parent index to inode
    idpar        = find (dA (inode, :));
    if append_children  && ~isempty  (idpar)
        % if it is not root then add inode's children to inode's parent
        dA (:, idpar) = dA (:, idpar) + ydA;
    end
    % get rid of the node in the adjacency matrix by eliminating row and
    % column inode.
    %if ~append_children && ~isempty  (idpar)
    dA (:, inode) = [];
    dA (inode, :) = [];
    %end
end
if pars.w  % waitbar option: close
    if length    (pars.inodes) > 499
        close    (HW);
    end
end
tree.dA          = dA;

% shorten all vectors of form Nx1
S                = fieldnames (tree);
for counter      = 1 : length (S)
    if ~strcmp   (S{counter}, 'dA')
        vec      = tree.(S{counter});
        if isvector (vec) && (numel (vec) == N) && ~(ischar (vec))
            tree.(S{counter})(pars.inodes)     = [];
        end
    end
end

% eliminate obsolete regions
if ~pars.r
    if isfield   (tree, 'R')
        [i1, ~, i3]  = unique (tree.R);
        tree.R   = i3;
        if isfield      (tree, 'rnames')
            tree.rnames = tree.rnames (i1);
        end
    end
end

% if root was deleted and it was a branch point the result is many trees:
iA               = find (sum (tree.dA, 2) == 0);
if ~append_children && length (iA) > 1
    s            = cell (1, length (iA));
    for counter1  = 1 : length (iA)
        [~, dtree]  = sub_tree (tree, iA (counter1));
        % shorten all vectors of form Nx1
        S        = fieldnames (dtree);
        for counter2      = 1 : length (S)
            if ~strcmp   (S{counter2}, 'dA')
                vec      = dtree.(S{counter2});
                if isvector (vec) && (numel (vec) == N) && ~(ischar (vec))
                    dtree.(S{counter2})(pars.inodes)     = [];
                end
            end
        end
        % eliminate obsolete regions
        if ~pars.r
            if isfield   (dtree, 'R')
                [i1, ~, i3]  = unique (dtree.R);
                dtree.R   = i3;
                if isfield      (dtree, 'rnames')
                    dtree.rnames = dtree.rnames (i1);
                end
            end
        end
        s{counter1} = dtree;
    end
    tree         = s;
end

% display the result
if pars.s
    clf;
    hold         on;
    plot_tree    (intree);
    colors       = [ ...
        0    1    0; ...
        0    0    1; ...
        0    0.5  0; ...
        0    0.75 0.75; ...
        0.75 0    0.75; ...
        0.75 0.75 0; ...
        0.5  0    0];
    if length    (tree) > 1
        for counter = 1 : length (tree)
            plot_tree ( ...
                tree{counter}, ...
                colors (mod (counter - 1, size (colors, 1)) + 1, :), 100);
        end
    else
        plot_tree    (tree, [0 1 0], 100);
        HP (1)       = plot (1, 1, 'k-');
        HP (2)       = plot (1, 1, 'g-');
        legend       (HP, ...
            {'original tree',      'trimmed tree'}); 
        set          (HP, ...
            'visible',             'off');
    end
    title        ('find the differences: delete nodes in tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
    if ~isempty  (pars.inodes)
        pointer_tree (intree, pars.inodes);
    end
end

