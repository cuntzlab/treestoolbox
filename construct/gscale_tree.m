% GSCALE_TREE   Scales trees from a set of trees to mean tree size.
% (trees package)
%
% [spanning ctrees] = gscale_tree (intrees, options)
% --------------------------------------------------
%
% Extracts region by region features from a group of trees intrees which
% are sufficient to constrain the artificial generation of trees similar to
% the original group. Is based on the assumption that the density of
% topological points on the trees are more or less scalable. The result is
% a structure spanning with some info about the spanning fields of the
% individual regions throughout the trees. ctrees contains the scaled
% trees.
%
% Input
% -----
% - intrees  ::integer:  index of tree in trees or structured tree or
%     cell-array of trees.
% - options  ::string:
%     '-s' : show plot
%     '-w' : with waitbar
%     {DEFAULT '-w'}
%
% Output
% ------
% - spanning ::structure:  containing scaling info about spanning fields
%     ordered by region
% - trees    ::cell array: of scaled trees as trees structures.
%
% Example
% -------
% dLPTCs     = load_tree ('dLPTCs.mtr');
% % scaling of HSE dendrites:
% [spanning, ctrees] = gscale_tree (dLPTCs{1})
%
% See also clone_tree
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [spanning, ctrees] = gscale_tree (intrees, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intrees)
    % {DEFAULT tree: last tree in trees cell array}
    intrees  = length (trees);
end

if (nargin < 2) || isempty (options)
    options  = '-w';
end

for counterT = 1 : length (intrees)
    intrees {counterT} = tran_tree (intrees{counterT});
end

% structure containing info about scaling of trees and all the points:
spanning         = [];
% in the array of input trees look for common region names
spanning.regions = intrees{1}.rnames;
for counterT     = 2 : length (intrees)
    spanning.regions = [spanning.regions intrees{counterT}.rnames];
end
spanning.regions = unique (spanning.regions);
lenr             = length (spanning.regions);
% establish the spanning volume of the different regions for all trees
spanning.xlims   = cell   (1, lenr);
spanning.ylims   = cell   (1, lenr);
spanning.zlims   = cell   (1, lenr);
spanning.xmass   = cell   (1, lenr);
spanning.ymass   = cell   (1, lenr);
spanning.zmass   = cell   (1, lenr);
spanning.iR      = cell   (1,    1);
spanning.nBT     = cell   (1,    1);
dR               = zeros  (1, lenr); % empty region flag
if strfind       (options, '-w') % waitbar option: initialization
    HW           = waitbar (0, ...
        'scanning spanning fields region by region...');
    set          (HW, ...
        'Name',                '..PLEASE..WAIT..YEAH..');
end
for counterR     = 1 : length (spanning.regions);
    if strfind   (options, '-w') % waitbar option: update
        waitbar  (counterR / length (spanning.regions), HW);
    end
    flag         = 0;
    for counterT  = 1 : length (intrees)
        iR0      = find (strcmp ( ...
            intrees{counterT}.rnames, ...
            spanning.regions{counterR}));
        if ~isempty  (iR0)
            % read out index values for each region in each cell:
            spanning.iR{counterR}{counterT} = ...
                find (intrees{counterT}.R == iR0);
            BT   = ~C_tree (intrees{counterT});
            iBT  = logical (BT (spanning.iR{counterR}{counterT}));
            % branch and termination points in that region
            iRBT = spanning.iR{counterR}{counterT}(iBT);
            spanning.nBT{counterR}{counterT} = length (iRBT);
            if ~isempty (spanning.iR{counterR}{counterT})
                % if nodes exist in that region in that cell readout x y z
                % limits:
                spanning.xlims {counterR} = [   ...
                    spanning.xlims{counterR}; [ ...
                    (min (intrees{counterT}.X ( ...
                    spanning.iR{counterR}{counterT}))) ...
                    (max (intrees{counterT}.X ( ...
                    spanning.iR{counterR}{counterT})))]];
                spanning.ylims {counterR} = [ ...
                    spanning.ylims{counterR}; [...
                    (min (intrees{counterT}.Y ( ...
                    spanning.iR{counterR}{counterT}))) ...
                    (max (intrees{counterT}.Y ( ...
                    spanning.iR{counterR}{counterT})))]];
                spanning.zlims {counterR} = [   ...
                    spanning.zlims{counterR}; [ ...
                    (min (intrees{counterT}.Z ( ...
                    spanning.iR{counterR}{counterT}))) ...
                    (max (intrees{counterT}.Z ( ...
                    spanning.iR{counterR}{counterT})))]];
                % now readout the center of mass:
                spanning.xmass {counterR} = [ ...
                    spanning.xmass{counterR}; ...
                    (mean (intrees{counterT}.X (iRBT)))];
                spanning.ymass {counterR} = [ ...
                    spanning.ymass{counterR}; ...
                    (mean (intrees{counterT}.Y (iRBT)))];
                spanning.zmass {counterR} = [ ...
                    spanning.zmass{counterR}; ...
                    (mean (intrees{counterT}.Z (iRBT)))];
                % indicate that nodes were found in that region at least in
                % one cell:
                flag   = 1;
            else
                spanning.xlims{counterR} = [ ...
                    spanning.xlims{counterR}; ...
                    [NaN NaN]];
                spanning.ylims{counterR} = [ ...
                    spanning.ylims{counterR}; ...
                     [NaN NaN]];
                spanning.zlims{counterR} = [ ...
                    spanning.zlims{counterR}; ...
                     [NaN NaN]];
                spanning.xmass{counterR} = [ ...
                    spanning.xmass{counterR}; ...
                      NaN];
                spanning.ymass{counterR} = [ ...
                    spanning.ymass{counterR}; ...
                      NaN];
                spanning.zmass{counterR} = [ ...
                    spanning.zmass{counterR}; ...
                      NaN];
            end
        else
            spanning.xlims{counterR} = [ ...
                    spanning.xlims{counterR}; ...
                     [NaN NaN]];
            spanning.ylims{counterR} = [ ...
                    spanning.ylims{counterR}; ...
                     [NaN NaN]];
            spanning.zlims{counterR} = [ ...
                    spanning.zlims{counterR}; ...
                     [NaN NaN]];
            spanning.xmass{counterR} = [ ...
                    spanning.xmass{counterR}; ...
                      NaN];
            spanning.ymass{counterR} = [ ...
                    spanning.ymass{counterR}; ...
                      NaN];
            spanning.zmass{counterR} = [ ...
                    spanning.zmass{counterR}; ...
                      NaN];
            spanning.iR{counterR}{counterT} = [];
        end
    end
    % if flag is not set then the region is fully empty and we can delete
    % it (see below):
    if ~flag
        dR (counterR) = 1;
    end
end

% create sample tapering in trees to determine region-wise tapering
% parameters:
qtrees           = cell (1, 1);
for counterT     = 1 : length (intrees)
    if strfind   (options, '-w') % waitbar option: update
        waitbar  (counterT / length (intrees), HW);
    end
    qtrees{counterT} = quaddiameter_tree (intrees {counterT});
end

% measure wriggliness amplitude independently of region
% (can be expanded):
spanning.wriggles = zeros (length (intrees), 2);
for counterT     = 1 : length (intrees)
    if strfind   (options, '-w'), % waitbar option: update
        waitbar  (counterT / length (intrees), HW);
    end
    tree         = intrees{counterT};
    ampl         = 2 * ( ...
        sum (len_tree (tree)) ./ ...
        sum (len_tree (delete_tree (tree, find (C_tree (tree))))) - 1);
    lambda       = 5;
    spanning.wriggles (counterT, :) = [ampl lambda];
end

% delete emptyregions:
emptyregion      = find (dR);
for counterR         = 1 : length (emptyregion)
    spanning.regions (emptyregion (counterR)) = [];
    spanning.xlims   (emptyregion (counterR)) = [];
    spanning.ylims   (emptyregion (counterR)) = [];
    spanning.zlims   (emptyregion (counterR)) = [];
    spanning.xmass   (emptyregion (counterR)) = [];
    spanning.ymass   (emptyregion (counterR)) = [];
    spanning.zmass   (emptyregion (counterR)) = [];
    spanning.iR      (emptyregion (counterR)) = [];
    spanning.nBT     (emptyregion (counterR)) = [];
end
lenr             = length (spanning.regions);

spanning.mxdiff      = zeros (lenr, 1);
spanning.stdxdiff    = zeros (lenr, 1);
spanning.mydiff      = zeros (lenr, 1);
spanning.stdydiff    = zeros (lenr, 1);
spanning.mzdiff      = zeros (lenr, 1);
spanning.stdzdiff    = zeros (lenr, 1);
for counterR             = 1 : lenr
    % readout mean and standard deviation of spanning hull limits:
    isy              = ~isnan ( ...
        spanning.xlims{counterR} (:, 1));
    spanning.mxdiff  (counterR) = ...
        mean (diff (spanning.xlims{counterR} (isy, :), [], 2));
    if spanning.mxdiff  (counterR) == 0,
        spanning.mxdiff (counterR) = 1;
    end
    spanning.stdxdiff   (counterR) = ...
        std  (diff (spanning.xlims{counterR} (isy, :), [], 2));
    spanning.mydiff     (counterR) = ...
        mean (diff (spanning.ylims{counterR} (isy, :), [], 2));
    if spanning.mydiff  (counterR) == 0,
        spanning.mydiff (counterR) = 1;
    end
    spanning.stdydiff   (counterR) = ...
        std  (diff (spanning.ylims{counterR} (isy, :), [], 2));
    spanning.mzdiff     (counterR) = ...
        mean (diff (spanning.zlims{counterR} (isy, :), [], 2));
    if spanning.mzdiff  (counterR) == 0,
        spanning.mzdiff (counterR) = 1;
    end
    spanning.stdzdiff  (counterR) = ...
        std  (diff (spanning.zlims{counterR} (isy, :), [], 2));
end
ctrees           = intrees;
spanning.X       = cell (1, 1);
spanning.Y       = cell (1, 1);
spanning.Z       = cell (1, 1);
spanning.qdiam   = cell (1, 1);
for counterR     = 1 : length (spanning.regions);
    if strfind   (options, '-w') % waitbar option: update
        waitbar  (counterR / length (spanning.regions), HW);
    end
    spanning.qdiam{counterR} = [];
    for counterT = 1 : size (spanning.xlims {counterR}, 1),
        BT       = ~C_tree (intrees{counterT});
        iBT      = logical (BT (spanning.iR{counterR}{counterT}));
        % branch and termination points in that region
        iRBT     = spanning.iR{counterR}{counterT} (iBT);
        Xpre     = intrees{counterT}.X (iRBT);
        Ypre     = intrees{counterT}.Y (iRBT);
        Zpre     = intrees{counterT}.Z (iRBT);
        % scale X Y Z coordinates with mean limits and collect for all
        % cells:
        if diff (spanning.xlims{counterR} (counterT, :)) ~= 0
            spanning.X{counterR}{counterT} = ...
                spanning.xmass{counterR} (counterT) + ...
                spanning.mxdiff (counterR) * ...
                (Xpre - spanning.xmass {counterR} (counterT))' / ...
                diff   (spanning.xlims {counterR} (counterT, :));
            ctrees{counterT}.X (spanning.iR{counterR}{counterT}) = ...
                spanning.mxdiff (counterR) * ...
                ctrees{counterT}.X (spanning.iR{counterR}{counterT})' / ...
                diff  (spanning.xlims{counterR} (counterT, :));
        else
            spanning.X{counterR}{counterT} = Xpre';
        end
        if diff (spanning.ylims{counterR} (counterT, :)) ~= 0
            spanning.Y{counterR}{counterT} = ...
                spanning.ymass{counterR} (counterT) + ...
                spanning.mydiff (counterR) * ...
                (Ypre - spanning.ymass{counterR} (counterT))' / ...
                diff   (spanning.ylims{counterR} (counterT, :));
            ctrees{counterT}.Y (spanning.iR{counterR}{counterT}) = ...
                spanning.mydiff (counterR) * ...
                ctrees{counterT}.Y (spanning.iR{counterR}{counterT})' / ...
                diff  (spanning.ylims{counterR} (counterT, :));
        else
            spanning.Y{counterR}{counterT} = Ypre';
        end
        if diff (spanning.zlims{counterR} (counterT, :)) ~= 0
            spanning.Z{counterR}{counterT} = ...
                spanning.zmass{counterR} (counterT) + ...
                spanning.mzdiff (counterR) * ...
                (Zpre - spanning.zmass{counterR} (counterT))' / ...
                diff   (spanning.zlims{counterR} (counterT, :));
            ctrees{counterT}.Z (spanning.iR{counterR}{counterT}) = ...
                spanning.mzdiff (counterR) * ...
                ctrees{counterT}.Z (spanning.iR{counterR}{counterT})' / ...
                diff  (spanning.zlims{counterR} (counterT, :));
        else
            spanning.Z{counterR}{counterT} = Zpre';
        end
        % determine region-wise tapering:
        if ~isempty (spanning.iR{counterR}{counterT})
            m1   = min (intrees{counterT}.D ( ...
                spanning.iR{counterR}{counterT}));
            m2   = max (intrees{counterT}.D ( ...
                spanning.iR{counterR}{counterT}));
            mm1  = min (qtrees{counterT}.D  ( ...
                spanning.iR{counterR}{counterT}));
            mm2  = max (qtrees{counterT}.D  ( ...
                spanning.iR{counterR}{counterT}));
            spanning.qdiam{counterR} (end + 1, :) = ...
                0.5 * [((m2 - m1) / (mm2 - mm1)) (m1 / mm1)];
        end
    end
end

spanning.mnBT    = zeros (lenr, 1);
spanning.stdnBT  = zeros (lenr, 1);
for counterR         = 1 : lenr
    spanning.mnBT   (counterR) = mean (cat (2, spanning.nBT{counterR}{:}));
    spanning.stdnBT (counterR) = std  (cat (2, spanning.nBT{counterR}{:}));
end

if strfind       (options, '-w') % waitbar option: close
    close        (HW);
end

if strfind       (options, '-s')
    clf; hold on;
    cX           = ...
        [0 0 0 0; 0 1 1 0; 0 1 1 0; 1 1 0 0; 1 1 0 0; 1 1 1 1] - 0.5;
    cY           = ...
        [0 0 1 1; 0 0 1 1; 1 1 1 1; 0 1 1 0; 0 0 0 0; 0 0 1 1] - 0.5;
    cZ           = ...
        [0 1 1 0; 0 0 0 0; 1 1 0 0; 1 1 1 1; 1 0 0 1; 0 1 1 0] - 0.5;
    colors       = [[0 0 0]; [1 0 0]; [0 1 0]; [0 0 1]];
    colors       = [colors; (rand (lenr - 4, 3))];
    for counterR = 1 : lenr
        HP       = patch ( ...
            mean (spanning.xmass{counterR}) + ...
            cX' * spanning.mxdiff (counterR), ...
            mean (spanning.ymass{counterR}) + ...
            cY' * spanning.mydiff (counterR), ...
            mean (spanning.zmass{counterR}) + ...
            cZ' * spanning.mzdiff (counterR), ...
            colors (counterR, :));
        set      (HP, ...
            'edgecolor',       colors (counterR, :), ...
            'facealpha',       0.2);
        HP       = patch ( ...
            mean (spanning.xmass {counterR})  + ...
            cX' * (spanning.mxdiff (counterR) + ...
            spanning.stdxdiff (counterR)), ...
            mean (spanning.ymass {counterR})  + ...
            cY' * (spanning.mydiff (counterR) + ...
            spanning.stdydiff (counterR)), ...
            mean (spanning.zmass {counterR})  + ...
            cZ' * (spanning.mzdiff (counterR) + ...
            spanning.stdzdiff (counterR)), ...
            colors (counterR, :));
        set      (HP, ...
            'edgecolor',       colors (counterR, :), ...
            'facealpha',       0.2);
        HT       = text ( ...
            mean (spanning.xmass{counterR}) - ...
            spanning.mxdiff (counterR) / 2,   ...
            mean (spanning.ymass{counterR}) + ...
            spanning.mydiff (counterR) / 2,   ...
            mean (spanning.zmass{counterR}) - ...
            spanning.mzdiff (counterR) / 2,   ...
            spanning.regions{counterR});
        set      (HT, ...
            'color',           colors (counterR, :), ...
            'verticalalignment', 'bottom');
    end
    title        ('spanning the tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2); 
    grid         on;
    axis         image;
end
