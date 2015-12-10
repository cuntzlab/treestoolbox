% SPINES_TREE   Add spines to an existing tree.
% (trees package)
%
% tree = spines_tree (intree, XYZ, dneck, dhead, mlneck, stdlneck, ipart,
% options)
% -------------------------------------------------------------------------
%
% Attaches cylinders with diameter dhead (dhead = length) to closest node
% on an existing tree, introducing a neck with diameter dneck. If XYZ
% coordinates are not defined the spine is attached to a randomly picked
% node with distance mlneck+-stdlneck. If region with name "spines" exists
% then nodes are appended to that region otherwise region named "spines" is
% created.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - XYZ      :: matrix: [X Y Z] or just a number of spines to add
%     {DEFAULT: 100}
% - dneck    ::value:   diameter of spine neck
%     {DEFAULT: 0.25 um}
% - dhead    ::value:   diameter of spine head
%     {DEFAULT: 1 um}
% - mlneck   ::value:   mean neck length
%     {DEFAULT: 1 um}
% - stdlneck ::value:   standard deviation neck length
%     {DEFAULT: 1 um}
% - ipart    ::index:   index to the subpart to be considered
%     {DEFAULT: all nodes}
%     (needs to be real index values not logical subset)
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     {DEFAULT '-w'}
%
% Output
% ------
% if no output is declared the trees are added in trees
% - tree     :: structured output tree
%
% Example
% -------
% spines_tree  (sample_tree, 300, 0.25, 1, 1, 1, [], '-s')
%
% See also quaddiameter_tree MST_tree
% Uses 
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function varargout = spines_tree (intree, XYZ, ...
    dneck, dhead, mlneck, stdlneck, ...
    ipart, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree);       % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees{intree};
else
    tree     = intree;
end

X            = tree.X;       % X-locations of nodes on tree
Y            = tree.Y;       % Y-locations of nodes on tree
Z            = tree.Z;       % Z-locations of nodes on tree

N            = size (X, 1);  % number of nodes in tree

if (nargin < 5) || isempty (mlneck)
    mlneck   = 1;
end

if (nargin < 6) || isempty (stdlneck)
    stdlneck = 1;
end

if (nargin < 2) || isempty (XYZ)
    XYZ      = 100;
end

if (nargin < 3) || isempty (dneck)
    dneck    = 0.5;
end

if (nargin < 4) || isempty (dhead)
    dhead    = 1;
end

if (nargin < 7) || isempty (ipart)
    % {DEFAULT index: select all nodes/points}
    ipart    = (1 : N)';
end

if numel (XYZ) == 1
    indy     = ceil (rand (XYZ, 1) * length (ipart));
    XYZ      = [ ...
        (X (ipart (indy))) ...
        (Y (ipart (indy))) ...
        (Z (ipart (indy)))] + ...
        (randn (XYZ, 3) * stdlneck + mlneck) .* ...
        ((rand (XYZ, 3) > 0.5) * 2 - 1);
end

if isfield       (tree, 'R')
    if isfield   (tree, 'rnames')
        iR       = find (strcmp (tree.rnames, 'spines'));
        if       ~isempty (iR)
            iR   = iR (1);
        else
            iR   = max (tree.R) + 1;
        end
    else
        iR       = max (tree.R) + 1;
    end
else
    iR           = 1;
end

if (nargin < 8) || isempty (options)
    options      = '-w';
end
if strfind       (options, '-w')    % waitbar option: initialization
    if size (XYZ, 1) > 99
        HW       = waitbar (0, 'spining...');
        set      (HW, 'Name', '..PLEASE..WAIT..YEAH..');
    end
end
for counter      = 1 : size (XYZ, 1)
    if strfind   (options, '-w')    % waitbar option: update
        if mod   (counter, 100) == 0
            waitbar (counter / size (XYZ, 1), HW);
        end
    end
    [~, i2]      = min (sqrt ( ...
        (X (ipart) - XYZ (counter, 1)).^2 + ...
        (Y (ipart) - XYZ (counter, 2)).^2 + ...
        (Z (ipart) - XYZ (counter, 3)).^2));
    dXYZ         = XYZ (counter, :) - ...
        [(X (ipart (i2))) (Y (ipart (i2))) (Z (ipart (i2)))];
    dXYZ         = dXYZ ./ norm(dXYZ);
    tree         = insert_tree (tree, ...
        [1 iR ...
        (XYZ (counter, 1)) ...
        (XYZ (counter, 2)) ...
        (XYZ (counter, 3)) ...
        dneck (ipart (i2))], 'none');
    tree         = insert_tree (tree, ...
        [1 iR ...
        (XYZ (counter, 1) + dXYZ (1)), ...
        (XYZ (counter, 2) + dXYZ (2)) ...
        (XYZ (counter, 3) + dXYZ (3)) ...
        dhead (N + 1 + 2 * (counter - 1))], 'none');
end
if strfind       (options, '-w') % waitbar option: close
    if size (XYZ, 1) > 99
        close    (HW);
    end
end

if isfield (tree, 'rnames') && isfield (tree, 'R')
    tree.rnames{end} = 'spines';
end

if strfind       (options, '-s')
    clf; hold on;
    plot_tree    (tree);
    title        ('spinalized tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]'); 
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

if (nargout == 1) || (isstruct (intree))
    varargout{1}  = tree; % if output is defined then it becomes the tree
else
    trees{intree} = tree; % otherwise the orginal tree in trees is replaced
end

