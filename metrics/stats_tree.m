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
% - intrees::tree, cell array of trees or cell array of cell array of trees
%     {DEFAULT: cell array of trees trees}
% - s::cell array of strings: names of the groups of cells. Must be
%     organized like intrees input.
% - name::string: file name with path if statistics should be saved as
%     ".sts" file
% - options::string: {DEFAULT: '-w -s -x'}
%     '-s'  : show results
%     '-w'  : waitbar
%     '-2d' : 2d tree, concerns hulls
%     '-x'  : no extras (much much less time consuming)
%     '-f'  : save as file
%
% Output
% -------
% - stats::structure: structure containing all statistics on sets of trees.
%
% Example
% -------
% stats_tree (sample_tree, [], [], '-s')
%
% See also
% Uses 
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function [stats tname tpath] = stats_tree (intrees, s, tname, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intrees),
    intrees = trees; % {DEFAULT trees: full trees cell array}
end;

% make intrees cell array convoluted to 2 depth:
if ~iscell (intrees)
    intrees = {{intrees}};
else
    if ~iscell (intrees {1})
        intrees = {intrees};
    end
end

lens = length (intrees);
if (nargin < 2)||isempty(s),
   s = num2str ((1 : lens)'); % {DEFAULT strings: call tree groups '1', '2', ...}
end

if (nargin < 4)||isempty(options),
    options = '-w -s -x'; % {DEFAULT: waitbar and show results}
end

if strfind(options,'-f') % save as file option
    if (nargin<3)||isempty(tname),
        [tname tpath] = uiputfile ('.sts','save trees statistics','trees.sts');
        if tname==0,
            tname = '';
            return
        end
    else
        tpath = '';
    end
end

gstats = struct([]); dstats = struct([]);

if isempty (strfind (options, '-x')),   % extras option
    % sholl plot prescan:
    maxlen = 0; % find longest euclidean distance to root among all trees
    for te = 1 : lens,
        for ward = 1 : length (intrees {te}),
            maxy = max (eucl_tree (intrees{te}{ward}));
            if maxlen < maxy, maxlen = maxy; end;
        end;
    end
    % this way we get a common ground for sholl
    dsholl = 0 : round (1.1 * 2 * max (maxlen));
end

if findstr (options, '-w'), % waitbar option: initialization
    HW = waitbar (0, 'extracting statistics tree by tree ...');
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end

for te = 1 : lens, % walk through tree groups
    if findstr (options, '-w'), % waitbar option: update
        waitbar (te ./ lens, HW);
    end
    lent = length (intrees {te}); % number of trees in this group
    
    % first initialize all parameter vectors:
    
    % feature distributions over:
    dstats(te).BO =     {};   % branching order
    dstats(te).Plen =   {};   % metric path length [um]
    dstats(te).peucl =  {};   % ratio between path length and euclidean distance
    dstats(te).angleB = {};   % angle at branch points [rad]
    dstats(te).blen =   {};   % branch lengths [um]

    % global features
    gstats(te).len =      zeros(lent,1);  % total length of tree [um]
    gstats(te).max_plen = zeros(lent,1);  % maximum metric path length [um]
    
    
    gstats(te).bpoints =  zeros(lent,1);  % number of branching points
    gstats(te).mpeucl =   zeros(lent,1);  % mean ratio of path length and euclidean distance
    gstats(te).maxbo =    zeros(lent,1);  % maximum branching order
    gstats(te).mangleB =  zeros(lent,1);  % mean angle at branch points [rad]
    gstats(te).mblen =    zeros(lent,1);  % mean branch lengths [um]
    gstats(te).mplen =    zeros(lent,1);  % mean path length (depends on node resolution) [um]
    gstats(te).mbo =      zeros(lent,1);  % mean branch order
    gstats(te).wh =       zeros(lent,1);  % height against width of spanning field
    gstats(te).wz =       zeros(lent,1);  % z-range against width of spanning field
    
    gstats(te).chullx =   zeros(lent,1);  % center of mass x
    gstats(te).chully =   zeros(lent,1);  % center of mass y
    gstats(te).chullz =   zeros(lent,1);  % center of mass z
        
    if isempty (strfind (options, '-x')),   % extras option
        dstats(te).sholl = {};  % sholl intersections
        dstats(te).asym =  {};  % asymmetry at branching points
        dstats(te).parea = {};  % area covered by one topological point
        
        gstats(te).hull =   zeros(lent,1);  % convex hull area (volume)

        gstats(te).uharea = zeros(lent,1);  %
        gstats(te).lharea = zeros(lent,1);
        
        gstats(te).masym =  zeros(lent,1);  % mean asymmetry at branch points
        gstats(te).mparea = zeros(lent,1);  % mean area of voronoi pieces
    end
    
    for ward = 1 : lent,
        len =  len_tree  (intrees{te}{ward});       % vector containing length values of tree segments [um]
        Plen = Pvec_tree (intrees{te}{ward}, len);  % path length from the root [um]
        BO =   BO_tree   (intrees{te}{ward});       % branch order of each node (# BPs on way to root)
        
        eucl = eucl_tree (intrees{te}{ward});       % euclidean distances of nodes to root [um]
        iBB =  B_tree    (intrees{te}{ward});       % vector containing 1 where branch point 0 else
        iBT =  T_tree    (intrees{te}{ward}) | iBB; % 1 branch or termination points 0 else

        dstats(te).BO{ward}    = BO   (iBT);        % branch order of topological points
        dstats(te).Plen{ward}  = Plen (iBT);        % metric path lengths of topological points
        warning('off','MATLAB:divideByZero');
        peucl                  = eucl (iBT) ./ Plen (iBT);
        warning('on','MATLAB:divideByZero');
        dstats(te).peucl{ward} = peucl;             % ratios between euclidean and metric path length
        % branching angles:
        dstats(te).angleB{ward} = angleB_tree  (intrees{te}{ward});
        % dissect trees into individual branches (for branch length
        % distribution):
        sect =                    dissect_tree (intrees{te}{ward});
        blen_d =                  diff (Plen(sect), [], 2);
        dstats(te).blen{ward} =   blen_d (blen_d > 0.2);
        
        if isempty (strfind (options, '-x')), % extras option
            % asymmetry:
            dstats(te).asym{ward}  = asym_tree  (intrees{te}{ward},...
                T_tree (intrees{te}{ward}));
            % sholl analysis:
            dstats(te).sholl{ward} = sholl_tree (intrees{te}{ward}, dsholl);
            
            % calculate convex hull area and put in "ahull"
            if strfind (options, '-2d'),
                [khull ahull] = convhull  ( intrees{te}{ward}.X, intrees{te}{ward}.Y);
            else
                [khull ahull] = convhulln ([intrees{te}{ward}.X, intrees{te}{ward}.Y, ...
                    intrees{te}{ward}.Z]);
            end
            gstats(te).hull(ward) = ahull;         % convex hull area (volume)
            
            % density calculation:
            if strfind (options, '-2d'),
                dhull          = hull_tree (intrees{te}{ward}, [], [], [], [], '-2d');
                [Xt Yt]        = cpoints(dhull); points = [Xt Yt];
                [HP VO KK vol] = vhull_tree (intrees{te}{ward}, [], points, ...
                    find (iBT), [], '-2d');
            else
                dhull = hull_tree(intrees{te}{ward},[],[],[],[],'none');
                points = dhull.vertices;
                [HP VO KK vol] = vhull_tree (intrees{te}{ward}, [], points, ...
                    find (iBT), [], 'none');
            end
            dstats(te).parea{ward} = vol;
        end
        
        gstats(te).len(ward) =      sum  (len);    % total length of tree [um]
        gstats(te).max_plen(ward) = max  (Plen);   % maximum metric path length [um]
        
        gstats(te).bpoints(ward) =  sum  (iBB);    % number of branching points
        % mean ratio of path length and euclidean distance
        % (nanmean(peucl) with statistics toolbox):
        gstats(te).mpeucl(ward) =   mean (peucl (~isnan (peucl)));
        % maximum branching order:
        gstats(te).maxbo(ward) =    max  (dstats(te).BO{ward});
        
        % mean angle at branch points [rad]:
        gstats(te).mangleB(ward) =  mean (dstats(te).angleB{ward}(~isnan (dstats(te).angleB{ward})));
        % mean branch lengths [um]:
        gstats(te).mblen(ward) =    mean (dstats(te).blen{ward});
        % mean path length (depends on node resolution) [um]:
        gstats(te).mplen(ward) =    mean (Plen);
        % mean branch order
        gstats(te).mbo(ward) =      mean (dstats(te).BO{ward});
        
        if isempty (strfind (options, '-x')), % extras option
            gstats(te).mparea(ward) = mean (dstats(te).parea{ward});
            [cx cy] = cpoints (dhull);
            cy_uh = cy; cy_uh(cy_uh < 0) = 0;
            cy_lh = cy; cy_lh(cy_lh > 0) = 0;
            gstats(te).uharea(ward) = polyarea (cx, cy_uh);
            gstats(te).lharea(ward) = polyarea (cx, cy_lh);
            
            % mean asymmetry at branch points:
            gstats(te).masym(ward)  = mean (dstats(te).asym{ward}(~isnan (dstats(te).asym{ward})));
        end
        
        gstats(te).chullx(ward) = mean (intrees{te}{ward}.X);
        gstats(te).chully(ward) = mean (intrees{te}{ward}.Y);
        gstats(te).chullz(ward) = mean (intrees{te}{ward}.Z);
        gstats(te).wh(ward) =     (max (intrees{te}{ward}.X) - min (intrees{te}{ward}.X)) ./  ...
            (max (intrees{te}{ward}.Y) - min (intrees{te}{ward}.Y));
        warning('off','MATLAB:divideByZero');
        if isinf (gstats(te).wh(ward)), gstats(te).wh(ward) = 0; end;
        gstats(te).wz(ward) = (max (intrees{te}{ward}.X) - min (intrees{te}{ward}.X)) ./ ...
            (max (intrees{te}{ward}.Z) - min (intrees{te}{ward}.Z));
        if isinf (gstats(te).wz(ward)), gstats(te).wz(ward) = 0; end;
        warning('on','MATLAB:divideByZero');
    end
end
if strfind (options, '-w'), % waitbar option: close
    close (HW);
end
stats.gstats = gstats;
stats.dstats = dstats;
stats.s      = s;
if exist ('dsholl', 'var'),
    stats.dsholl = dsholl;
end

if isempty (strfind (options, '-x')),
    stats.extras = 1; % flag indicating that extras have been calculated
end

if strfind (options, '-2d'),
    stats.dim    = 2; % indicate that hulls were calculated for 2D
else
    stats.dim    = 3; % indicate that hulls were calculated for 3D
end

if strfind (options, '-f'),
    if tname ~= 0,
        save ([tpath tname], 'stats');
    end
end

if strfind (options, '-s'), % show option, see "dstats_tree"
    dstats_tree (stats, [], '-d -c -g');
end