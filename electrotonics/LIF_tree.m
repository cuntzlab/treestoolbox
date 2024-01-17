% LIF_TREE   Leaky integrate-and-fire in full morphology
% (trees package)
%
% [v, t, sp] = LIF_tree (intree, time, options, ...
%                  Vzone, ge, gi, Ee, Ei, I, iroot, thr, vreset, Aspike)
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

function [v, time, sp] = LIF_tree (intree, time, options, ...
    Vzone, ge, gi, Ee, Ei, I, iroot, thr, vreset, Aspike)

ver_tree         (intree);
tree             = intree;

if (nargin < 2)  || isempty (time)
    time         = 0 : 0.1 : 1000;
end

if (nargin < 3)  || isempty (options)
    options      = '';
end

M                = M_tree (intree);
N                = size   (M,    1);
T                = size   (time, 2);
dt               = diff   (time  (1 : 2)) / 1000;

if (nargin < 4)  || isempty (Vzone)
    Vzone        = 0.995;
end

if (nargin < 5)  || isempty (ge)
    if ~isfield  (tree, 'ge')
        ge       = sparse (N, T);
    else
        ge       = tree.ge;
    end
end

if (nargin < 6)  || isempty (gi)
    if ~isfield   (tree, 'gi')
        gi       = sparse (N, T);
    else
        gi       = tree.gi;
    end
end

if (nargin < 7)  || isempty (Ee)
    if ~isfield   (tree, 'Ee')
        Ee       =  60;
    else
        Ee       = tree.Ee;
    end
end

if (nargin < 8)  || isempty (Ei)
    if ~isfield  (tree, 'Ei')
        Ei       =  -20;
    else
        Ei       = tree.Ei;
    end
end

if (nargin < 9)  || isempty (I)
    if ~isfield  (tree, 'I')
        I        = sparse (size (ge));
    else
        I        = tree.I;
    end
end

if (nargin < 10)  || isempty (iroot)
    if ~isfield  (tree, 'iroot')
        iroot    = 1;
    else
        iroot    = tree.iroot;
    end
end

if (nargin < 11) || isempty (thr)
    if ~isfield  (tree, 'thr')
        thr      = 10;
    else
        thr      = tree.thr;
    end
end

if (nargin < 12) || isempty (vreset)
    if ~isfield  (tree, 'vreset')
        vreset   = 0;
    else
        vreset   = tree.vreset;
    end
end

if (nargin < 13) || isempty (Aspike)
    if ~isfield  (tree, 'Aspike')
        Aspike   = 75;
    else
        Aspike   = tree.Aspike;
    end
end

plset            = zeros (N, 1);
if contains (options, '-t')
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
v                = zeros     (size (I));
sp               = [];
for counterT     = 1 : T - 1
    if contains  (options, '-e')
        if mod (counterT - 1, 100) == 0
            disp (time (counterT));
        end
    end
    M1           = M;
    % feed into M the synaptic conductances
    M1           = M1 +  ...
        spdiags  (ge (:, counterT), 0, N, N) + ...
        spdiags  (gi (:, counterT), 0, N, N);
    v (:, counterT + 1) = M1 \ (...
        (ge   (:, counterT) .* Ee') + ...
        (gi   (:, counterT) .* Ei') + ...
        I     (:, counterT) + ...
        v     (:, counterT) .* Mcm_vec);
    % voltage reaches threshold -> reset
    if  v (iroot, counterT + 1) >=  thr
        v     (iroot, counterT) =   Aspike;   % spike amplitude
        v0       = v (:, counterT + 1);
        %         v     (v     (ireset, counterT + 1) > Vzone * thr, counterT + 1) = ...
        %             vreset;   % reset voltage
        
        v (:, counterT + 1) = vreset + (v0 - vreset) .* plset;
        % remember spike times:
        sp       =   [sp; (counterT * dt)];
    end
end

