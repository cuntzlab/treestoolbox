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
% - stats    ::structure: structure containing all statistics (see stats_tree).
% - vcolor   ::numx3 vector: RGB values for each group {DEFAULT: see below}
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
% Copyright (C) 2009 - 2016  Hermann Cuntz

function dstats_tree (stats, vcolor, options)

if (nargin < 1)||isempty(stats)
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
    vcolor = [   ...
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
if strfind (options, '-g')
    if strfind (options, '-d')
        by = 2;
    else
        by = 1;
    end
    if isfield (stats, 'extras') && (stats.extras == 1)
        lenoo = 7;
        bx = 7;
    else
        lenoo = 5;
        bx = 5;
    end
    % find correct ranges first:
    Rchullx = [min(cat (1, stats.gstats.chullx)) max(cat (1, stats.gstats.chullx))];
    Rchully = [min(cat (1, stats.gstats.chully)) max(cat (1, stats.gstats.chully))];
    Rchullz = [min(cat (1, stats.gstats.chullz)) max(cat (1, stats.gstats.chullz))];
    Rwh =     [min(cat (1, stats.gstats.wh))     max(cat (1, stats.gstats.wh))];
    Rwz =     [min(cat (1, stats.gstats.wz))     max(cat (1, stats.gstats.wz))];
    if diff (Rwz) == 0,     Rwz(2) =     Rwz(2) + 1;     end;
    if diff (Rchullz) == 0, Rchullz(2) = Rchullz(2) + 1; end;
    for te = 1 : lens,
        for tissimo = 1 : lenoo,
            subplot (by, bx, tissimo); hold on; set (gca, 'fontsize', 12);
            switch tissimo,
                case 1
                    y = stats.gstats(te).chullx;
                    title (''); HT = xlabel ('center of mass horiz.');
                    ylim ([0 1.1]);  lxax = Rchullx;
                case 2
                    y = stats.gstats(te).chully;
                    title (''); HT = xlabel ('center of mass vert.');
                    ylim ([0 1.1]);  lxax = Rchully;
                case 3
                    y = stats.gstats(te).chullz;
                    title (''); HT = xlabel ('center of mass z');
                    ylim ([0 1.1]);  lxax = Rchullz;
                case 4
                    y = stats.gstats(te).wh;
                    title (''); HT = xlabel ('width vs. height');
                    ylim ([0 1.1]);  lxax = Rwh; 
                case 5
                    y = stats.gstats(te).wz;
                    title (''); HT = xlabel ('width vs. z-range');
                    ylim ([0 1.1]);  lxax = Rwz;    
                case 6
                    y = (stats.gstats(te).uharea + stats.gstats(te).lharea) / 1000000;
                    title (''); HT = xlabel('hull area [mm^2]');
                    ylim ([0 0.15]); lxax = [0 0.15];
                case 7
                    y = (stats.gstats(te).uharea + stats.gstats(te).lharea) ./ stats.gstats(te).hull;
                    title (''); HT = xlabel ('convexity index');
                    ylim ([0 1.75]); lxax = [0 1.75];
            end
            set (HT, 'fontsize', 12);
            HP = plot (mean (y), 1.2 * (te - 1), 's');
            set (HP, 'color', vcolor (te, :),'markerfacecolor', vcolor (te, :));
            HL = line (mean (y) + [-std(y) std(y)], [1 1] * (1.2 * (te - 1)));
            set (HL, 'linewidth', 2, 'color', vcolor (te, :));
            if diff (lxax) == 0, lxax = sort ([.9 1.1].*lxax); end;
            xlim (lxax);
        end
    end
    for te = 1 : lenoo,
        subplot (by, bx, (te - 1) + 1);
        if te == 1,
            set (gca, 'ytick', (0 : (lens - 1))*1.2, 'yticklabel', stats.s,'tickdir','out');
        else
            set (gca, 'ytick', (0 : (lens - 1))*1.2, 'yticklabel', {},     'tickdir','out');
        end
        ylim([-0.2 (lens - 1)*1.2+0.2]);
    end
end

if strfind (options, '-d'),
    if strfind (options, '-g'),
        by = 2;
    else
        by = 1;
    end
    if isfield (stats, 'extras') && (stats.extras == 1),
        lenoo = 6; bx = 7;
    else
        lenoo = 5; bx = 5;
    end
    % find correct ranges first:
    maxPlen = 0; maxBO = 0; maxblen = 0; maxangleB = 0; maxparea = 0;
    for te = 1 : lens,
        for ward = 1 : length (stats.dstats(te).Plen),
            maxPlen      = max (maxPlen,   max (stats.dstats(te).Plen   {ward}));
            maxBO        = max (maxBO,     max (stats.dstats(te).BO     {ward}));
            maxblen      = max (maxblen,   max (stats.dstats(te).blen   {ward}));
            maxangleB    = max (maxangleB, max (stats.dstats(te).angleB {ward}));
            if isfield (stats.dstats(te), 'parea'),
                maxparea = max (maxparea,  max (stats.dstats(te).parea  {ward}))
            end
        end
    end
    for te = 1 : lens,
        for tissimo = 1 : lenoo,
            subplot (by ,bx, tissimo + bx * (by - 1)); hold on; set (gca, 'fontsize', 12)
            switch tissimo,
                case 1
                    y = stats.dstats(te).Plen;   ym = stats.gstats(te).mplen;
                    lxax = [0 ceil(maxPlen / 10)*10];
                    title (''); HT = xlabel ('path length [\mum]');
                case 2
                    y = stats.dstats(te).peucl;  ym = stats.gstats(te).mpeucl;
                    lxax = [0 1.1];
                    title (''); HT = xlabel ('direct vs. path ratio');
                case 3
                    y = stats.dstats(te).BO;     ym = stats.gstats(te).mbo;
                    lxax = [0 ceil(maxBO)];
                    title (''); HT = xlabel ('branching order');
                case 4
                    y = stats.dstats(te).blen;   ym = stats.gstats(te).mblen;
                    lxax = [0 ceil(maxblen)];
                    title (''); HT = xlabel ('branch length [\mum]');
                case 5
                    y = stats.dstats(te).angleB; ym = stats.gstats(te).mangleB;
                    lxax = [0 pi];
                    set (gca, 'xtick', [0 pi/2 pi], 'xticklabel', {'0', '90', '180'});
                    title (''); HT = xlabel ('branching angle [°]');
                case 6
                    y = stats.dstats(te).parea;  ym = stats.gstats(te).mparea;
                    lxax = [0 ceil(maxparea * 10)/10];
                    title (''); HT = xlabel ('density [\mum^2]');
            end
            set (HT, 'fontsize', 12);
            xax = lxax (1) : diff (lxax) / 19 : lxax (2);
            if tissimo == 3,
                xax = 0 : ceil (maxBO);
            end
            for ward = 1 : length (y),
                yax = histc (y{ward}, xax)'; yax = yax ./ max (yax);
                if strfind (options, '-c'), % smoothing:
                    HP = plot (xax, 1.2 * (te - 1) + convn (yax, ones (1, 5) / 5, 'same'), '-');
                else
                    HP = plot (xax, 1.2 * (te - 1) + yax, '-');
                end
                set (HP, 'color', vcolor (te, :));
            end
            HP = plot (mean (ym),   1.2 * (te - 1), 's');
            set (HP, 'color', vcolor (te, :), 'markerfacecolor', vcolor (te, :));
            HL = line (mean (ym) + [-std(ym) std(ym)], [1 1] * (1.2 * (te - 1)));
            set (HL, 'linewidth', 2, 'color', vcolor (te, :));
            xlim ([min(xax) max(xax)]); ylim([-0.2 lens*1.2]);
            if tissimo == 1,
                set (gca, 'ytick', 1.2 * (0 : lens - 1), 'yticklabel', stats.s, 'tickdir', 'out');
            else
                set (gca, 'ytick', 1.2 * (0 : lens - 1), 'yticklabel', {},      'tickdir', 'out');
            end
        end
        % sholl plot:
        if isfield (stats, 'extras') && (stats.extras == 1),
            subplot (by, bx, lenoo + 1 + bx * (by - 1)); hold on; set (gca, 'fontsize', 12)
            title (''); HT = xlabel ('Sholl intersections'); set (HT, 'fontsize', 12);
            indy_dsholl = 1  : round (max (stats.dsholl) / 20) : length (stats.dsholl);
            y = stats.dstats(te).sholl;
            for ward = 1 : length (y),
                yax = y {ward}; yax = yax ./ max (yax);
                if strfind (options, '-c'), % smoothing:
                    HP = plot (stats.dsholl (indy_dsholl), ...
                        convn (yax (indy_dsholl), ones(1, 5) / 5, 'same')    + 1.2 * (te - 1), '-');
                else
                    HP = plot (stats.dsholl (indy_dsholl), yax (indy_dsholl) + 1.2 * (te - 1), '-');
                end
                set (HP, 'color', vcolor (te, :));
            end
            xlim([0 max(stats.dsholl)]); ylim([-0.2 lens*1.2]);
            set (gca, 'ytick', 1.2 * (0 : lens - 1), 'yticklabel', {}, 'tickdir', 'out');
        end
    end
end