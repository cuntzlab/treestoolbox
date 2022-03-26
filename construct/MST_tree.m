% MST_TREE   Minimum spanning tree based tree constructor.
% (trees package)
%
% [tree indx] = MST_tree (msttrees, X, Y, Z, bf, thr, mplen, DIST, options)
% -------------------------------------------------------------------------
%
% Creates trees corresponding to the minimum spanning tree keeping the path
% length to the root small (with balancing factor bf). A sparse distance
% matrix DIST between nodes is added to the cost function. Don't forget to
% include input tree nodes into the distance matrix DIST!
%
% For speed and memory considerations an area of close vicinity is drawn
% around each tree as it grows.
%
% Input
% -----
% - msttrees ::vector: indices to the starting points of trees
%     (# determines # of trees), or starting trees as cell array of tree
%     structures
%     {DEFAULT: additional node (0, 0, 0)}
% - X        ::vertical vector: X coords of pts to be connected
%     {DEFAULT: 1000 rand. pts}
% - Y        ::vertical vector: Y coords of pts to be connected
%     {DEFAULT: 1000 rand. pts}
% - Z        ::vertical vector: Z coords of pts to be connected
%     {DEFAULT: zeros}
% - bf       ::number between 0 1: balancing factor
%     {DEFAULT: 0.4}
% - thr      ::value: max distance that a connection can span
%     {DEFAULT: 50}
% - mplen    ::value: maximum path length in a tree
%     {DEFAULT: 10000}
%     (doesn't really work yet..)
% - DIST     ::sparse matrix BIGNxBIGN: zero indicates probably no
%     connection, numbers increasing probabilities of a connection.
%     {DEFAULT: sparse zeros matrix, with order of elements is first all
%     trees in order and then all open points}
% - options  ::string:
%     '-s'   : show plot (much much much slower)
%     '-w'   : with waitbar
%     '-t'   : time lapse save
%     '-b'   : suppress multifurcations
%     {DEFAULT '-w'}
%
% Output
% ------
% if no output is declared the trees are added in trees
% - tree     :: structured output trees, cell array if many
% - indx     :: index indicating where points ended up [itree inode]
%
% Example
% -------
% X            = rand (100, 1) * 100;
% Y            = rand (100, 1) * 100;
% Z            = zeros (100, 1);
% tree         = MST_tree (1, [50; X], [50; Y], [0; Z], ...
%                0.5, 50, [], [], '-s');
%
% See also rpoints_tree quaddiameter_tree BCT_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2022  Hermann Cuntz

function [tree, indx] = MST_tree (msttrees, X, Y, Z, bf, ...
    thr, mplen, DIST, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (msttrees)
    % starting tree is just point (0,0,0)
    msttrees           = {};
    msttrees{1}.X      = 0;
    msttrees{1}.Y      = 0;
    msttrees{1}.Z      = 0;
    msttrees{1}.dA     = sparse (0);
    msttrees{1}.D      = 1;
    msttrees{1}.R      = 1;
    msttrees{1}.rnames = {'tree'};
end

if (nargin < 2) || isempty(X)
    X        = rand  (1000, 1)        .* 400;
end

if (nargin < 3) || isempty (Y)
    Y        = rand  (size (X, 1), 1) .* 400;
end

if (nargin < 4) || isempty (Z)
    Z        = zeros (size (X, 1), 1);
end

if (nargin < 5) || isempty (bf)
    bf       = 0.4;
end

if (nargin < 6) || isempty (thr)
    thr      = 50;
end

if (nargin < 7) || isempty (mplen)
    mplen    = 10000;
end

if (nargin < 8) || isempty (DIST)
    DIST     = [];
else
    Derr     = max (max (DIST));
    DIST     = DIST / Derr;
end

if (nargin < 9) || isempty (options)
    % options  = '-w';
    options  = '';
end

if ~iscell       (msttrees)
    ID           = msttrees;
    msttrees     = cell (1, length (ID));
    for counter  = 1 : length (ID)
        msttrees{counter}.X  = X (ID (counter));
        msttrees{counter}.Y  = Y (ID (counter));
        msttrees{counter}.Z  = Z (ID (counter));
        msttrees{counter}.dA = sparse (0);
        msttrees{counter}.D  = 1;
        msttrees{counter}.R  = 1;
        msttrees{counter}.rnames = {'tree'};
    end
    X (ID)       = [];
    Y (ID)       = [];
    Z (ID)       = [];
end

lenX             = length (X);          % number of points
lent             = length (msttrees);   % number of trees

if ~isempty      (DIST)
    iDIST        = cell (lent, 1);
    iDISTP       = cell (lent, 1);
    TSUM         = 0;
    for counter  = 1 : lent
        % number of nodes in tree:
        N        = length (msttrees{counter}.X);
        % DIST index creation, which indicates which node in the tree
        % corresponds to which field in DIST:
        iDIST{counter}  = TSUM + 1 : TSUM + N;
        TSUM            = TSUM + N;
    end
end

if contains       (options, '-t')  % time lapse save
    timetrees    = cell (lent, 1);
    for countert = 1 : lent
        timetrees{countert}{1} = msttrees{countert};
    end
end

if contains       (options, '-s')  % prepare a plot if showing
    clf;
    % choose colors for the different trees:
    colors       = [ ...
        [1 0 0]; ...
        [0 1 0]; ...
        [0 0 1]; ...
        [0.2 0.2 0.2]; ...
        [1 0 1]; ...
        [1 1 0]; ...
        [0 1 1]];
    if lent      > 7
        colors   = [colors; (rand (lent - 7, 3))];
    end
    plot3        (X, Y, Z, 'k.');
    hold         on;
    HP           = cell (1, lent);
    for counter  = 1 : lent
        HP {counter} = plot_tree (msttrees{counter});
    end
    view         (2);
    grid         on;
    axis         image;
end

% initialisation:
N                = cell (lent, 1); % number of nodes in each tree
tthr             = cell (lent, 1); % vicinity threshold for each tree
root_dist        = cell (lent, 1); % distance from all open points to root
rdist            = cell (lent, 1);
irdist           = cell (lent, 1);
plen             = cell (lent, 1); % path length to the root in each tree
avic             = cell (lent, 1);
inX              = cell (lent, 1);
dplen            = cell (lent, 1);
ITREE            = cell (lent, 1);

for counter            = 1 : lent
    % number of nodes in tree:
    N{counter}         = length (msttrees{counter}.X);
    % initialization is a lot harder when starting tree is not empty:
    if N{counter}      > 1
        % starting path length to the root in the tree:
        plen{counter}  = Pvec_tree (msttrees{counter});
        % don't allow to go beyond a maximum path length:
        plen{counter} (plen{counter} > mplen) = NaN;
        % threshold distance determining the vicinity circle:
        eucl           = eucl_tree (msttrees{counter});
        tthr{counter}  = max (eucl) + thr;
        % calculate distance from all open points to root
        root_dist{counter} = sqrt ( ...
            (X - msttrees{counter}.X (1)).^2 + ...
            (Y - msttrees{counter}.Y (1)).^2 + ...
            (Z - msttrees{counter}.Z (1)).^2)';
        % calculate distance from all open points to any point on the tree:
        dis            = zeros (1, lenX);
        idis           = ones  (1, lenX);
        if strfind     (options, '-b') % avoid multifurcations
            % non-branch points:
            iCT        = find (sum (msttrees{counter}.dA, 1) < 2);
            % search only among non-branch-points:
            for counterX = 1 : lenX
                sdis   = sqrt ( ...
                    (X (counterX) - msttrees{counter}.X (iCT)).^2 + ...
                    (Y (counterX) - msttrees{counter}.Y (iCT)).^2 + ...
                    (Z (counterX) - msttrees{counter}.Z (iCT)).^2);
                % dis contains closest node on tree:
                [dis(counterX), idis(counterX)] = min (sdis);
            end
            idis       = iCT (idis); % retranslate index to all nodes
        else
            for counterX   = 1 : lenX
                sdis       = sqrt ( ...
                    (X (counterX) - msttrees{counter}.X).^2 + ...
                    (Y (counterX) - msttrees{counter}.Y).^2 + ...
                    (Z (counterX) - msttrees{counter}.Z).^2);
                % dis contains closest node on tree:
                [dis(counterX), idis(counterX)] = min (sdis);
            end
        end
        % don't allow to go beyond the threshold distance:
        dis (dis > thr)    = NaN;
        % sort points according to their distance to the tree:
        [rdist{counter}, irdist{counter}] = sort (dis);
        % set actual vicinity to all points in distance tthr of root
        avic{counter}  = sum (rdist{counter} < tthr{counter});
        if strfind     (options, '-s')
            plot3      ( ...
                X (irdist{counter}(1 : avic{counter})), ...
                Y (irdist{counter}(1 : avic{counter})), ...
                Z (irdist{counter}(1 : avic{counter})), 'g.');
        end
        % vector index in XYZ all points which are in vicinity but not yet
        % on tree:
        inX{counter}   = irdist{counter} (1 : avic{counter});
        if ~isempty    (DIST)
            % index of open points in distance matrix DIST:
            iDISTP{counter} = inX{counter} + TSUM;
            % initialise distance vector including path to root and extra
            % distance:
            dplen{counter} = ...
                rdist{counter} (1 : avic{counter}) + ...
                bf * plen{counter} (idis (inX{counter}))' + ...
                Derr * (1 - DIST ( ... % extra error term from DIST matrix
                iDIST{counter} (idis (inX{counter}))', ...
                iDISTP{counter}));
        else
            % initialise distance vector including path to root:
            dplen{counter} = ...
                rdist{counter} (1 : avic{counter}) + ...
                bf * plen{counter} (idis (inX{counter}))';
        end
        % initialise index vector indicating to which point on tree an open
        % point is closest to:
        ITREE{counter} = idis (inX{counter});
    else
        % starting path length to the root in the tree is just 0
        plen{counter}  =   0;
        % threshold distance determining the vicinity circle
        tthr{counter}  = thr;
        % calculate distance from all open points to root
        root_dist{counter} = sqrt ( ...
            (X - msttrees {counter}.X(1)).^2 +...
            (Y - msttrees {counter}.Y(1)).^2 + ...
            (Z - msttrees {counter}.Z(1)).^2)';
        % dis contains closest node on tree
        % this is simply the distance to root in this case:
        dis            = root_dist{counter};
        % don't allow to go beyond the threshold distance:
        dis (dis > thr) = NaN;
        % sort points according to their distance to the root:
        [rdist{counter}, irdist{counter}] = sort (root_dist{counter});
        % set actual vicinity to all points in distance tthr of root
        avic{counter}  = sum (rdist{counter} < tthr{counter});
        if strfind     (options, '-s')
            plot3      ( ...
                X (irdist{counter} (1 : avic{counter})), ...
                Y (irdist{counter} (1 : avic{counter})), ...
                Z (irdist{counter} (1 : avic{counter})), 'g.');
        end
        % vector index in XYZ all points which are in vicinity but not yet
        % on tree:
        inX{counter}   = irdist{counter} (1 : avic{counter});
        if ~isempty    (DIST)
            % index of open points in distance matrix DIST:
            iDISTP{counter} = inX{counter} + TSUM;
            % initialize distance vector including path to root and extra
            % distance:
            dplen{counter} = ...
                dis (inX{counter}) + ...
                Derr * (1 - DIST (iDIST{counter} (1), iDISTP{counter}));
        else
            % initialize distance vector including path to root
            dplen{counter} = dis (inX{counter});
        end
        % initialize index vector indicating to which point on tree an open
        % point is closest to: in the beginning all points are closest to
        % the root (#1):
        ITREE{counter} = ones (1, avic{counter});
    end
end

if strfind             (options, '-w')
    HW                 = waitbar (0, 'finding minimum spanning tree...');
    set                (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end

% find closest point one by one:
ncounter               = 0;
flag                   = 1;
indx                   = zeros (size (X, 1), 2);
while ~isempty (dplen) && (flag == 1)
    if strfind         (options, '-w')
        if mod         (ncounter, 500) == 0
            waitbar    (ncounter / lenX, HW);
        end
    end
    flag               = 0;
    % proceed iteratively one tree at a time:
    for counter        = 1 : lent 
        % choose closest point (iopen: index in Open points of vicinity):
        [idis, iopen]  = min (dplen{counter}, [], 2);
        % itree: index in tree:
        itree          = ITREE{counter} (iopen);
        % NaN means distance is bigger than threshold (see below):
        if ~isnan      (idis)
            % update vicinity distance:
            tthr{counter} = max ( ...
                tthr{counter}, ...
                thr + root_dist{counter} (inX{counter} (iopen)));
            % update adjacency matrix dA
            msttrees{counter}.dA (end + 1, itree)   = 1;
            msttrees{counter}.dA (itree,   end + 1) = 0;
            N{counter} = N{counter} + 1; % update number of nodes in tree
            % calculate the actual distance of the point to its closest
            % partner in the tree (itree)
            dis        = sqrt ( ...
                (X (inX{counter} (iopen)) - ...
                msttrees{counter}.X (itree)).^2 + ...
                (Y (inX{counter} (iopen)) - ...
                msttrees{counter}.Y (itree)).^2 + ...
                (Z (inX{counter} (iopen)) - ...
                msttrees{counter}.Z (itree)).^2);
            % don't allow to go beyond the threshold distance:
            dis (dis > thr) = NaN;
            % and add this to the path length of that point (itree) to get
            % the total path length to the new point:
            plen_new      = plen{counter} (itree) + dis;
            % don't allow to go beyond a maximum path length:
            plen_new (plen_new > mplen) = NaN;
            plen{counter} = [plen{counter}; plen_new];
            % update node coordinates in tree
            msttrees{counter}.X = [ ...
                msttrees{counter}.X; ...
                (X (inX{counter} (iopen)))];
            msttrees{counter}.Y = [ ...
                msttrees{counter}.Y; ...
                (Y (inX{counter} (iopen)))];
            msttrees{counter}.Z = [ ...
                msttrees{counter}.Z; ...
                (Z (inX{counter} (iopen)))];
            msttrees{counter}.D = [ ...
                msttrees{counter}.D; 1];
            msttrees{counter}.R = [ ...
                msttrees{counter}.R; 1];
            % remember which node came from where:
            indx (inX{counter} (iopen), :) = [ ...
                counter ...
                (length (msttrees{counter}.X))];
            % move node index of DIST matrix from open points to tree:
            if ~isempty  (DIST) 
                iDIST{counter} = [ ...
                    (iDIST{counter}) ...
                    (iDISTP{counter} (iopen))];
                iDISTP{counter} (iopen) = [];
            end
            % eliminate point in other trees:
            for counterM = [(1 : counter - 1) (counter + 1 : lent)]
                iiopen   = find (inX {counterM} == inX {counter} (iopen));
                dplen{counterM}  (iiopen)  = [];
                inX{counterM}    (iiopen)  = [];
                ITREE{counterM}  (iiopen)  = [];
                iiiopen  = ...
                    find (irdist{counterM} == inX{counter} (iopen));
                irdist{counterM} (iiiopen) = [];
                rdist{counterM}  (iiiopen) = [];
                if iiiopen <= avic{counterM}
                    avic{counterM} = avic{counterM} - 1;
                end
                if ~isempty (DIST)
                % get rid of indices in DIST of open nodes in all other
                % trees:                    
                    iDISTP{counterM} (iiopen) =[];
                end
            end
            % get rid of point in open points in vicinity
            dplen{counter} (iopen) = [];
            inX{counter}   (iopen) = [];
            ITREE{counter} (iopen) = [];
            % compare point to dplen to point which is now in the tree
            if ~isempty (dplen{counter}) % update in current vicinity
                dis    = (sqrt ( ...
                    (X (inX{counter}) - ...
                    msttrees{counter}.X (end)).^2 + ...
                    (Y (inX{counter}) - ...
                    msttrees{counter}.Y (end)).^2 + ...
                    (Z (inX{counter}) - ...
                    msttrees{counter}.Z (end)).^2));
                dis (dis > thr) = NaN;
                if ~isempty (DIST) % add DISTance matrix factor to Error
                    [dplen{counter}, idplen] = min ( ...
                        [dplen{counter}; ...
                        (dis + ...
                        bf * plen{counter} (end) + ...
                        Derr * (1 - ...
                        DIST (iDISTP{counter}, ...
                        iDIST{counter} (end))))'], ...
                        [], 1);
                else
                    [dplen{counter}, idplen] = min( ...
                        [dplen{counter}; ...
                        (dis + ...
                        bf * plen{counter} (end))'], [], 1);
                end
                % last added point:
                ITREE{counter} (idplen == 2) = N {counter};
                if strfind (options, '-b')
                    if sum (msttrees {counter}.dA (:, itree)) > 1
                        % non-branch points:
                        iCT = find (sum (msttrees {counter}.dA, 1) < 2);
                        inewbp = find (ITREE {counter} == itree);
                        if ~isempty (inewbp)
                            for tetete = 1 : length (inewbp)
                                dis = (sqrt ( ...
                                    (X (inX{counter} ...
                                    (inewbp (tetete))) - ...
                                    msttrees{counter}.X (iCT)).^2 + ...
                                    (Y (inX{counter} ...
                                    (inewbp (tetete))) - ...
                                    msttrees{counter}.Y (iCT)).^2 + ...
                                    (Z (inX{counter} ...
                                    (inewbp (tetete))) - ...
                                    msttrees{counter}.Z (iCT)).^2));
                                dis (dis > thr) = NaN;
                                if ~isempty (DIST)
                                    [d1, id1] = min ( ...
                                        dis + ...
                                        bf * plen {counter} (iCT) + ...
                                        Derr * (1 - ...
                                        DIST (iDISTP{counter} ...
                                        (inewbp (tetete)), ...
                                        iDIST{counter} (iCT)))', ...
                                        [], 1);
                                else
                                    [d1, id1] = min ( ...
                                        dis + ...
                                        bf * plen{counter} (iCT), ...
                                        [], 1);
                                end
                                dplen{counter} (inewbp (tetete)) = d1;
                                ITREE{counter} (inewbp (tetete)) = ...
                                    iCT (id1);
                            end
                        end
                    end
                end
            end
            % update vicinity:
            vic        = sum (rdist{counter} < tthr{counter});
            % update dplen etc... according to new vicinity:
            if vic     > avic{counter}
                % new points in vicinity:
                indo   = irdist{counter} (avic{counter} + 1 : vic);
                leno   = length (indo); % number of new points
                % repeat the old story with all new points:
                if strfind (options, '-b')
                    % non-branch points:
                    iCT = find (sum (msttrees{counter}.dA, 1) < 2);
                    dis = sqrt ( ...
                        (repmat (X (indo)',  length (iCT), 1) - ...
                        repmat (msttrees{counter}.X (iCT), 1, leno)).^2 + ...
                        (repmat (Y (indo)',  length (iCT), 1) - ...
                        repmat (msttrees{counter}.Y (iCT), 1, leno)).^2 + ...
                        (repmat (Z (indo)',  length (iCT), 1) - ...
                        repmat (msttrees{counter}.Z (iCT), 1, leno)).^2);
                    dis (dis > thr) = NaN;
                    if ~isempty (DIST)
                        [d1, id1] = min ( ...
                            dis + ...
                            bf * repmat (plen{counter} (iCT), 1, leno) + ...
                            Derr * (1 - DIST (sub2ind (size (DIST), ...
                            repmat (indo, length (iCT), 1), ...
                            repmat (iDIST{counter} (iCT), leno, 1)'))), ...
                            [], 1);
                    else
                        [d1, id1] = min ( ...
                            dis + ...
                            bf * repmat (plen{counter} (iCT), 1, leno), ...
                            [], 1);
                    end
                    id1 = iCT (id1);
                else
                    dis = sqrt ( ...
                        (repmat (X (indo)', N{counter}, 1) - ...
                        repmat  (msttrees{counter}.X, 1, leno)).^2 + ...
                        (repmat (Y (indo)', N{counter}, 1) - ...
                        repmat  (msttrees{counter}.Y, 1, leno)).^2 + ...
                        (repmat (Z (indo)', N{counter}, 1) - ...
                        repmat  (msttrees{counter}.Z, 1, leno)).^2);
                    dis (dis > thr) = NaN;
                    if ~isempty (DIST)
                        [d1, id1] = min ( ...
                            dis + ...
                            bf * repmat (plen{counter}, 1, leno) + ...
                            Derr * (1 - DIST (sub2ind (size (DIST), ...
                            repmat (indo, N{counter}, 1), ...
                            repmat (iDIST{counter}, leno, 1)'))), ...
                            [], 1);
                    else
                        [d1, id1] = min ( ...
                            dis + ...
                            bf * repmat (plen {counter}, 1, leno), ...
                            [], 1);
                    end
                end
                dplen{counter} = [dplen{counter}  d1];
                ITREE{counter} = [ITREE{counter} id1];
                inX{counter}   = [inX{counter}  indo];
                if ~isempty (DIST)
                    iDISTP{counter} = [iDISTP{counter} (indo + TSUM)];
                end
                if strfind (options, '-s')
                    plot3 (X (indo), Y (indo), Z (indo), 'g.');
                end
                avic{counter} = vic;
            end
            if strfind (options, '-s')
                set (HP{counter}, 'visible', 'off');
                HP{counter}  = ...
                    plot_tree (msttrees{counter}, colors (counter, :));
                drawnow;
            end
            if strfind (options, '-t')
                timetrees{counter}{end+1} = msttrees{counter};
            end
            % indicates that a point has been added in at least one tree:
            flag       = 1;
            ncounter   = ncounter + 1;
        end
    end
end
if strfind             (options, '-w')
    close              (HW);
end
if strfind             (options, '-t')
    msttrees           = timetrees;
end
if (nargout            > 0)
    if lent            == 1
        tree           = msttrees {1};
    else
        tree           = msttrees;
    end
else
    trees              = [trees msttrees];
end




