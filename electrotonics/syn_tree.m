% SYN_TREE   Steady-state synaptic electrotonic signature of a tree.
% (trees package)
%
% syn = syn_tree (intree, ge, gi, Ee, Ei, I, options)
% ---------------------------------------------------
%
% Calculates the steady state potentials with a given synaptic input.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
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
% - options  ::string: {DEFAULT: ''}
%     '-s' : show 
%
% Output
% ------
% - syn      ::Nx1 matrix:   voltage output
%
% Example
% -------
% syn_tree     (sample_tree, 100,  95, [], [], [], '-s')
% syn_tree     (sample_tree, 100, 105, [], [], [], '-s')
%
% See also M_tree sse_tree syncat_tree
% Uses M_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function syn = syn_tree ( ...
    intree, ...
    ge, gi, Ee, Ei, ...              % synaptic inputs
    I, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    intree   = length (trees);
end;

ver_tree     (intree);

M            = M_tree (intree);
N            = size (M, 1);

if (nargin < 2) || isempty (ge)
    ge       = sparse (N, 1);
end

if (nargin < 3) || isempty (gi)
    gi       = sparse (N, 1);
end

if (nargin < 4) || isempty (Ee)
    Ee       =  60;
end

if (nargin < 5) || isempty (Ei)
    Ei       = -20;
end

if numel (ge) == 1
    dg       = ge;
    ge       = sparse (N, 1);
    ge (dg)  = 1;
end

if numel (gi) == 1
    dg       = gi;
    gi       = sparse (N, 1);
    gi (dg)  = 1;
end

if (nargin < 6) || isempty (I)
    I        = sparse (size (ge, 1), 1);

end

if numel (I)     == 1
    dI           = I;
    I            = sparse (size (ge, 1), 1);
    I (dI)       = 1;
end

if (nargin < 7) || isempty(options)
    options      = '';
end

% feed into M the synaptic conductances
M                = M + ...
    spdiags  (ge, 0, N, N) + ...
    spdiags  (gi, 0, N, N);
% and then inject the corresponding current
syn              = M \ ((ge .* Ee) + (gi .* Ei) + I);

if strfind       (options, '-s')
    clf; hold on;
    plot_tree    (intree, syn(:, 1));
    colorbar;
    L (1)        = pointer_tree (intree, find (ge ~= 0), ...
        [], [0 1 0], [], '-l');
    L (2)        = pointer_tree (intree, find (gi ~= 0), ...
        [], [1 0 0], [], '-l');
    legend       (L, {'exc', 'inh'});
    set          (L, 'facealpha', 0.5);
    title        ('potential distribution [mV]');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end









