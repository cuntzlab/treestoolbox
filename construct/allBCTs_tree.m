% ALLBCTS_TREE   Outputs all possible trees with N nodes.
% (trees package)
% 
% [BCTs BCTtrees] = allBCTs_tree (N, options)
% -------------------------------------------
%
% Outputs in BCTs all possible non-isomorphic BCT strings with N nodes. On
% demand, cell array of trees BCTtrees is calculated that correspond
% to the BCT strings using sensible metrics. This uses the equivalent tree
% method from "BCT_tree". Gets very slow very quickly.
%
% Input
% -----
% - N        ::integer: number of nodes
%     {DEFAULT 8 nodes}
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     {DEFAULT '-w'}
%
% Output
% ------
% - BCTtrees ::cell array of trees: all possible trees with N nodes
% - BCTs     ::vector: the BCT version of the trees in a matrix
%
% Example
% -------
% [BCTs, trees] = allBCTs_tree (8, '-w -s')
%
%
% See also   BCT_tree
% Uses       isBCT_tree BCT_tree sortLO_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2018  Hermann Cuntz

function [BCTs, BCTtrees] = allBCTs_tree (N, options)

if (nargin < 1) || isempty (N)
    % {DEFAULT: eight nodes}
    N        = 8;
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: waitbar}
    options  = '-w';
end

MT               = [];
if strfind       (options, '-w')     % waitbar option: initialization
    if ((3^N) - 1) > 19998
        HW       = waitbar (0, 'trying out BCT strings...');
        set      (HW, 'Name', '..PLEASE..WAIT..YEAH..');
    end
end
for counter      = 0 : (3^N) - 1
    % waitbar option: update:
    if strfind   (options, '-w')
        if  (mod (counter, 20000) == 19999)
            waitbar (counter / ((3^N) - 1), HW);
        end
    end
    % create all possible strings with B, C and T:
    BCT          = mod (floor (counter ./ (3.^(N - 1 : -1 : 0))), 3);
    if isBCT_tree (BCT)
        % if they are BCT conform then add them to the list:
        MT       = [MT; BCT];
    end
end
if strfind       (options, '-w')     % waitbar option: close
    if ((3^N) - 1) > 19998
        close    (HW);
    end
end

MT2              = zeros (size (MT, 1), N);
for counter      = 1 : size (MT, 1),
    BCT          = MT (counter, :);
    tree         = BCT_tree  (BCT,  '-dA'); % create tree from BCT string
    tree         = sort_tree (tree, '-LO'); % sort in a unique way
    MT2 (counter, :)  = full (sum (tree.dA));
end

BCTs             = unique (MT2, 'rows'); % get rid of duplicates
if (nargout > 1) || ~isempty (strfind (options, '-s'))
    BCTtrees     = cell (1,  size (BCTs, 1));
    for counter  = 1 : size (BCTs, 1)
        BCTtrees{counter} = BCT_tree (BCTs (counter, :));
    end
end

if strfind       (options, '-s') % show option
    clf; hold on;
    dd           = spread_tree (BCTtrees);
    for counter  = 1 : length  (BCTtrees)
        pointer_tree (dd{counter}, 1, [], [], [], '-o');
        plot_tree    (BCTtrees{counter}, [] , dd{counter});
    end
    text         (0, 50, ['all BCT trees - ' (num2str (N)) ' nodes']);
    view         (2);
    axis         image off
end






