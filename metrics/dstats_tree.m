% DSTATS_TREE   Display tree statistics obtained by stats_tree.
% (trees package)
%
% HP = dstats_tree (stats, vcolor, options)
% -----------------------------------------
%
% Displays some statistics of trees. "stats" can be a structure obtained
% from stats_tree or can be read out from an ".sts" file.
%
% Inputs
% ------
% - stats    ::structure: structure containing all statistics
%     (see stats_tree). 
% - vcolor   ::numx3 vector: RGB values for each group
%     {DEFAULT: see below}
% - options  ::string:
%     '-g'   : global hull parameter display
%     '-d'   : branching distributions display
%     '-c'   : smooth output {kernel [0.2 0.2 0.2 0.2 0.2]}
%     {DEFAULT: '-d -g -c'}
%
% Output
% -------
% - HP       ::handles:
%
% Example
% -------
% dstats_tree  (stats_tree (sample_tree), [], '-g -d')
%
% See also stats_tree
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function dstats_tree (stats, vcolor, options)

if (nargin < 1) || isempty (stats)
    [tname, path] = uigetfile ( ...
        {'*.sts', 'TREES statistics format (*.sts)'}, ...
        'Pick a file', 'multiselect', 'off');
    if tname == 0
        return
    end
    data     = load ([path tname], '-mat');
    stats    = data.stats;
end

lens         = length (stats.gstats);

if (nargin < 2) || isempty (vcolor)
    vcolor   = [ ...
        [0 0 0]; ...
        [1 0 0]; ...
        [0 1 0]; ...
        [0 0 1]; ...
        (rand (lens - 4, 3))];
end

if (nargin < 3) || isempty (options)
    options  = '-d -g -c';
end

clf;
if contains (options, '-g')
    if contains (options, '-d')
        by                     = 2;
    else
        by                     = 1;
    end
    if (isfield  (stats, 'extras')) && (stats.extras == 1)
        lenoo                  = 7;
        bx                     = 7;
    else
        lenoo                  = 5;
        bx                     = 5;
    end
    % find correct ranges first:
    Rchullx                    = [ ...
        (min (cat (1, stats.gstats.chullx))) ...
        (max (cat (1, stats.gstats.chullx)))];
    Rchully                    = [ ...
        (min (cat (1, stats.gstats.chully))) ...
        (max (cat (1, stats.gstats.chully)))];
    Rchullz                    = [ ...
        (min (cat (1, stats.gstats.chullz))) ...
        (max (cat (1, stats.gstats.chullz)))];
    Rwh                        = [ ...
        (min (cat (1, stats.gstats.wh)) ) ...
        (max (cat (1, stats.gstats.wh)))];
    Rwz                        = [ ...
        (min (cat (1, stats.gstats.wz))) ...
        (max (cat (1, stats.gstats.wz)))];
    if diff (Rwz)              == 0
        Rwz (2)                = Rwz (2) + 1;
    end
    if diff (Rchullz)          == 0
        Rchullz (2)            = Rchullz (2) + 1;
    end
    for counter1               = 1 : lens
        for counter2           = 1 : lenoo
            subplot            (by, bx, counter2);
            hold               on;
            set                (gca, ...
                'fontsize',    12);
            switch             counter2
                case           1
                    y          = stats.gstats (counter1).chullx;
                    title      ('');
                    HT         = xlabel ('center of mass horiz.');
                    ylim       ( [0 1.1]);
                    lxax       = Rchullx;
                case           2
                    y          = stats.gstats (counter1).chully;
                    title      ('');
                    HT         = xlabel ('center of mass vert.');
                    ylim       ( [0 1.1]);
                    lxax       = Rchully;
                case           3
                    y          = stats.gstats (counter1).chullz;
                    title      ('');
                    HT         = xlabel ('center of mass z');
                    ylim       ( [0 1.1]);
                    lxax       = Rchullz;
                case           4
                    y          = stats.gstats (counter1).wh;
                    title      ('');
                    HT         = xlabel ('width vs. height');
                    ylim       ( [0 1.1]);
                    lxax       = Rwh; 
                case           5
                    y          = stats.gstats (counter1).wz;
                    title      ('');
                    HT         = xlabel ('width vs. z-range');
                    ylim       ( [0 1.1]);
                    lxax       = Rwz;    
                case           6
                    y          = ( ...
                        stats.gstats (counter1).uharea + ....
                        stats.gstats (counter1).lharea) / 1000000;
                    title      ('');
                    HT         = xlabel ('hull area [mm^2]');
                    ylim       ( [0 0.15]);
                    lxax       = [0 0.15];
                case           7
                    y          = ( ...
                        stats.gstats(counter1).uharea + ...
                        stats.gstats(counter1).lharea) ./ ...
                        stats.gstats(counter1).hull;
                    title      ('');
                    HT         = xlabel ('convexity index');
                    ylim       ( [0 1.75]);
                    lxax       = [0 1.75];
            end
            set                (HT, ...
                'fontsize',    12);
            HP                 = plot ( ...
                mean  (y), ...
                1.2 * (counter1 - 1), 's');
            set                (HP, ...
                'color',       vcolor (counter1, :), ...
                'markerfacecolor', vcolor (counter1, :));
            HL                 = line ( ...
                mean  (y) + [-std(y) std(y)], ...
                [1 1] * (1.2 * (counter1 - 1)));
            set                (HL, ...
                'linewidth',   2, ...
                'color',       vcolor (counter1, :));
            if diff (lxax)     == 0
                lxax           = sort ([0.9 1.1] .* lxax);
            end
            xlim               (lxax);
        end
    end
    for counter1               = 1 : lenoo
        subplot                (by, bx, (counter1 - 1) + 1);
        if counter1            == 1
            set                (gca, ...
                'ytick',       (0 : (lens - 1)) * 1.2, ...
                'yticklabel',  stats.s, ...
                'tickdir',     'out');
        else
            set                (gca, ...
                'ytick',       (0 : (lens - 1)) * 1.2, ...
                'yticklabel',  {}, ...
                'tickdir',     'out');
        end
        ylim                   ([-0.2 ((lens - 1) * 1.2 + 0.2)]);
    end
end

if contains               (options, '-d')
    if contains           (options, '-g')
        by                     = 2;
    else
        by                     = 1;
    end
    if isfield (stats, 'extras') && (stats.extras == 1)
        lenoo                  = 6;
        bx                     = 7;
    else
        lenoo                  = 5;
        bx                     = 5;
    end
    % find correct ranges first:
    maxPlen                    = 0;
    maxBO                      = 0;
    maxblen                    = 0;
    maxangleB                  = 0;
    maxparea                   = 0;
    for counter1               = 1 : lens
        for counter2           = 1 : length (stats.dstats (counter1).Plen)
            maxPlen            = max (maxPlen,   ...
                max (stats.dstats (counter1).Plen{counter2}));
            maxBO              = max (maxBO,     ...
                max (stats.dstats (counter1).BO{counter2}));
            maxblen            = max (maxblen,   ...
                max (stats.dstats (counter1).blen{counter2}));
            maxangleB          = max (maxangleB, ...
                max (stats.dstats (counter1).angleB{counter2}));
            if isfield  (stats.dstats (counter1), 'parea')
                maxparea       = max (maxparea,  ...
                    max (stats.dstats (counter1).parea{counter2}));
            end
        end
    end
    for counter1               = 1 : lens
        for counter2           = 1 : lenoo
            subplot            (by, bx, counter2 + bx * (by - 1));
            hold               on;
            set                (gca, ...
                'fontsize',    12)
            switch             counter2
                case           1
                    y          = stats.dstats (counter1).Plen;
                    ym         = stats.gstats (counter1).mplen;
                    lxax       = [0 (ceil (maxPlen / 10) * 10)];
                    title      ('');
                    HT         = xlabel ('path length [\mum]');
                case           2
                    y          = stats.dstats (counter1).peucl;
                    ym         = stats.gstats (counter1).mpeucl;
                    lxax       = [0 1.1];
                    title      ('');
                    HT         = xlabel ('direct vs. path ratio');
                case           3
                    y          = stats.dstats (counter1).BO;
                    ym         = stats.gstats (counter1).mbo;
                    lxax       = [0 (ceil (maxBO))];
                    title      ('');
                    HT         = xlabel ('branching order');
                case           4
                    y          = stats.dstats (counter1).blen;
                    ym         = stats.gstats (counter1).mblen;
                    lxax       = [0 (ceil (maxblen))];
                    title      ('');
                    HT         = xlabel ('branch length [\mum]');
                case           5
                    y          = stats.dstats (counter1).angleB;
                    ym         = stats.gstats (counter1).mangleB;
                    lxax       = [0 pi];
                    set        (gca, ...
                        'xtick',      [0 pi/2 pi], ...
                        'xticklabel', {'0', '90', '180'});
                    title      ('');
                    HT         = xlabel ('branching angle [°]');
                case           6
                    y          = stats.dstats (counter1).parea;
                    ym         = stats.gstats (counter1).mparea;
                    lxax       = [0 (ceil (maxparea * 10) / 10)];
                    title      ('');
                    HT         = xlabel ('density [\mum^2]');
            end
            set                (HT, ...
                'fontsize',    12);
            xax                = lxax (1) : diff (lxax) / 19 : lxax (2);
            if counter2        == 3
                xax            = 0 : ceil (maxBO);
            end
            for counter3       = 1 : length (y)
                yax            = histc (y{counter3}, xax)';
                yax            = yax ./ max (yax);
                if contains (options, '-c') % smoothing:
                    HP         = plot ( ...
                        xax, ...
                        1.2 * (counter1 - 1) + ...
                        convn (yax, ones (1, 5) / 5, 'same'), '-');
                else
                    HP         = plot ( ...
                        xax, ...
                        1.2 * (counter1 - 1) + ...
                        yax, '-');
                end
                set            (HP, ...
                    'color',   vcolor (counter1, :));
            end
            HP                 = plot ( ...
                mean (ym), ...
                1.2 * (counter1 - 1), 's');
            set                (HP, ...
                'color',           vcolor (counter1, :), ...
                'markerfacecolor', vcolor (counter1, :));
            HL                 = line ( ...
                mean (ym) + [(-std (ym)) (std (ym))], ...
                [1 1] * (1.2 * (counter1 - 1)));
            set                (HL, ...
                'linewidth',   2, ...
                'color',       vcolor (counter1, :));
            xlim               ([(min (xax)) (max (xax))]);
            ylim               ([-0.2 (lens * 1.2)]);
            if counter2        == 1
                set            (gca, ...
                    'ytick',      1.2 * (0 : lens - 1), ...
                    'yticklabel', stats.s, ...
                    'tickdir',    'out');
            else
                set            (gca, ...
                    'ytick',      1.2 * (0 : lens - 1), ...
                    'yticklabel', {},     ...
                    'tickdir',    'out');
            end
        end
        % sholl plot:
        if (isfield (stats, 'extras')) && (stats.extras == 1)
            subplot            (by, bx, lenoo + 1 + bx * (by - 1));
            hold               on;
            set                (gca, ...
                'fontsize',    12)
            title              ('');
            HT                 = xlabel ('Sholl intersections');
            set                (HT, ...
                'fontsize',    12);
            indy_dsholl        = ...
                1  : ...
                round  (max (stats.dsholl) / 20) : ...
                length (stats.dsholl);
            y                  = stats.dstats (counter1).sholl;
            for counter3       = 1 : length (y)
                yax            = y{counter3};
                yax            = yax ./ max (yax);
                if contains (options, '-c') % smoothing:
                    HP         = plot ( ...
                        stats.dsholl (indy_dsholl), ...
                        convn (yax (indy_dsholl), ones(1, 5) / 5, 'same') + ...
                        1.2 * (counter1 - 1), '-');
                else
                    HP         = plot ( ...
                        stats.dsholl (indy_dsholl), ...
                        yax (indy_dsholl) + ...
                        1.2 * (counter1 - 1), '-');
                end
                set            (HP, ...
                    'color',   vcolor (counter1, :));
            end
            xlim               ([0 (max (stats.dsholl))]);
            ylim               ([-0.2 (lens * 1.2)]);
            set                (gca, ...
                'ytick',       1.2 * (0 : lens - 1), ...
                'yticklabel',  {}, ...
                'tickdir',     'out');
        end
    end
end


