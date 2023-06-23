% SYNCAT_TREE   Steady-state synaptic elect. signature of connected trees.
% (trees package)
%
% syn = syncat_tree (intrees, inodes1, inodes2, gelsyn, ge, gi, Ee, Ei, ...
%                    I, options)
% -------------------------------------------------------------------------
%
% Concatenates many trees with electrical synapses and calculates the
% responses to synaptic input (see syn_tree). Indices are cumulative
% summing along trees; N (below) is sum of all nodes in all trees.
%
% Input
% -----
% - intrees  ::cell array:   cell array of trees
% - inodes1  ::array:        indices for elsyn origin, indices are
%     cumulated over trees
% - inodes2  ::array:        indices of  elsyn endpoints
% - gelsyn   ::number or vector: conductance value or values if individual
%     in [uS]
% - ge       ::Nx1 vector or value: excitatory synaptic input ind.
%     compartments (or allround)
%     {DEFAULT: 0 uS in all nodes}
% - gi       ::Nx1 vector or value: inhibitory synaptic input ind.
%     compartments (or allround)
%     {DEFAULT: 0 uS in all nodes}
% - Ee       ::Nx1 vector or value: excitatory reversal potential ind.
%     compartments (or allround)
%     {DEFAULT:  60 mV}
% - Ei       ::Nx1 vector or value: inhibitory reversal potential ind.
%     compartments (or allround)
%     {DEFAULT: -20 mV}
% - I        ::Nx1 vector:   current injection vector {DEFAULT 0 nA}
%      if I is a number, then 1 nA is injected in position I)
% - options::string:
%     '-s' : show - full matrix if I is left empty (full sse)
%                 - tree distribution if I is Nx1 vector
%                 - other Is first column
%     {DEFAULT: ''}
%
% Output
% ------
% - syn      ::Nx1 matrix:   voltage output
%
% Example
% -------
% % be creative.. (see ssecat_tree)
%
% See also sse_tree syn_tree ssecat_tree M_tree loop_tree
% Uses M_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function syn = syncat_tree (...
    intrees, ...
    inodes1, inodes2, gelsyn, ...        % electrical synapses
    ge, gi, Ee, Ei, ...                  % synaptic inputs
    I, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intrees)
    intrees  = trees;
end

len          = length (intrees);

for counter  = 1 : len
    ver_tree (intrees {counter});
end

siz          = zeros (1, len);
for counter  = 1 : len
    siz (counter) = length (intrees {counter}.X);
end
sumsiz       = [0 (cumsum (siz))];
N            = sumsiz (end);

if (nargin < 2) || isempty (inodes1)
    inodes1  = size (N, 1);
end

if (nargin < 3) || isempty (inodes2)
    inodes2  = 1;
end

if (nargin < 4) || isempty (gelsyn)
    gelsyn   = 1;
end

if (nargin < 5) || isempty (ge)
    ge       = sparse (N, 1);
end

if (nargin < 6) || isempty (gi)
    gi       = sparse (N, 1);
end

if (nargin < 7) || isempty (Ee)
    Ee       =  60;
end

if (nargin < 8) || isempty (Ei)
    Ei       = -20;
end

if numel (ge)  == 1
    dg       = ge;
    ge       = sparse (N, 1);
    ge (dg)  = 1;
end

if numel (gi)  == 1
    dg       = gi;
    gi       = sparse (N, 1);
    gi (dg)  = 1;
end

if (nargin < 9) || isempty (I)
    I        = sparse (N, 1);
end

if numel (I) == 1
    dI       = I;
    I        = sparse (N, 1);
    I (dI)   = 1;
end

if (nargin < 10) || isempty (options),
    options  = '';
end

MM               = sparse ( ...
    sumsiz (len + 1), ...
    sumsiz (len + 1));

for counter      = 1 : len
    MM           ( ...
        sumsiz (counter) + 1 : sumsiz (counter + 1),   ...
        sumsiz (counter) + 1 : sumsiz (counter + 1)) = ...
        M_tree   (intrees{counter});
end

if numel (gelsyn) == 1
    gelsyn       = ones (length (inodes1), 1) .* gelsyn;
end

for counter      = 1 : length (inodes1)
    MM (inodes1 (counter), inodes2 (counter)) = ...
        MM (inodes1 (counter), inodes2 (counter)) - gelsyn (counter);
    MM (inodes2 (counter), inodes1 (counter)) = ...
        MM (inodes2 (counter), inodes1 (counter)) - gelsyn (counter);
    MM (inodes1 (counter), inodes1 (counter)) = ...
        MM (inodes1 (counter), inodes1 (counter)) + gelsyn (counter);
    MM (inodes2 (counter), inodes2 (counter)) = ...
        MM (inodes2 (counter), inodes2 (counter)) + gelsyn (counter);
end

% feed into M the synaptic conductances
MMg              = MM + ...
    spdiags (ge, 0, N, N) + ...
    spdiags (gi, 0, N, N);
% and then inject the corresponding current
syn              = MMg \ ((ge .* Ee) + (gi .* Ei) + I);

if contains      (options, '-s')
    clf;
    hold         on;
    X            = zeros (N, 1);
    Y            = zeros (N, 1);
    Z            = zeros (N, 1);
    for counter  = 1 : len
        plot_tree (intrees {counter}, ...
            syn   (sumsiz (counter) + 1 : sumsiz (counter + 1), 1));
        X (sumsiz (counter) + 1 : sumsiz (counter + 1)) = ...
            intrees{counter}.X;
        Y (sumsiz (counter) + 1 : sumsiz (counter + 1)) = ...
            intrees{counter}.Y;
        Z (sumsiz (counter) + 1 : sumsiz (counter + 1)) = ...
            intrees{counter}.Z;
    end
    L            = [];
    ige          = find (ge ~= 0);
    R            = rand ( ...
        length (ige), 3) .* repmat ([50 50 150], ...
        length (ige), 1);
    HP           = line ( ...
        [(X (ige)) (X (ige)) + (R (:, 1))]',...
        [(Y (ige)) (Y (ige)) + (R (:, 2))]',...
        [(Z (ige)) (Z (ige)) + (R (:, 3))]');
    set          (HP, ...
        'linestyle',         '-', ...
        'color',             [0 1 0], ...
        'linewidth',         2);
    L (1)        = HP (1);
    igi          = find (gi ~= 0);
    R            = rand ( ...
        length (igi), 3) .* repmat ([50 50 150], ...
        length (igi), 1);
    HP           = line ( ...
        [(X (igi)) (X (igi)) + (R (:, 1))]',...
        [(Y (igi)) (Y (igi)) + (R (:, 2))]',...
        [(Z (igi)) (Z (igi)) + (R (:, 3))]');
    set          (HP, ...
        'linestyle',         '-', ...
        'color',             [1 0 0], ...
        'linewidth',         2);
    L (2)        = HP (1);
    L2           = line ( ...
        [(X (inodes1)) (X (inodes2))]', ...
        [(Y (inodes1)) (Y (inodes2))]',...
        [(Z (inodes1)) (Z (inodes2))]');
    set          (L2, ...
        'linestyle',         '--', ...
        'color',             [0 0 0], ...
        'linewidth',         2);
    L (3)        = L2 (1);
    legend       (L, {'exc', 'inh', 'elsyn'});
    colorbar;
    title        ('potential distribution [mV]');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end



