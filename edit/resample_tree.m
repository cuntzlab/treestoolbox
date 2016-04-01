% RESAMPLE_TREE   Redistributes nodes on tree.
% (trees package)
%
% tree = resample_tree (intree, sr, options)
% ------------------------------------------
%
% Resamples a tree to equidistant nodes of distance sr. In order to do so
% some abstraction principles need to be arbitrarily set.
% This function alters the original morphology.
%
% Input
% -----
% - intree   ::integer/tree: index of tree in trees or structured tree
% - sr       ::scalar:       sampling [um]
%     {DEFAULT: 10 um}
% - options  ::string:
%     '-s'   : show
%     '-e'   : echo modified nodes
%     '-w'   : waitbar
%     '-d'   : interpolates diameters (changes total surface & volume)
%     '-v'   : do not collapse branchings of small angles {NOT DEFAULT}
%     imprecise resampling. Resampling automatically reduces length and
%     that reduces the sr-length pieces sligthly. However, this can be
%     altered by:
%     '-l' : length conservation - reduced pieces are lenghtened to
%        reflect the original path lengths in the tree. But the total
%        tree size expands in the process (no good for automated
%        reconstruction procedure for example)
%     {DEFAULT: '-w'}
%
% Output
% ------
% if no output is declared the tree is changed in the trees structure
% - tree     ::tree: altered tree structure
%
% Example
% -------
% resample_tree (sample_tree, 5, '-s')
%
% See also insertp_tree, insert_tree, delete_tree, cat_tree, recon_tree
% Uses T_tree Pvec_tree insertp_tree morph_tree len_tree idpar_tree
% delete_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2015  Hermann Cuntz

function varargout = resample_tree (intree, sr, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function:
if ~isstruct (intree)
    tree     = trees{intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (sr)
    % {DEFAULT: 10 um spacing between the nodes}
    sr       = 10;
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: waitbar}
    options  = ''; 
end

if strfind   (options, '-s')
    clf;     hold on;
end

%%%%%%
% first attach a sr/2 um piece at each single terminal:
iT           = find (T_tree (tree)); % termination point indices
len          = len_tree (tree);      % length values of tree segments [um]
lenT         = len;
lenT (iT)    = len(iT) + 0.5 * sr;   % new length values, ready to morph
% (conserve options from resample_tree  but not show -> waitbar)
% - options2 is used again further below -
i1           = strfind (options, '-s');
options2     = options;
options2 (i1 : i1 + 1) = '';
if isempty   (options2)
    options2 = 'none';
end
% see "morph_tree", changes length values but preserves topology and
% angles:
tree         = morph_tree (tree, lenT, options2);

%%%%%%
% initialise coordinates of nodes and adjacency matrix
idpar        = idpar_tree (tree); % index to direct parent
Plen         = Pvec_tree  (tree); % path length from the root [um]
dA           = tree.dA;           % directed adjacency matrix of tree
N            = size (dA, 1);      % number of nodes in tree
mdA          = dA ^ 0;            % = eye (N, N) but twice as fast!
% these all will contain the new tree:
ndA          = dA;
nindy        = (1 : N)';
nX           = tree.X;
nY           = tree.Y;
nZ           = tree.Z;
nD           = tree.D;

if strfind       (options, '-w')  % waitbar option: initialisation
    if N > 499
        HW           = waitbar (0, 'insert points on all paths ...');
        set          (HW, 'Name', 'please wait...');
    end
end
% for each node look at point to add on the path:
for counter      = 1 : N
    if strfind   (options, '-w')       % waitbar option: update
        if mod (counter, 500) == 0,
            waitbar (counter / N, HW);
        end
    end
    ic           = find (mdA * dA (:, 1)); % children index
    mdA          = mdA * dA;               % walk through adjacency matrix
    ip           = idpar (ic);             % parent index
    for counterC = 1 : length (ic)
        Gpath    = (0 : sr : Plen (ic (counterC)));
        Gpath    = Gpath (Gpath > Plen (ip (counterC)));
        if ~isempty  (Gpath)
            lenG = length( Gpath);
            nN   = size (ndA, 1);
            ndA (ic (counterC), ip (counterC))     = 0;
            ndA  = [ndA sparse(nN, lenG)];
            ndA  = [ndA; [ ...
                (sparse  (lenG, nN)) ...
                (spdiags (ones (lenG, 1), -1, lenG, lenG))]];
            ndA (nN + 1, ip (counterC))      = 1;
            ndA (ic (counterC), nN + lenG)   = 1;
            rpos = ((Gpath - Plen (ip (counterC))) / ...
                (Plen (ic (counterC)) - Plen (ip (counterC))))';
            nX   = [nX; ...
                (nX (ip (counterC)) + ...
                rpos * (nX (ic (counterC)) - nX (ip (counterC))))];
            nY       = [nY; ...
                (nY (ip (counterC)) + ...
                rpos * (nY (ic (counterC)) - nY (ip (counterC))))];
            nZ       = [nZ; ...
                (nZ (ip (counterC)) + ...
                rpos * (nZ (ic (counterC)) - nZ (ip (counterC))))];
            nD       = [nD; ...
                (nD (ip (counterC)) + ...
                rpos * (nD (ic (counterC)) - nD (ip (counterC))))];
            nindy    = [nindy; ...
                (ones (lenG, 1) * ic (counterC))];
        end
    end
end
if strfind       (options, '-w') % waitbar option: close
    if N > 499
        close        (HW);
    end
end

% build the new tree
ntree            = [];
ntree.dA         = ndA;
ntree.X          = nX;
ntree.Y          = nY;
ntree.Z          = nZ;
if strfind       (options, '-d')
    ntree.D      = nD;
end

% expand vectors of form Nx1
S                = fieldnames (tree);
for counterS     = 1 : length (S)
    if      (...
            ~strcmp (S{counterS}, 'dA') && ...
            ~strcmp (S{counterS}, 'X')  && ...
            ~strcmp (S{counterS}, 'Y')  && ...
            ~strcmp (S{counterS}, 'Z'))
        if  ...
                (~isempty (strfind (options, '-d')) && ...
                strcmp (S{counterS}, 'D'))
        else
            vec  = tree.(S{counterS});
            if isvector (vec) && (numel (vec) == N) && ~(ischar (vec))
                ntree.(S{counterS})  = vec  (nindy);
            else
                ntree.(S{counterS})  = vec;
            end
        end
    end
end
tree             = delete_tree (ntree, 2 : N); % resampled tree

if isempty       (strfind (options, '-v'))
    % a bit complicated for collapsing multifurcations:
    iF           = [1; (N + 1 : size (ntree.dA))'];
    % collapse small angle branches:
    Bs           = find (sum (tree.dA) > 1)'; % multibranch point indices
    ipar_ntree   = ipar_tree (ntree); % all parent relationships of ntree
    len_ntree    = len_tree  (ntree); % length values of all segments
    collab       = {};
    for counter  = 1 : length (Bs)
        % here are the daughters of the branching point in the newly pruned
        % tree:
        idaughters   = find (tree.dA (:, Bs(counter)));
        % but we kept old tree ntree and can check
        LIPAR        = {};
        for counterD = 1 : length (idaughters)
            % beware of indices again:
            % points in original tree ntree from branching point to daughter:
            lipar    = ipar_ntree (iF (idaughters (counterD)), :);
            LIPAR{counterD} = ...
                lipar (1 : find (lipar == iF (Bs (counter))) - 1);
        end
        DIS          = [];
        for counterD1      =             1 : length (idaughters)
            for counterD2  = counterD1 + 1 : length (idaughters)
                DIS (end + 1, :) = [ ...
                    counterD1 counterD2 ...
                    (sum (len_ntree (unique ( ...
                    [LIPAR{counterD1} LIPAR{counterD2}]))) / (2 * sr))];
            end
        end
        for counterD       = 1 : size (DIS, 1)
            if DIS (counterD, 3) < 0.75
                collab{end+1} = idaughters (DIS (counterD, 1 : 2));
            end
        end
    end
    % collab now contains pairs of indices of nodes to collapse together
    child        = child_tree (tree);
    itodel       = cat (2, collab{:}); % to collapse
    % collapse the point with least amount of child nodes:
    [~, icollapse] = min (child (itodel));
    if ~isempty  (icollapse)
        % (3- icollapse is the other node in the pair)...
        for counter = 1:size (collab, 2)
            XM   = mean (tree.X (collab{counter}));
            YM   = mean (tree.Y (collab{counter}));
            ZM   = mean (tree.Z (collab{counter}));
            tree.X (collab{counter}) = XM;
            tree.Y (collab{counter}) = YM;
            tree.Z (collab{counter}) = ZM;
            tree.dA ( ... 
                logical (tree.dA (:, ...
                collab{counter} (icollapse (counter)))), ...
                collab{counter} (3 - icollapse (counter)))     = 1;
            tree.dA (:, collab{counter} (icollapse (counter))) = 0;
        end
        tree     = delete_tree (tree, ...
            itodel (sub2ind (size (itodel), ...
            icollapse, ...
            1 : length (icollapse))));
    end
end

if ~isempty  (strfind (options, '-l'))
    % now after deleting points on the way the length of an edge is not sr
    % anymore (because we cut the paths short), prolong all pieces to sr
    % via morphing:
    tree     = morph_tree (tree, ...
        sr * ones (length (tree.X), 1), options2);
end

if strfind   (options, '-s') % show option
    clf; hold on;
    HP       = plot_tree (intree, [], 20, [], 2, '-b');
    set      (HP, ...
        'facecolor',           'none', ...
        'linestyle',           '-', ...
        'edgecolor',           [0 0 0]);
    HP       = plot_tree (tree, [1 0 0], [], [], 2, '-b');
    set      (HP, ...
        'facecolor',           'none', ...
        'linestyle',           '-', ...
        'edgecolor',           [1 0 0]);
    HP (1)   = plot (1, 1, 'k-');
    HP (2)   = plot (1, 1, 'r-');
    set      (HP (2), ...
        'markersize',          48);
    legend   (HP, {'old tree', 'new tree'});
    set      (HP, ...
        'visible',             'off');
    title    ('resampling tree');
    xlabel   ('x [\mum]');
    ylabel   ('y [\mum]');
    zlabel   ('z [\mum]');
    view     (2);
    grid     on;
    axis     image;
end

if strfind   (options, '-e')
    display  ('resample_tree: added some nodes');
end

if (nargout > 0) || (isstruct (intree))
    varargout{1}   = tree;
else
    trees{intree}  = tree;
end








