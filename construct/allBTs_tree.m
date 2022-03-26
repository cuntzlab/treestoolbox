% ALLBTS_TREE   Outputs all possible trees with N nodes.
% (trees package)
% 
% [BTs BTtrees] = allBTs_tree (N, options)
% -------------------------------------------
%
% Outputs in BCTs all possible non-isomorphic BT strings with N nodes. On
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
% - BTtrees  ::cell array of trees: all possible trees with N nodes
% - BTs      ::vector: the BCT version of the trees in a matrix
%
% Example
% -------
% [BTs, trees] = allBTs_tree (8, '-w -s')
%
%
% See also   BCT_tree
% Uses       isBCT_tree BCT_tree sort_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2022  Hermann Cuntz

function [BTs, BTtrees] = allBTs_tree (N, options)

if (nargin < 1) || isempty (N)
    % {DEFAULT: eight nodes}
    N        = 8;
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: waitbar}
    options  = '-w';
end

MT           = [];
if strfind   (options, '-w')     % waitbar option: initialization
    HW       = waitbar (0, 'trying out BCT strings...');
    set      (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end
for counter     = 0 : (2^N) - 1
    if strfind  (options, '-w') && (mod(counter,1000)==0)  % waitbar option: update
        waitbar (counter / ((2^N) - 1), HW);
    end
    % create all possible strings with B and T:
    BT      = 2 * mod (floor (counter ./ (2.^(N - 1 : -1 : 0))), 2);
    if isBCT_tree (BT)
        % if they are BT conform then add them to the list:
        MT   = [MT; BT];
    end
end
if strfind   (options, '-w')     % waitbar option: close
    close    (HW);
end

MT2                = zeros (size (MT, 1), N);
for counter        = 1 : size (MT, 1)
    BT            = MT (counter, :);
    tree           = BCT_tree  (BT,  '-dA'); % create tree from BCT string
    tree           = sort_tree (tree, '-LO'); % sort in a unique way
    MT2 (counter, :)  = full (sum (tree.dA));
end

BTs               = unique (MT2, 'rows'); % get rid of duplicates
if (nargout > 1) || ~isempty (strfind (options, '-s'))
    BTtrees       = cell (1,  size (BTs, 1));
    for counter       = 1 : size (BTs, 1)
        BTtrees {counter} = BCT_tree (BTs (counter, :));
    end
end

if strfind   (options, '-s') % show option
    clf; hold on;
    dd       = spread_tree (BTtrees);
    for counter = 1 : length  (BTtrees)
        plot_tree    (BTtrees {counter}, [] , dd {counter});
        pointer_tree (dd {counter});
    end
    text     (0, 50, ['all BCT trees - ' num2str(N) ' nodes']);
    view     (2);
    axis     equal off
end






