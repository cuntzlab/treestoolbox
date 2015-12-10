% CLEAN_TREE   Cleans a tree from nodes inside of main branches.
% (trees package)
%
% tree = clean_tree (intree, radius, options)
% -------------------------------------------
%
% Cleans tree of improbable nodes (after e.g. automated reconstruction or
% artificial generation of a tree structure). Termination points in close
% vicinity of other nodes on a different branch will be deleted and very
% short terminal branches as well. The "close vicinity" depends on the
% radius of the "other node" and on the input parameter radius. Consecutive
% calls of this function can be useful.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - radius   ::value:   scaling factor for radius delimiter
%     {DEFAULT: no scaling == 1}
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     {DEFAULT '-w'}
%
% Output
% ------
% if no output is declared the trees are added in trees
% - tree     ::structured output tree
%
% Example
% -------
% clean_tree (sample_tree, 10, '-s')
%
% See also quaddiameter_tree RST_tree
% Uses sort_tree idpar_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function tree = clean_tree (intree, radius, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length(trees);
end;
ver_tree (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (radius)
    radius   = 1;
end

if (nargin < 3) || isempty (options)
    options  = '-w';
end

% sort tree to be BCT conform, heavy parts left:
tree             = sort_tree (intree, '-LO');
D                = tree.D;            % local diameter values
len              = len_tree (tree);   % length values of tree segments [um]
% sum (dA) (actually faster than sum(dA)!!!):
typeN            = (ones (1, size (tree.dA, 1)) * tree.dA)';
iT               = find (typeN == 0); % find terminals
% delete only one terminal branch per branch point:
iBpar            = [];
idpar            = idpar_tree (tree);
IFFER            = [];
if length (iT)   > 1
    if strfind   (options, '-w') % waitbar option: initialization
        if length (iT) > 499
            HW   = waitbar (0, 'cleaning the tree...');
            set  (HW, 'Name', '..PLEASE..WAIT..YEAH..');
        end
    end
    for counter  = 1 : length (iT)
        % waitbar option: update:
        if strfind (options, '-w')
            if   (mod (counter, 500) == 0)
                 waitbar (counter / length (iT), HW);
            end
        end
        % wow! Simple way to describe branch indices when tree was sorted:
        ibranch  = find  (abs (typeN (1 : iT (counter) - 1) - 1), ...
            1, 'last') + 1 : iT (counter);
        idbpar   = idpar (ibranch (1)); % direct parent branch point
        if ~ismember (idbpar, iBpar) && ...
                ~isempty (setdiff (find (eucl_tree (tree, iT (counter)) < ...
                (D / 2 + radius / 2)), ibranch))
            iBpar  = [iBpar idbpar];
            IFFER  = [IFFER ibranch];
        end
        if ~ismember (idbpar, iBpar) && ...
                ~isempty (ibranch) && ...
                (sum (len (ibranch)) < radius)
            iBpar  = [iBpar idbpar];
            IFFER  = [IFFER ibranch];
        end
    end
    if strfind   (options, '-w') % waitbar option: close
        if length (iT) > 499
            close (HW);
        end
    end
end
IFFER            = unique (IFFER);
if ~isempty      (IFFER)
    tree         = delete_tree (tree, IFFER); % delete all unwanted points
end

if strfind       (options, '-s')
    clf; hold on;
    plot_tree    (intree, [],      [], [], [], '-3l');
    plot_tree    (tree,   [1 0 0], [], [], [], '-3l');
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, {'before', 'after'});
    set          (HP, 'visible', 'off');
    title        ('clean tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

if (nargout == 0) && ~(isstruct (intree))
    % otherwise the orginal tree in trees is replaced
    trees {intree} = tree;
end

