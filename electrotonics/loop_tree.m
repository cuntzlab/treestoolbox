% LOOP_TREE   Builds conductance matrix of a tree, including loops.
% (trees package)
%
% M = loop_tree (intree, inodes1, inodes2, gelsyn, options)
% ---------------------------------------------------------
%
% Creates loops in the neuronal structure. Since conventional trees cannot
% be used a conductance matrix is calculated directly. The extra
% connections are considered to be electrical synapses
%
% Input
% -----
% - intree   ::integer:    index of tree in trees or structured tree
% - inodes1  ::vector:     starting indices of electrical synapses
%     {DEFAULT: last node}
% - inodes2  ::vector:     ending indices of electrical synapses.
%     {DEFAULT: root}
% - gelsyn   ::vector or number: individual conductance values or one
%     conductance for all
%     {DEFAULT: 1 S}
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% -------
% - M        ::matrix:     sparse matrix containing conductances
%
% Example
% -------
% loop_tree    (sample_tree, [], [], [], '-s')
%
% See also M_tree sse_tree
% Uses M_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function M   = loop_tree (intree, ...
    inodes1, inodes2, gelsyn, ...     % electrical synapses
    options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree); % verify that input is a tree structure

M            = M_tree (intree);

if (nargin < 2) || isempty (inodes1)
    inodes1  = size (M, 1);
end

if (nargin < 3) || isempty (inodes2)
    inodes2  = 1;
end

if (nargin < 4) || isempty (gelsyn)
    gelsyn   = 1;
end

if numel (gelsyn) == 1
    gelsyn   = ones (size (inodes1, 1), 1) .* gelsyn;
end

if (nargin < 5) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

for counter      = 1 : size (inodes1, 1)
    M (inodes1 (counter), inodes2 (counter)) = ...
        M (inodes1 (counter), inodes2 (counter)) - ...
        gelsyn (counter);
    M (inodes2 (counter), inodes1 (counter)) = ...
        M (inodes2 (counter), inodes1 (counter)) -...
        gelsyn (counter);
    M (inodes1 (counter), inodes1 (counter)) = ...
        M (inodes1 (counter), inodes1 (counter)) + ...
        gelsyn (counter);
    M (inodes2 (counter), inodes2 (counter)) = ...
        M (inodes2 (counter), inodes2 (counter)) + ...
        gelsyn (counter);
end

if strfind       (options, '-s')     % show option
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
    HP           = plot (inodes1, inodes2, 'kx');
    set          (HP, ...
        'color',               [0 0 0], ...
        'markersize',          18);
    HP           = plot (inodes2, inodes1, 'kx');
    set          (HP, ...
        'color',               [0 0 0], ...
        'markersize',          18);
    HP           = plot (inodes1, inodes1, 'kx');
    set          (HP, ...
        'color',               [0 0 0], ...
        'markersize',          18);
    HP           = plot (inodes2, inodes2,' kx');
    set          (HP, ...
        'color',               [0 0 0], ...
        'markersize',          18);
    set          (gca, ...
        'ydir',                'reverse');
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
    HP3          = plot (0, 0, 'kx');
    set          (HP3, ...
        'markersize',          16, ...
        'visible',             'off');
    legend       ([HP1 HP2 HP3], ...
        {'neg. conductance', 'pos. conductance', 'el. synapse'});
    xlim         ([1 (size (M, 1))]);
    ylim         ([1 (size (M, 1))]);
end



