% JITTER_TREE   Jitters coordinates of a tree.
% (trees package)
%
% tree = jitter_tree (intree, stde, lambda, options, inodes)
% ----------------------------------------------------------
%
% adds spatial noise to the coordinates of the nodes of a tree.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - stde     ::value:   standard deviation in um
%     {DEFAULT: 1}
% - lambda   ::integer: length constant of treeed low pass filter applied
%     on the noise
%     {DEFAULT: 10}
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     {DEFAULT: '-w'}
% - inodes   ::index: nodes of the tree affected by jitter
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     ::structured output tree
%
% Example
% -------
% jitter_tree (sample_tree, [], [], '-s');
%
% See also smooth_tree MST_tree
% Uses ipar_tree
%
% speed up suggested  by Calvin Schneider 2014
% added inodes option by Marcel Beining   2015
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function  varargout = jitter_tree (intree, stde, lambda, options, inodes)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1) || isempty (intree)
    intree   = length (trees);
end;

ver_tree     (intree);

if ~isstruct (intree)
    tree     = trees {intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (stde)
    stde     = 1;
end

if (nargin < 3) || isempty (lambda)
    lambda   = 10;
end

if (nargin < 4) || isempty (options)
    options  = '-w';
end

N            = size (tree.X, 1);

if (nargin < 5) || isempty (inodes)
    inodes   = 1 : N;
end
if islogical (inodes) && numel (inodes) == N  % transform logical indexing
    inodes   = find (inodes);
end

% all paths:
A                = tree.dA + tree.dA';
As               = cell (1, 1);

if strfind       (options, '-w')     % waitbar option: initialization
    HW           = waitbar (0, 'calculating paths...');
    set          (HW, ...
        'Name',                  '..PLEASE..WAIT..YEAH..');
end

for counter      = 1 : lambda
    if strfind   (options, '-w')   % waitbar option: update
        if mod (counter, 5) == 0
            waitbar (counter / lambda, HW);
        end
    end
    As{counter}  = A ^ counter;
end
R                = zeros (N, 3);
R (inodes, :)    = randn (numel (inodes), 3) * stde * lambda;
R1               = zeros (N, 3);

if strfind       (options, '-w')     % waitbar option: reinitialization
    waitbar      (0, ...
        HW,                      'jittering...');
end

for counter      = 1 : N
    if strfind   (options, '-w')   % waitbar option: update
        if mod (counter, 50) == 0,
            waitbar (counter / N, HW);
        end
    end
    Z            = zeros (N, 1);
    Z (counter)  = 1;
    S            = zeros (N, 1);
    S1           = zeros (N, 1);
    for counter2 = 1 : lambda
        zA       = As{counter2} * Z > 0;
        iA       = find ((zA - S1) > 0);
        S1 (iA)  =  1;
        S  (iA)  = counter2;
    end
    S (S == 0)   = 100000;
    S            = gauss (S, 1, lambda / 5);
    R1 (counter, :) = sum   (R .* [S S S]);
end

if strfind       (options, '-w')       % waitbar option: close
    close        (HW);
end

tree.X           = tree.X + R1 (:, 1) - R1 (1, 1);
tree.Y           = tree.Y + R1 (:, 2) - R1 (1, 2);
tree.Z           = tree.Z + R1 (:, 3) - R1 (1, 3);

if strfind       (options, '-s')
    clf; hold on;
    plot_tree    (intree);
    plot_tree    (tree, [1 0 0]);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, {'before', 'after'});
    set          (HP, 'visible', 'off');
    title        ('jitter tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

if (nargout == 1) || (isstruct (intree))
    varargout {1} = tree;
else
    trees {intree} = tree;
end



