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
% Copyright (C) 2009 - 2023  Hermann Cuntz

function syn = syn_tree (intree, varargin)

ver_tree     (intree);

M            = M_tree (intree);
N            = size (M, 1);

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('ge', sparse (N, 1))
p.addParameter('gi', sparse (N, 1))
p.addParameter('Ee', 60)
p.addParameter('Ei', -20)
p.addParameter('I', [])
p.addParameter('s', false)
pars = parseArgs(p, varargin, {'ge', 'gi', 'Ee', 'Ei', 'I'}, {'s'});
%==============================================================================%

if numel (pars.ge) == 1
    dg       = pars.ge;
    pars.ge  = sparse (N, 1);
    pars.ge (dg) = 1;
end

if numel (pars.gi) == 1
    dg       = pars.gi;
    pars.gi  = sparse (N, 1);
    pars.gi (dg) = 1;
end

if isempty (pars.I)
    pars.I   = sparse (size (pars.ge, 1), 1);

end

if numel (pars.I) == 1
    dI       = pars.I;
    pars.I   = sparse (size (pars.ge, 1), 1);
    pars.I (dI) = 1;
end

% feed into M the synaptic conductances
M                = M + ...
    spdiags  (pars.ge, 0, N, N) + ...
    spdiags  (pars.gi, 0, N, N);
% and then inject the corresponding current
syn              = M \ ((pars.ge .* pars.Ee) + (pars.gi .* pars.Ei) + pars.I);

if pars.s
    clf;
    hold on;
    plot_tree    (intree, syn(:, 1));
    colorbar;
    L (1)        = pointer_tree (intree, find (pars.ge ~= 0), ...
        [], [0 1 0], [], '-l');
    L (2)        = pointer_tree (intree, find (pars.gi ~= 0), ...
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

