% GROWTH_TREE   Space-filling minimum spanning tree based tree constructor.
% (trees package)
%
% [tree, tL, tT, target_indx, tree_indx] = growth_tree(span, start, thr, bf, sp, 
%                           k, alpha, j, max_radius, n_target_points, options)
% -------------------------------------------------------------------------
%
% Creates trees by minimizing both spanning tree costs (along with path length
% to the root) and adjustably maximizing the space-filling-ness of the growth
% 
% For speed and memory considerations an area of close vicinity is drawn
% around each tree as it grows.
%
% Input
% -----
% - span     ::integer: used to obtain space in which to grow the tree - can
%     be a spanning hull, a structured tree, or a target points (see options -P
%     and -d)
% - start    ::tree: initial tree or root coordinates, by default [0 0 0]
%     or root of tree in span
% - thr      ::integer: termination condition for growth - can be the number of
%     iterations (ie target points to add), total cable length (see option -L),
%     or the number of termination points (see option -T)
%     {DEFAULT 100 iterations}
% - bf       ::number between 0 1: balancing factor
%     {DEFAULT: 0.5}
% - sp       ::number between 0 1: space filling factor
%     {DEFAULT: 0.5}
% - k        ::number between 0 1: stochasticity in growth
%     {DEFAULT: 0} 
% - alpha    ::value: convexity/tightness of the boundary around intree
%     {DEFAULT: 0.5}
% - j        ::cell array: pairs of jitter values, see jitter_tree
%     {DEFAULT: {}}
% - max_radius   ::value: max distance that a connection can span
%     {DEFAULT: 10000}
% - n_target_points   ::integer: around new tree growths from which
%      target points are eliminated
%     {DEFAULT: 100000}
% - options  ::string:
%     '-L'   : thr becomes a length threshold in [um]
%     '-T'   : thr becomes a threshold number in termination points
%     '-P'   : c is interpreted as available target points
%     '-s'   : show plot (much much much slower)
%     {DEFAULT ''}
%
% Output
% ------
% if no output is declared the trees are added in trees
% - tree     :: structured output trees, cell array if many
%
% Example
% -------
% X            = rand(100, 1) * 100;
% Y            = rand(100, 1) * 100;
% Z            = zeros(100, 1);
% tree         = MST_tree(1, [50; X], [50; Y], [0; Z], ...
%                0.5, 50, [], [], '-s');
%
% See also rpoints_tree quaddiameter_tree BCT_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz

function [mtree, tL, tT, target_indx, tree_indx] = growth_tree(varargin)

    %=============================== Parsing inputs ===============================%
    p = inputParser;
    p.addParameter('span', [])
    p.addParameter('start', [])
    p.addParameter('thr', 100)
    p.addParameter('bf', 0.5)
    p.addParameter('sp', 0.5)
    p.addParameter('k', 0)
    p.addParameter('alpha', 0.5)
    p.addParameter('j', {})
    p.addParameter('max_radius', 10000)
    p.addParameter('n_target_points', 1e6)
    p.addParameter('L', false)
    p.addParameter('T', false)
    p.addParameter('d', false)
    p.addParameter('P', false)
    p.addParameter('b', false)
    p.addParameter('w', false)
    p.addParameter('s', false)
    pars = parseArgs(p, varargin, {'span', 'start', 'thr', 'bf', 'sp', 'k', 'alpha', 'j', 'max_radius', 'n_target_points'}, {'L', 'T', 'd', 'P', 'b', 'w', 's'});
    %==============================================================================%
    
    span = pars.span;
    start = pars.start;
    thr = pars.thr;
    bf = pars.bf;
    sp = pars.sp;
    k = pars.k;
    alpha = pars.alpha;
    j = pars.j;
    max_radius = pars.max_radius;
    n_target_points = pars.n_target_points;
    
    if pars.P
    % fix empty Z bug
        X = span(:, 1);
        Y = span(:, 2);
        if size(span, 2) < 3
            Z = zeros(length(span), 1);
        else
            Z = span(:, 3);
        end
    else
        if isstruct(span) % obtain boundary from tree
            % ver_tree(span); % verify that input is a tree structure
            tree = span;
            ibound = boundary(tree.X, tree.Y, tree.Z, alpha);
            fv = struct('vertices', [tree.X, tree.Y, tree.Z], 'faces', ibound);
        else
            fv = span;
        end
        [X, Y, Z] = mc3d(fv, n_target_points);
    end
    
    % getting starting point from parameter start: 
    % * if it's a tree structure, extract its root and use it as the start
    % * if it's empty, create a root at 0
    % * if it's a list of coordinates, use as root and empty the tree
    if (nargin < 2) || isempty(start)
        if exist('tree', 'var')
            root = [tree.X(1) tree.Y(1) tree.Z(1)];
            start = [];
        else
            root = [0 0 0];
            start = [];
        end
    elseif length(start) == 3
        root = start;
        start = [];
    elseif length(start) == 2
        root = [start 0];
        start = [];
    end
    
    % setting the threshold value if no threshold value is givem
    % * if a tree is given as a boundary, the threshold value would be:
    %   - its total length (if w/ -L)
    %   - its number of termination points (if w/-T)
    % * else it defaults to 100 (see above)
    if (nargin < 3) || isempty(thr)
        if exist('tree', 'var')
            if ~isempty(tree)
                if pars.L
                    thr = sum(len_tree(tree));
                else
                    thr = sum(T_tree(tree));
                end
            end
        end
    end
    
    if pars.s  % prepare a plot if showing
        clf;
        plot3(X, Y, Z, 'k.');
        hold on;
        if ~isempty(start)
            plot_tree(start);
        end
        view(2);
        grid on;
        axis image;
    end

    % parameter tranformations:
    
    % sigmoid transform the sp value:
    sig_limit = .0005;
    if sp < sig_limit
        sp =  sig_limit;
    elseif sp > 1-sig_limit
        sp = 1-sig_limit;
    end
    sp = max(min(log(sp./(1-sp))/log((1-sig_limit)./sig_limit)/1.75+.475, 1), 0);

    % tan transform k to linearize the effect of stochasticity
    k = tanh(k * 4);

    % initialization:
    
    % if the total number of target points that will be connected to is known (via
    % the threshold not being the length or number of termination points of the
    % final tree), initialize the variables to the right size.
    if pars.L || pars.T
        tL = [];
        tT = [];
        tree_indx = [];
        target_indx = [];
        mtree = cell(1, 1);
    else
        tL = zeros(thr, 1);
        tT = zeros(thr, 1);
        tree_indx = zeros(thr, 1);
        target_indx = zeros(thr, 1);
        mtree = cell(1, thr);
    end
    
    % initialization is a lot harder when starting tree is not empty:
    if ~isempty(start)
        mtree{1} = start;
        
        % number of nodes in the tree:
        N = length(mtree{1}.X);
        % starting path length to the root in the tree:
        plen = Pvec_tree(mtree{1});
        % radius distance determining the vicinity circle:
        eucl = eucl_tree(mtree{1});
        tradius = max(eucl) + max_radius;
        % calculate distance from all open points to root
        root_dist = sqrt((X - mtree{1}.X(1)).^2 + (Y - mtree{1}.Y(1)).^2 + (Z - mtree{1}.Z(1)).^2)';
        % get pairwise distances between tree nodes and open points
        [dis, idis] = min(pdist2([mtree{1}.X mtree{1}.Y mtree{1}.Z], [X Y Z]));
        % don't allow to go beyond the radius distance:
        dis(dis > max_radius) = NaN;
        % sort points according to their distance to the tree:
        [rdist, irdist] = sort(dis);
        % get the number of points in the vicinity
        avic  = sum(rdist < tradius);
        if pars.s
            plot3(X(irdist(1:avic)), Y(irdist(1:avic)), Z(irdist(1:avic)), 'g.');
        end
        % vector index in XYZ all points which are in vicinity but not yet
        % on tree:
        inX = irdist(1:avic);
        % initialise distance vector including path to root:
        dplen = rdist(1:avic) + bf * plen(idis(inX))';
        % initialise index vector indicating to which point on tree an open
        % point is closest to:
        ITREE = idis(inX);
    else % the tree is empty
        % initialize the tree itself
        mtree{1}.X  = root(1);
        mtree{1}.Y  = root(2);
        mtree{1}.Z  = root(3);
        mtree{1}.dA = sparse(0);
        mtree{1}.D  = 1;
        mtree{1}.R  = 1;
        mtree{1}.rnames = {'tree'};
    
        N = length(mtree{1}.X);
    
        % starting path length to the root in the tree is just 0
        plen = 0;
        % radius distance determining the vicinity circle
        tradius = max_radius;
        % calculate distance from all open points to root
        root_dist = sqrt((X - mtree{1}.X(1)).^2 + (Y - mtree{1}.Y(1)).^2 + (Z - mtree{1}.Z(1)).^2)';
        % dis contains closest node on tree©
        % this is simply the distance to root in this case:
        dis = root_dist;
        % don't allow to go beyond the radius distance:
        dis(dis > max_radius) = NaN;
        % sort points according to their distance to the root:
        [rdist, irdist] = sort(root_dist);
        % set actual vicinity to all points in distance tradius of root
        avic = sum(rdist < tradius);
        if pars.s
            plot3(X(irdist(1:avic)), Y(irdist(1:avic)), Z(irdist(1:avic)), 'g.');
        end
        % indices of available nodes sorted by distance from the root
        inX = irdist(1:avic);
    
        % initialize distance vector including path to root
        dplen = dis(inX);
        % initialize index vector indicating to which point on tree an open
        % point is closest to: in the beginning all points are closest to
        % the root (#1):
        ITREE = ones(1, avic);
    end
    
    tL(1) = sum(len_tree(mtree{1}));
    tT(1) = sum(T_tree(mtree{1}));
    
    % find closest point one by one:
    icontinue = 1;
    counter = 1;
    xtree = mtree{counter};
    
    while icontinue
        % choose closest point (iopen: index in open points of vicinity): 
        if sp > sig_limit
            % get the overall distance from each target node to the tree: get the minimum distance from every target point to every tree node
            node_tree_dist = min(pdist2([xtree.X xtree.Y xtree.Z], [X(inX) Y(inX) Z(inX)]), [], 1);
            [~, iopen] = min((1 - k) * ((1 - sp) * dplen/max(dplen) - sp * node_tree_dist/max(node_tree_dist)) + k * rand(size(dplen)), [], 2);
        else
            [~, iopen] = min((1 - k) * dplen/max(dplen) + k * rand(size(dplen)), [], 2);
        end
        
        % connecting iopen and itree
        if ~isempty(dplen)
            % itree: index in tree
            itree = ITREE(iopen);
            % update vicinity distance:
            tradius = max(tradius, max_radius + root_dist(inX(iopen)));
    
            % get the distance between the chosen target node and the chosen tree node
            dis = sqrt((X(inX(iopen)) - xtree.X(itree)).^2 + (Y(inX(iopen)) - xtree.Y(itree)).^2 + (Z(inX(iopen)) - xtree.Z(itree)).^2);
            % don't allow to go beyond the radius distance:
            dis(dis > max_radius) = NaN;
    
            n_new_nodes = max(round(dis), 1);
            
            % get node coordinates
            x1 = xtree.X(itree);
            y1 = xtree.Y(itree);
            z1 = xtree.Z(itree);

            x2 = X(inX(iopen));
            y2 = Y(inX(iopen));
            z2 = Z(inX(iopen));
            
            % create resampled chosen_path between nodes
            dx = x2 - x1;
            dy = y2 - y1;
            dz = z2 - z1;
            ndx = dx/(sqrt(dx.^2 + dy.^2 + dz.^2));
            ndy = dy/(sqrt(dx.^2 + dy.^2 + dz.^2));
            ndz = dz/(sqrt(dx.^2 + dy.^2 + dz.^2));
            new_X = x1 + (ndx .* (1:n_new_nodes)');
            new_Y = y1 + (ndy .* (1:n_new_nodes)');
            new_Z = z1 + (ndz .* (1:n_new_nodes)');
            
            % add jitter
            R0 = zeros(numel(new_X), 3);
            for counter2 = 1:length(j)
                stde = j{counter2}(1);
                lambda = j{counter2}(2);
                RJ = randn(numel(new_X), 3) * stde * lambda;
                G = gauss(-lambda:lambda, 0, lambda/5)';
                RJ = convn(RJ, G, 'same');
                RJ = RJ - repmat(RJ(1, :), size(RJ, 1), 1);
                R0 = R0 + RJ;
            end

            % add nodes to the tree
            xtree.X = [xtree.X; new_X + R0(:, 1)];
            xtree.Y = [xtree.Y; new_Y + R0(:, 2)];
            xtree.Z = [xtree.Z; new_Z + R0(:, 3)];
            xtree.D = [xtree.D; repelem(1, n_new_nodes, 1)];
            xtree.R = [xtree.R; repelem(1, n_new_nodes, 1)];
            
            % update adjacency matrix dA
            xtree.dA(end + 1, itree) = 1;
            xtree.dA(itree, end + 1) = 0;
            if n_new_nodes > 1
                latest_node = length(xtree.dA);
                xtree.dA(latest_node:(latest_node + n_new_nodes - 2), (latest_node + 1):(latest_node + n_new_nodes - 1)) = 0;
                xtree.dA((latest_node + 1):(latest_node + n_new_nodes-1), latest_node:(latest_node + n_new_nodes - 2)) = eye(n_new_nodes-1, n_new_nodes-1);
            end
            % update number of nodes in tree
            N = N + n_new_nodes;
            
            % update path lengths
            nlen = sqrt(sum(diff([x1 y1 z1; [new_X new_Y new_Z] + R0]).^2,2));
            plen = [plen; plen(itree)+cumsum(nlen)];
    
            counter = counter + 1;
            tL(counter) = sum(len_tree(xtree));
            tT(counter) = sum(T_tree(xtree));
            tree_indx(counter) = itree;
            target_indx(counter) = inX(iopen);
            mtree{counter} = xtree;
            
            % check termination conditions
            if pars.L && tL(counter) >= thr
                % disp('Exit 1: reached the desired length')
                icontinue = 0;
            elseif pars.T && tT(counter) >= thr
                % disp('Exit 2: reached the desired number of termination points')
                icontinue = 0;
            elseif ~pars.L && ~pars.T && counter >= thr
                % disp('Exit 3: reached the desired number of iterations')
                icontinue = 0;
            end
            
            % if termination conditions aren't met
            if icontinue                    
                % get rid of point in open points in vicinity
                dplen(iopen) = [];
                inX(iopen) = [];
                ITREE(iopen) = [];
    
                % compare point to dplen to point which is now in the tree
                if ~isempty(dplen) % update in current vicinity                    
                    dis = (sqrt ((X(inX) - xtree.X(end-n_new_nodes:end)').^2 + (Y(inX) - xtree.Y(end-n_new_nodes:end)').^2 + (Z(inX) - xtree.Z(end-n_new_nodes:end)').^2));
                    dis (dis > max_radius) = NaN;
                    [dplen, idplen] = min([dplen; (dis + bf * plen(end-n_new_nodes:end)')'], [], 1);
                    % last added point:
                    new_nodes = N - n_new_nodes:N;
                    ITREE(idplen > 1) = new_nodes(idplen(idplen>1)-1);
                end
                % update vicinity:
                % vicinity can be increased with the addition of new target points
                % to the tree. this section updates it and looks for/adds target
                % points that now fall within the enlarged vicinity
                vic = sum(rdist < tradius);
                % update dplen etc... according to new vicinity:
                if vic > avic
                    % new points in vicinity:
                    indo = irdist(avic + 1:vic);
                    leno = length(indo); % number of new points
                    % repeat the old story with all new points:
    
                    dis = sqrt((repmat(X(indo)', N, 1) - repmat(xtree.X, 1, leno)).^2 + (repmat(Y(indo)', N, 1) - repmat(xtree.Y, 1, leno)).^2 + (repmat(Z(indo)', N, 1) - repmat(xtree.Z, 1, leno)).^2);
                    dis(dis > max_radius) = NaN;
                    [d1, id1] = min(dis + bf * repmat(plen, 1, leno), [], 1);
    
                    dplen = [dplen  d1];
                    ITREE = [ITREE id1];
                    inX = [inX  indo];
                    if pars.s
                        plot3(X(indo), Y(indo), Z(indo), 'g.');
                    end
                    avic = vic;
                end
    
                if pars.s
                    plot_tree(xtree);
                    drawnow;
                end
            end
        else
            icontinue = 0;
        end
    end
    tL = tL(1:counter);
    tT = tT(1:counter);
    mtree = mtree(1:counter);
end

function [pX, pY, pZ] = mc3d(fv, NN)
    rangeX = range (fv.vertices (:, 1));
    rangeY = range (fv.vertices (:, 2));
    rangeZ = range (fv.vertices (:, 3));
    centerX = min   (fv.vertices (:, 1)) + rangeX / 2;
    centerY = min   (fv.vertices (:, 2)) + rangeY / 2;
    centerZ = min   (fv.vertices (:, 3)) + rangeZ / 2;
    ranger = round (max ([rangeX rangeY rangeZ]) * 1.1);
    pX = centerX + (rand (NN, 1) - 0.5) * ranger;
    pY = centerY + (rand (NN, 1) - 0.5) * ranger;
    pZ = centerZ + (rand (NN, 1) - 0.5) * ranger;
    inside = inpolyhedron (fv, [pX, pY, pZ]);%,'FLIPNORMALS',1);
    inside = find (inside);
    pX = pX (inside);
    pY = pY (inside);
    pZ = pZ (inside);
end

