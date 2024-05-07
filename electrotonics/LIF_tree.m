% LIF_TREE   Leaky integrate-and-fire in full morphology
% (trees package)
%
% [v, sp] = LIF_tree (intree, time, Vzone, ge, gi, Ee, Ei, ...
%                       I, iroot, thr, vreset, Aspike, options)
% ----------------------------------------------------------------------
%
% Calculates passive or spiking responses to synaptic inputs with dynamic
% structure. The spiking mechanism is
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - time::vector of length T
% - options::string: {DEFAULT: ''}
%     '-s' : show
%     '-p' : partial reset in 20% closest nodes
%
% Also possible, model parameters, usually from fields of intree:
% - ge::NxT vector or value:excitatory synaptic input ind. compartments
%       (or allround) {DEFAULT: 0 uS in all nodes}
% - gi::NxT vector or value:inhibitory synaptic input ind. compartments
%       (or allround) {DEFAULT: 0 uS in all nodes}
% - Ee::Nx1 vector or value:excitatory reversal potential ind. compartments
%       (or allround) {DEFAULT: 60 mV}
% - Ei::Nx1 vector or value:inhibitory reversal potential ind. compartments
%       (or allround) {DEFAULT: -20 mV}
% - I::NxT vector:current injection vector
%       {DEFAULT 0 nA throughout}
% - iroot:single value: tree node at which IF mechanism is inserted
%       {DEFAULT 1, root of the tree}
% - thr::value: Threshold value (above resting voltage, IF mechanism)
%       {DEFAULT 10 mV}
% - vreset::value: Voltage reset after spiking (IF mechanism)
%       {DEFAULT 0 mV, resting voltage...}
% - Aspike::value: Voltage amplitude of spike (IF mechanism)
%       {DEFAULT 75 mV, above resting voltage}
%
% Output
% ------
% - syn::Nx1 matrix: voltage output
%
% Example
% -------
% LIF_tree (sample_tree, 100,  95, '-s')
%
% See also syn_tree M_tree sse_tree syncat_tree
% Uses M_tree ver_tree
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [v, sp] = LIF_tree (intree, varargin)

ver_tree         (intree);
tree             = intree;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('time', 0 : 0.1 : 1000)
p.addParameter('Vzone', 0.995)
p.addParameter('ge', [])
p.addParameter('gi', [])
p.addParameter('Ee', [])
p.addParameter('Ei', [])
p.addParameter('I', [])
p.addParameter('iroot', [])
p.addParameter('thr', [])
p.addParameter('vreset', [])
p.addParameter('Aspike', [])
pars = parseArgs(p, varargin, ...
    {'time', 'Vzone', 'ge', 'gi', 'Ee', 'Ei', ...
    'I', 'iroot', 'thr', 'vreset', 'Aspike'}, ...
    {'t', 'e'});
%==============================================================================%

M                = M_tree (intree);
N                = size   (M,    1);
T                = size   (pars.time, 2);
dt               = diff   (pars.time  (1 : 2)) / 1000;

if isempty (pars.ge)
    if ~isfield  (tree, 'ge')
        pars.ge  = sparse (N, T);
    else
        pars.ge  = tree.ge;
    end
end

if isempty (pars.gi)
    if ~isfield   (tree, 'gi')
        pars.gi  = sparse (N, T);
    else
        pars.gi  = tree.gi;
    end
end

if isempty (pars.Ee)
    if ~isfield   (tree, 'Ee')
        pars.Ee  =  60;
    else
        pars.Ee  = tree.Ee;
    end
end

if isempty (pars.Ei)
    if ~isfield  (tree, 'Ei')
        pars.Ei  =  -20;
    else
        pars.Ei  = tree.Ei;
    end
end

if isempty (pars.I)
    if ~isfield  (tree, 'I')
        pars.I   = sparse (size (pars.ge));
    else
        pars.I   = tree.I;
    end
end

if isempty (pars.iroot)
    if ~isfield  (tree, 'iroot')
        pars.iroot = 1;
    else
        pars.iroot = tree.iroot;
    end
end

if isempty (pars.thr)
    if ~isfield  (tree, 'thr')
        pars.thr = 10;
    else
        pars.thr = tree.thr;
    end
end

if isempty (pars.vreset)
    if ~isfield  (tree, 'vreset')
        pars.vreset = 0;
    else
        pars.vreset = tree.vreset;
    end
end

if isempty (pars.Aspike)
    if ~isfield  (tree, 'Aspike')
        pars.Aspike = 75;
    else
        pars.Aspike = tree.Aspike;
    end
end

plset            = zeros (N, 1);
if pars.t
    lambda       = 100;
    xoffset      = 600;
    Pvec         = Pvec_tree (tree);
    plset        = 1 ./ (1 + exp  (-(Pvec - xoffset) / lambda));
end

surf             = surf_tree (tree) / 100000000; % now [cm2]
Msurf            = spdiags   (surf, 0, N, N);
Mcm              = (Msurf .* tree.Cm) / dt; % given in micro Farad!!!!
M                = M + Mcm;
Mcm_vec          = full      (diag (Mcm)); % get capacitance vector
v                = zeros     (size (pars.I));
sp               = [];
for counterT     = 1 : T - 1
    if pars.e
        if mod (counterT - 1, 100) == 0
            disp (pars.time (counterT));
        end
    end
    M1           = M;
    % feed into M the synaptic conductances
    M1           = M1 +  ...
        spdiags  (pars.ge (:, counterT), 0, N, N) + ...
        spdiags  (pars.gi (:, counterT), 0, N, N);
    v (:, counterT + 1) = M1 \ (...
        (pars.ge   (:, counterT) .* pars.Ee') + ...
        (pars.gi   (:, counterT) .* pars.Ei') + ...
        pars.I     (:, counterT) + ...
        v          (:, counterT) .* Mcm_vec);
    % voltage reaches threshold -> reset
    if  v (pars.iroot, counterT + 1) >=  pars.thr
        v     (pars.iroot, counterT) =   pars.Aspike;   % spike amplitude
        v0       = v (:, counterT + 1);
        %         v     (v     (ireset, counterT + 1) > Vzone * thr, counterT + 1) = ...
        %             vreset;   % reset voltage
        
        v (:, counterT + 1) = pars.vreset + (v0 - pars.vreset) .* plset;
        % remember spike times:
        sp       =   [sp; (counterT * dt)];
    end
end

