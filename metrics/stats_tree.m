% STATS_TREE   Collects tree statistics using TREES toolbox functions.
% (trees package)
%
% [stats name path] = stats_tree (intrees, s, name, options)
% ----------------------------------------------------------
%
% collects typical statistics on trees. A graphical output is controlled by
% dstats_tree. Input trees can be organized as:
% .single tree
% .one    group  of trees: {tree1, tree2,... treen}
% .many   groups of trees: {{treei1,...,treein},{treej1,...,treejm},...}
%
% Input
% -----
% - intrees  ::tree, cell array of trees OR
%     cell array of cell array of trees
%     {DEFAULT: cell array of trees trees}
% - s        ::cell array of strings: names of the groups of cells. Must be
%     organized like intrees input.
% - name     ::string: file name with path if statistics should be saved as
%     ".sts" file
% - options::string:
%     '-s'  : show results
%     '-w'  : waitbar
%     '-2d' : 2d tree, concerns hulls
%     '-x'  : no extras (much much less time consuming)
%     '-f'  : save as file
%     {DEFAULT: '-w -s -x'}
%
% Output
% -------
% - stats    ::structure: structure containing all statistics on sets of
%     trees.
%
% Example
% -------
% stats_tree   (sample_tree, [], [], '-s')
%
% See also dstats_tree
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [stats, tname, tpath] = stats_tree (intrees, s, tname, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intrees)
    % {DEFAULT trees: full trees cell array}
    intrees  = trees;
end;

% make intrees cell array convoluted to 2 depth:
if ~iscell   (intrees)
    intrees  = {{intrees}};
else
    if ~iscell   (intrees{1})
        intrees  = {intrees};
    end
end

lens = length (intrees);
if (nargin < 2) || isempty (s)
    % {DEFAULT strings: call tree groups '1', '2', ...}
    s        = num2str ((1 : lens)');
end

if (nargin < 4) || isempty (options)
    % {DEFAULT: waitbar and show results}
    options  = '-w -s -x';
end

if strfind (options, '-f') % save as file option
    if (nargin < 3) || isempty (tname)
        [tname, tpath] = uiputfile ( ...
            '.sts', ...
            'save trees statistics', ...
            'trees.sts');
        if tname     == 0
            tname    = '';
            return
        end
    else
        tpath        = '';
    end
end


gstats           = struct ([]);
dstats           = struct ([]);

if isempty       (strfind (options, '-x'))   % extras option
    % sholl plot prescan:
    % first find longest euclidean distance to root among all trees:
    maxlen       = 0;
    for counter1     = 1 : lens
        for counter2 = 1 : length (intrees{counter1})
            maxy     = max (eucl_tree (intrees{counter1}{counter2}));
            if maxlen    < maxy
                maxlen   = maxy;
            end
        end
    end
    % this way we get a common ground for sholl
    dsholl       = 0 : round (1.1 * 2 * max (maxlen));
end

if strfind       (options, '-w') % waitbar option: initialization
    HW           = waitbar (0, ...
        'extracting statistics tree by tree ...');
    set          (HW, ...
        'Name',                '..PLEASE..WAIT..YEAH..');
end

for counter1                     = 1 : lens % walk through tree groups
    if strfind                   (options, '-w') % waitbar option: update
        waitbar                  (counter1 ./ lens, HW);
    end
    % number of trees in this group:
    lent                         = length (intrees {counter1});
    
    % first initialize all parameter vectors:
    
    % %%%%% feature distributions over:
    % branching order:
    dstats (counter1).BO         = {};
    % metric path length [um]:
    dstats (counter1).Plen       = {};
    % ratio between path length and euclidean distance:
    dstats (counter1).peucl      = {};
    % angle at branch points [rad]:
    dstats (counter1).angleB     = {};
    % branch lengths [um]:
    dstats (counter1).blen       = {};
    
    % %%%%% global features:
    % total length of tree [um]:
    gstats (counter1).len        = zeros (lent, 1);
    % maximum metric path length [um]:
    gstats (counter1).max_plen   = zeros (lent, 1);
    % number of branching points:
    gstats (counter1).bpoints    = zeros (lent, 1);
    % mean ratio of path length and euclidean distance:
    gstats (counter1).mpeucl     = zeros (lent, 1);
    % maximum branching order:
    gstats (counter1).maxbo      = zeros (lent, 1);
    % mean angle at branch points [rad]:
    gstats (counter1).mangleB    = zeros (lent, 1);
    % mean branch lengths [um]:
    gstats (counter1).mblen      = zeros (lent, 1);
    % mean path length (depends on node resolution) [um]:
    gstats (counter1).mplen      = zeros (lent, 1);
    % mean branch order:
    gstats (counter1).mbo        = zeros (lent, 1);
    % height against width of spanning field:
    gstats (counter1).wh         = zeros (lent, 1);
    % z-range against width of spanning field:
    gstats (counter1).wz         = zeros (lent, 1);
    % center of mass x:
    gstats (counter1).chullx     = zeros (lent, 1);
    % center of mass y:
    gstats (counter1).chully     = zeros (lent, 1);
    % center of mass z:
    gstats (counter1).chullz     = zeros (lent, 1);
    
    if isempty (strfind (options, '-x'))   % extras option
        % sholl intersections:
        dstats (counter1).sholl  = {};
        % asymmetry at branching points:
        dstats (counter1).asym   = {};
        % area covered by one topological point:
        dstats (counter1).parea  = {};
        % convex hull areas (volumes):
        gstats (counter1).hull   = zeros (lent, 1);
        gstats (counter1).uharea = zeros (lent, 1);
        gstats (counter1).lharea = zeros (lent, 1);
        % mean asymmetry at branch points:
        gstats (counter1).masym  = zeros (lent, 1);
        % mean area of voronoi pieces:
        gstats (counter1).mparea = zeros (lent, 1);
    end
    
    for counter2                 = 1 : lent
        % vector containing length values of tree segments [um]:
        len                      = len_tree     ( ...
            intrees{counter1}{counter2});
        % path length from the root [um]:
        Plen                     = Pvec_tree    ( ...
            intrees{counter1}{counter2}, len);
        % branch order of each node (# BPs on way to root):
        BO                       = BO_tree      ( ...
            intrees{counter1}{counter2});
        % euclidean distances of nodes to root [um]:
        eucl                     = eucl_tree    ( ...
            intrees{counter1}{counter2});
        % vector containing 1 where branch point 0 else:
        iBB                      = B_tree       ( ...
            intrees{counter1}{counter2});
        % 1 branch or termination points 0 else:
        iBT                      = T_tree       ( ...
            intrees{counter1}{counter2}) | iBB;
        peucl                    = eucl (iBT) ./ Plen (iBT);
        % divide tree in sections:
        sect                     = dissect_tree ( ...
            intrees{counter1}{counter2});
        % branch lengths:
        blen_d                   = diff (Plen (sect), [], 2);
        % branch order of topological points:
        dstats (counter1).BO{counter2}     = BO   (iBT);
        % metric path lengths of topological points:
        dstats (counter1).Plen{counter2}   = Plen (iBT);
        % ratios between euclidean and metric path length:
        dstats (counter1).peucl{counter2}  = peucl;
        % branching angles:
        dstats (counter1).angleB{counter2} = angleB_tree ( ...
            intrees{counter1}{counter2});
        % dissect trees into individual branches (for branch length
        % distribution):
        dstats (counter1).blen{counter2}   = blen_d (blen_d > 0.2);
        
        if isempty (strfind (options, '-x')) % extras option
            % asymmetry:
            dstats (counter1).asym{counter2}   = asym_tree  ( ...
                intrees{counter1}{counter2}, ...
                T_tree (intrees{counter1}{counter2}));
            % sholl analysis:
            dstats (counter1).sholl{counter2}  = sholl_tree ( ...
                intrees{counter1}{counter2}, ...
                dsholl);
            
            % calculate convex hull area and put in "ahull"
            if strfind (options, '-2d')
                [~, ahull]                     = convhull  (  ...
                    intrees{counter1}{counter2}.X, ...
                    intrees{counter1}{counter2}.Y);
            else
                [~, ahull]                     = convhulln ([ ...
                    intrees{counter1}{counter2}.X, ...
                    intrees{counter1}{counter2}.Y, ...
                    intrees{counter1}{counter2}.Z]);
            end
            % convex hull area (volume):
            gstats (counter1).hull (counter2)  = ahull;
            
            % density calculation:
            if strfind (options, '-2d')
                dhull                          = hull_tree  ( ...
                    intrees{counter1}{counter2}, [], [], [], [], '-2d');
                [Xt, Yt]                       = cpoints (dhull);
                points                         = [Xt Yt];
                [~, ~, ~, vol]                 = vhull_tree ( ...
                    intrees{counter1}{counter2}, [], points, ...
                    find (iBT), [], '-2d');
            else
                dhull                          = hull_tree  ( ....
                    intrees{counter1}{counter2},[],[],[],[],'none');
                points                         = dhull.vertices;
                [~, ~, ~, vol]                 = vhull_tree ( ...
                    intrees{counter1}{counter2}, [], points, ...
                    find (iBT), [], 'none');
            end
            dstats (counter1).parea{counter2}  = vol;
        end
        % total length of tree [um]:
        gstats (counter1).len      (counter2)  = sum  (len);
        % maximum metric path length [um]:
        gstats (counter1).max_plen (counter2)  = max  (Plen);
        % number of branching points:
        gstats (counter1).bpoints  (counter2)  = sum  (iBB);
        % mean ratio of path length and euclidean distance
        % (nanmean(peucl) with statistics toolbox):
        gstats (counter1).mpeucl   (counter2)  = mean ( ...
            peucl (~isnan (peucl)));
        % maximum branching order:
        gstats (counter1).maxbo    (counter2)  = max  ( ...
            dstats (counter1).BO{counter2});
        % mean angle at branch points [rad]:
        gstats (counter1).mangleB  (counter2)  = mean ( ...
            dstats (counter1).angleB{counter2} ( ...
            ~isnan (dstats (counter1).angleB{counter2})));
        % mean branch lengths [um]:
        gstats (counter1).mblen    (counter2)  = mean ( ...
            dstats (counter1).blen{counter2});
        % mean path length (depends on node resolution) [um]:
        gstats (counter1).mplen    (counter2)  = mean (Plen);
        % mean branch order
        gstats (counter1).mbo      (counter2)  = mean ( ...
            dstats (counter1).BO{counter2});
        if isempty (strfind (options, '-x')), % extras option
            gstats (counter1).mparea (counter2)  = mean ( ...
                dstats (counter1).parea{counter2});
            [cx, cy]                             = cpoints (dhull);
            cy_uh                                = cy;
            cy_uh (cy_uh < 0)                    = 0;
            cy_lh                                = cy;
            cy_lh (cy_lh > 0)                    = 0;
            gstats (counter1).uharea (counter2)  = polyarea (cx, cy_uh);
            gstats (counter1).lharea (counter2)  = polyarea (cx, cy_lh);
            % mean asymmetry at branch points:
            gstats (counter1).masym  (counter2)  = mean ( ...
                dstats (counter1).asym{counter2} ( ...
                ~isnan (dstats (counter1).asym{counter2})));
        end
        gstats (counter1).chullx (counter2)      = mean ( ...
            intrees{counter1}{counter2}.X);
        gstats (counter1).chully (counter2)      = mean ( ...
            intrees{counter1}{counter2}.Y);
        gstats (counter1).chullz (counter2)      = mean ( ...
            intrees{counter1}{counter2}.Z);
        gstats (counter1).wh     (counter2)      =  ( ...
            max (intrees{counter1}{counter2}.X) - ...
            min (intrees{counter1}{counter2}.X)) ./ ( ...
            max (intrees{counter1}{counter2}.Y) - ...
            min (intrees{counter1}{counter2}.Y));
        if isinf (gstats (counter1).wh (counter2))
            gstats (counter1).wh (counter2)      = 0;
        end
        gstats (counter1).wz (counter2)          = ( ...
            max (intrees{counter1}{counter2}.X) - ...
            min (intrees{counter1}{counter2}.X)) ./ (...
            max (intrees{counter1}{counter2}.Z) - ...
            min (intrees{counter1}{counter2}.Z));
        if isinf (gstats (counter1).wz (counter2))
            gstats (counter1).wz (counter2)      = 0;
        end
    end
end
if strfind       (options, '-w') % waitbar option: close
    close        (HW);
end
stats.gstats     = gstats;
stats.dstats     = dstats;
stats.s          = s;
if exist         ('dsholl', 'var'),
    stats.dsholl = dsholl;
end

if isempty       (strfind (options, '-x'))
    % flag indicating that extras have been calculated:
    stats.extras = 1;
end

if strfind       (options, '-2d')
    % indicate that hulls were calculated for 2D:
    stats.dim    = 2;
else
    % indicate that hulls were calculated for 3D:
    stats.dim    = 3;
end

if strfind       (options, '-f')
    if tname     ~= 0
        save     ([tpath tname], 'stats');
    end
end

if strfind       (options, '-s') % show option, see "dstats_tree"
    dstats_tree  (stats, [], '-d -c -g');
end


