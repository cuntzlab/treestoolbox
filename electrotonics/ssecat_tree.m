% SSECAT_TREE   Steady-state electrotonic signature of connected trees.
% (trees package)
%
% sse = ssecat_tree (intrees, inodes1, inodes2, gelsyn, I, options)
% -----------------------------------------------------------------
%
% Concatenates many trees with electrical synapses and calculates the
% steady-state matrix (see sse_tree). Indices are cumulative summing along
% trees.
%
% Input
% -----
% - intrees  ::cell array:   cell array of trees
% - inodes1  ::array:        indices for elsyn origin, indices are
%     cumulated over trees
%     {DEFAULT: last node of last tree}
% - inodes2  ::array: indices of elsyn endpoints.
%     {DEFAULT: root of first tree}
% - gelsyn   ::number or vector: conductance value or values if
%     inhomogeneous
% - I        ::NxH matrix or value: (optional) current injection vector
%     if I is a number, then 1 nA is injected in position I)
%     if I is omitted I is the identity matrix {DEFAULT}
% - options  ::string:
%     '-s'   : show          - full matrix if I is left empty (full sse)
%                            - tree distribution if I is Nx1 vector
%                            - other Is first column
%     {DEFAULT: ''}
%
% Output
% ------
% - sse      ::NxH matrix:   electrotonic signature matrix
%
% Example
% -------
% ssecat_tree  ( ...
%    {sample_tree, (tran_tree (sample2_tree, [-50 30 0]))}, ...
%    197, 205, 0.01, 195, '-s');
%
% sse          = ssecat_tree ( ...
%    {sample_tree, (tran_tree (sample2_tree, [-50 30 0]))}, ...
%    197, 205, 0.01, [],  '-s');
%
% See also sse_tree syn_tree syncat_tree M_tree loop_tree
% Uses M_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function sse = ssecat_tree ( ...
    intrees, ...
    inodes1, inodes2, gelsyn, ...        % electrical synapses
    I, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty(intrees)
    intrees  = trees;
end;

len          = length (intrees);

for counter  = 1 : len
    ver_tree  (intrees{counter});
end

siz          = zeros (1, len);
for counter  = 1 : len
    siz (counter) = length (intrees {counter}.X);
end
sumsiz       = [0 cumsum(siz)];
N            = sumsiz (end);

if (nargin < 2) || isempty (inodes1)
    inodes1  = size (sumsiz (end), 1);
end

if (nargin < 3) || isempty (inodes2)
    inodes2  = 1;
end

if (nargin < 4) || isempty (gelsyn)
    gelsyn   = 1;
end

if (nargin < 6) || isempty (options)
    options  = '';
end

MM           = sparse ( ...
    sumsiz   (len + 1), ...
    sumsiz   (len + 1));

for counter     = 1 : len
    MM       ( ...
        sumsiz (counter) + 1 : sumsiz (counter + 1), ...
        sumsiz (counter) + 1 : sumsiz (counter + 1)) = ...
        M_tree (intrees {counter});
end

if numel (gelsyn) == 1
    gelsyn   = ones (length (inodes1), 1) .* gelsyn;
end

for counter     = 1 : length (inodes1)
    MM (inodes1 (counter), inodes2 (counter)) = ...
        MM (inodes1 (counter), inodes2 (counter)) - gelsyn (counter);
    MM (inodes2 (counter), inodes1 (counter)) = ...
        MM (inodes2 (counter), inodes1 (counter)) - gelsyn (counter);
    MM (inodes1 (counter), inodes1 (counter)) = ...
        MM (inodes1 (counter), inodes1 (counter)) + gelsyn (counter);
    MM (inodes2 (counter), inodes2 (counter)) = ...
        MM (inodes2 (counter), inodes2 (counter)) + gelsyn (counter);
end

if (nargin < 5) || isempty (I)
    sse      = inv (MM);
else
    if numel (I) == 1,
        dI   = I;
        I    = sparse (size (MM, 1), 1);
        I (dI) = 1;
    end
    sse      = MM \ I;
end

if strfind       (options, '-s')
    if numel (MM) == numel (sse)
        clf;
        imagesc  (sse);
        colorbar;
        axis     image;
        xlabel   ('node #');
        ylabel   ('node #');
        title    ('potential distribution [mV]');
    else
        clf; hold on;
        X        = zeros (N, 1);
        Y        = zeros (N, 1);
        Z        = zeros (N, 1);
        for counter = 1 : len
            plot_tree (intrees{counter}, ...
                sse (sumsiz (counter) + 1 : sumsiz (counter + 1), 1));
            X    (sumsiz (counter) + 1 : sumsiz (counter + 1)) = ...
                intrees {counter}.X;
            Y    (sumsiz (counter) + 1 : sumsiz (counter + 1)) = ...
                intrees {counter}.Y;
            Z    (sumsiz (counter) + 1 : sumsiz (counter + 1)) = ...
                intrees {counter}.Z;
        end
        L        = line ( ...
            [(X (inodes1)) (X (inodes2))]', ...
            [(Y (inodes1)) (Y (inodes2))]', ...
            [(Z (inodes1)) (Z (inodes2))]');
        set      (L, ...
            'linestyle',       '--', ...
            'color',           [0 0 0], ...
            'linewidth',       2);
        legend   (L (1), 'el. synapse');
        colorbar;
        title    ('potential distribution [mV]');
        xlabel   ('x [\mum]');
        ylabel   ('y [\mum]');
        zlabel   ('z [\mum]');
        view     (2);
        grid     on;
        axis     image;
        set      (gca, ...
            'clim', [0 (full (1.2 * max (max (sse))))]);
    end
end





