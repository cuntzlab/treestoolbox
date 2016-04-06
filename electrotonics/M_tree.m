% M_TREE   Conductance matrix of the electric circuitry in a tree.
% (trees package)
%
% M = M_tree (intree, options)
% ----------------------------
%
% Calculates the matrix containing all conductances in the equivalent
% circuit of the neuron in the trees format. To be used in "sse_tree" and
% other electrotonic analysis of trees. 
%
% Input
% -----
% - intree   ::integer:    index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - M        ::matrix:     sparse matrix containing conductances
%
% Example
% -------
% M_tree       (sample_tree, '-s')
%
% See also sse_tree
% Uses idpar_tree cvol_tree surf_tree dA Gm Ri
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function M  = M_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees{intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

dA               = tree.dA;          % directed adjacency matrix of tree
N                = size (dA, 1);     % number of nodes in tree
surf             = surf_tree (tree) / 100000000; % now [cm2]
cvol             = cvol_tree (tree) * 10000;     % now [1/cm]
% conversion is because um -> cm
% Gm/Ri come in [cm] units

% surface values in a diagonal matrix D_s
Msurf            = spdiags (surf,      0, N, N);
% same for inverse continuous volumes:
Mlov             = spdiags (1 ./ cvol, 0, N, N);

% sum over the columns of the intercompartmental axial conductances:
% maybe possible to write using the laplacian matrix:
INTERM           = ones (1, N) * (dA * Mlov + Mlov * dA');
Milov            = - (dA * Mlov + Mlov * dA') + spdiags (INTERM', 0, N, N);
%%% same, slower but clearer :-) :
% lA         = (dA * Mlov + Mlov * dA');
% Milov      = eye (N) .* (ones (N, N) * lA) - lA;

Mgi              = Milov .* (1 ./ tree.Ri);
Mgm              = Msurf .* tree.Gm;
% factor matching scale to [nA] and [mV]:
M                = (Mgm + Mgi) * 1000000;

if strfind       (options, '-s') % show option
    clf; hold on;
    [i1, i2]     = ind2sub (size (M), find (M > 0));
    R1           = [i1 i2 (repmat ([0 1 0], length (i1), 1))];
    [i1, i2]     = ind2sub (size (M), find (M < 0));
    R1           = [R1; [i1 i2 (repmat ([1 0 0], length (i1), 1))]];
    [~, iR]      = sort (rand (size (R1, 1), 1));
    for counter  = 1 : size (R1, 1)
        HP       = plot ( ...
            R1 (iR (counter), 1), ...
            R1 (iR (counter), 2), 'k.');
        set      (HP, ...
            'color',           [0 0 0], ...
            'markersize',      18);
        HP       = plot ( ...
            R1 (iR (counter), 1), ...
            R1 (iR (counter), 2), 'k.');
        set      (HP, ...
            'color',           R1 (iR (counter), 3 : 5), ...
            'markersize',      14);
    end
    set          (gca, ...
        'ydir',        'reverse'); 
    axis         image; 
    box          on;
    title        ('+- conductances matrix');
    xlabel       ('node #');
    ylabel       ('node #');
    HP1          = plot (0, 0, 'r.');
    set          (HP1, ...
        'markersize',          16, ...
        'visible',             'off');
    HP2          = plot (0, 0, 'g.');
    set          (HP2, ...
        'markersize',          16, ...
        'visible',             'off');
    legend       ([HP1 HP2],   {'neg. conductance', 'pos. conductance'});
    xlim         ([1 N]);
    ylim         ([1 N]);
end



