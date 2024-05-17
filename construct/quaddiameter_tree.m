% QUADDIAMETER_TREE   Map quadratic diameter tapering to tree.
% (trees package)
%
% tree = quaddiameter_tree (intree, scale, offset, P, ldend, options)
% -------------------------------------------------------------------
%
% Applies a quadratic decaying diameter on a given tree structure. P
% and ldend are derived precisely in (Cuntz, Borst and Segev 2007, Theor
% Biol Med Model, 4:21). P is an nx3 matrix containing the parameters to
% put in the quadratic equation y = P(1)x^2 + P(2)x + P(3). Each single
% triplet corresponds to the best fit to a segment of length ldend (nx1)
% vector. When the quadratic diameter is added, the path from each terminal
% to the root is compared to its closest in ldend. Then the quadratic
% equation is chosen according to the index in ldend. This is done for all
% paths from root to terminal point and for each node the diameter is an
% average of all local diamaters of all paths leading through that node.
% Choosing parameters (P and ldend) by hand here is tempting but very hard.
%
% Input
% -----
% - intree   ::integer:index of tree in trees or structured tree
% - scale    ::value: scale of diameter of root
%     {DEFAULT: 0.5}
% - offset   ::value: added base diameter
%     {DEFAULT: 0.5}
% - P        ::matrix of three columns: parameters for the quadratic
%     equation in dependence of the root to tip length given in:
% - ldend    ::vertical vector, same length as P: typical lengths at which
%     P are given
% - options  ::string:
%     '-s'    : show
%     '-w'    : waitbar
%     {DEFAULT ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% quaddiameter_tree (sample_tree, [], [], [], [], '-s')
%
% See also
% Uses Pvec_tree ipar_tree T_tree ver_tree dA D
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2024  Hermann Cuntz

function  tree = quaddiameter_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
% use full tree for this function
tree         = intree;

% =============================== Parsing inputs ======================== %
p            = inputParser;
p.addParameter ('scale', 0.5)
p.addParameter ('offset', 0.5)
p.addParameter ('P', [])
p.addParameter ('ldend', [])
p.addParameter ('s', false)
p.addParameter ('w', false)
pars         = parseArgs (p, varargin, ...
    {'scale', 'offset', 'P', 'ldend'}, ...
    {'s', 'w'});
% ======================================================================= %

P            = pars.P;
ldend        = pars.ldend;

if isempty (P)
    % {DEFAULT: parameters calculated for optimal current transfer for
    % branches on their own}
    load     quaddiameter_P P
end

if isempty (ldend)
    % {DEFAULT: length values of branches for which P is given
    % quaddiameter_tree uses the P whos ldend is closest to the
    % path length for each path to termination point}
    load     quaddiameter_ldend ldend
end

N            = size (tree.dA, 1); % number of nodes in tree
tree.D       = ones (N, 1) .* 0.5; % first set diameter to 0.5 um
Plen         = Pvec_tree (tree)'; % path length from the root [um]
% NOTE! I'm not sure about the following line:
% parent index structure incl. node itself twice:
ipari        = [(1 : N)' (ipar_tree (tree))];
% parent index paths but only for termination nodes:
ipariT       = ipari (T_tree (tree), :);


if pars.w      % waitbar option: initialization
    HW       = waitbar ( ...
        0,                     'calculating quad diameter...');
    set      (HW, ...
        'Name',                '..PLEASE..WAIT..YEAH..');
end

Ds               = zeros (size (ipariT));
for counter      = 1    : size (ipariT, 1)
    if pars.w    % waitbar option: update
        if mod   (counter, 500) == 0
            waitbar (counter / size (ipariT, 1), HW);
        end
    end
    iipariT      = ipariT (counter, ipariT (counter, :) ~= 0);
    iipariT      = fliplr (iipariT);
    pathh        = Plen   (iipariT);
    % find which ldend is closest to path length:
    [~, i2]      = min    ((pathh (end) - ldend).^2);
    quadpathh    = polyval (P (i2, :), pathh) .* pars.scale;
    % apply the diameters:
    Ds (counter, 1 : length (quadpathh)) = fliplr (quadpathh);
end

if pars.w      % waitbar option: close
    close        (HW);
end

% average the diameters for overloaded nodes (there might be a better way
% to do this than averaging):
for counter      = 1 : N
    iR           = ipariT == counter;
    tree.D (counter) = mean (Ds (iR));
end

tree.D           = tree.D + pars.offset; % add offset diameter


if pars.s % show option
    clf; hold on;
    plot_tree    (intree, [0 0 0]);
    plot_tree    (tree,   [1 0 0]);
    title        ('quadratic diameter tapering');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         equal;
end

