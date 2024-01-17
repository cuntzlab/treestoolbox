% DISSECT_TREE   Groups together nodes belonging to same branches.
% (trees package)
%
% [sect, vec] = dissect_tree (intree, options)
% --------------------------------------------
%
% Groups segments together which belong to same branches to be used as
% sections in NEURON-like compartmental modeling. Branches are defined as
% being separated by either branching or termination nodes or
% region-defined borders. To simplify a tree to its dissected version
% delete all continuation points with:
% "delete_tree (tree, find (C_tree (tree))".
% 
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show branches
%     '-r'   : do not section by region
%     {DEFAULT: ''}
%
% Output
% ------
% - sect     ::two-column vector: 1. starting node 2. ending node
% - vec      ::optional vector Nx2: attributes to each element a branch
%     index and a path length value [in um] within the given section
%
% NOTE! this function isn't completely correct yet at the root!
%
% Example
% -------
% sect         = dissect_tree (sample_tree, '-s')
%
% See also   resample_tree, delete_tree, neuron_tree
% Uses       root_tree ipar_tree idpar_tree T_tree B_tree Pvec_tree ver_tree R
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [sect, vec] = dissect_tree (intree, options)

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

% add an empty compartment in the root:
tree             = root_tree (intree);
 % parent index structure (see "ipar_tree"):
ipar             = ipar_tree (tree);
ipar             = ipar + 1;

% iBT: positions at which to cut the tree (branch and terminal nodes):
iBT              = T_tree (tree) | B_tree (tree);
if ...
        (~contains (options, '-r')) && ...
        (isfield (tree,'R')) && ...
        (numel   (tree.R) == numel (tree.X))
    idpar        = idpar_tree (tree);      % indices to direct parents
    % detect region changes:
    iR           = idpar (tree.R ~= tree.R (idpar));
    iBT (iR)     = 1;                      % also dissect with regions
end
% iBT therefore is one whenever a changing point B, T or new R
iiBT             = [1; iBT];

% iS contains for each changing point the index in ipar to the directly
% previous changing point (the beginning of that branch)
if sum (iBT)     == 1
    iS           = sum (cumsum (iiBT (ipar (iBT, :))')' <= 1, 1) + 1;
else
    iS           = sum (cumsum (iiBT (ipar (iBT, :))')' <= 1, 2) + 1;
end
% starting points of the branches are therefore just ipar of iS for all
% changing points:
startB           = ipar (sub2ind (size (ipar), find (iBT), iS)) - 1;
startB (startB == 0) = 1;
% end points are obviously just all changing points:
endB             = find (iBT);
sect             = [startB endB] - 1;
sect (sect == 0) = 1;


vec              = [];
if nargout       > 1
    vec          = zeros (size (tree.dA, 1) + 1, 2);
    % path length values from the root:
    Plen         = [0; (Pvec_tree (tree))];
    o            = 1;
    for counter  = find (iBT)'
        % correct the full path length values with the start of each
        % section:
        DEC      = ipar (sub2ind ( ...
            size (ipar), ...
            ones (1, iS (o)) .* counter, ...
            1 : iS (o)));
        pif      = diff (Plen (DEC ([end 1])));
        pof      = Plen (DEC (1 : end - 1)) - Plen (DEC (end));
        vec (DEC (1 : end - 1), 1) = o;
        vec (DEC (1 : end - 1), 2) = pof ./ pif;
        o        = o + 1;
    end
    vec          = vec (3 : end, :);
    vec (1, 2)   = 0;
end

if contains (options, '-s')       % show option
    clf;
    hold         on;
    if ~isempty  (vec)
        R        = rand (size (sect, 1), 1);
        HP       = plot_tree  (intree, ...
            R (round (vec (:, 1)), :), [], [], [], '-b');
    else
        HP       = plot_tree  (intree, [], [], [], [], '-b');
    end
    set          (HP, ...
        'facealpha',           0.2);
    L            = line ( ...
        [(tree.X (startB)) (tree.X (endB))]', ...
        [(tree.Y (startB)) (tree.Y (endB))]', ...
        [(tree.Z (startB)) (tree.Z (endB))]');
    set          (L, ...
        'color',               [1 0 0],...
        'linewidth',           2);
    HP (1)       = plot (1, 1, 'r-');
    legend       (HP, {'dissected branches'}, ...
        'box','off');
    set          (HP, ...
        'visible',             'off');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

