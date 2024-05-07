% AdExLIF_tree   Adaptive exponential LIF in full morphology
% (trees package)
%
% [v, sp, w] = AdExLIF_tree (intree, time, I, ge, gi)
% -----------------------------------------------------------------
%
% Calculates passive or spiking responses to synaptic inputs with dynamic
% structure. The spiking mechanism is
%
% Input
% -----
% - intree ::integer: index of tree in trees or structured tree
% - time   ::vector: in [ms]
% - I      ::NxT matrix: currents injected in each node per time
%
% The input tree needs to have the following fields:
% - Cm     : Membrane capacitance {DEFAULT: 1 uF/cm2}
% - Gm     : Membrane conductance {DEFAULT: 1 / 40000 S/cm2}
% - Ri     : Axial resistance {DEFAULT: 100 Ohm cm}
% - Aspike : Spike amplitude {DEFAULT: 110 mV}
% - Vrest  : Resting potential {DEFAULT: -70 mV}
% - Ee     : E{DEFAULT:  60 mV}
% - Ei     : {DEFAULT: -20 mV}
% - iroot  : {DEFAULT: 1}
% - EL     : {DEFAULT: 0}
% - DeltaT : {DEFAULT: 2}
% - Vt     : {DEFAULT: 10}
% - thr    : {DEFAULT: 80}
% - vreset : {DEFAULT: 2}
% - tauw   : {DEFAULT: 0.4}
% - b      : {DEFAULT: 1 * 10^-6}
% - a      : {DEFAULT: 0}
%
% Output
% ------
% - syn::Nx1 matrix: voltage output
%
% Example
% -------
% AdExLIF_tree (sample_tree)
%
% See also syn_tree M_tree sse_tree syncat_tree
% Uses M_tree ver_tree
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [v, sp, w] = AdExLIF_tree (intree, varargin)

ver_tree     (intree);
tree         = intree;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('time', 0 : 0.1 : 1000)
p.addParameter('I', [])
p.addParameter('ge', [])
p.addParameter('gi', [])
pars = parseArgs(p, varargin, {'time', 'I', 'ge', 'gi'}, {});
%==============================================================================%

M            = M_tree (tree);
N            = size   (M, 1);
T            = size   (pars.time, 2);

if isempty (pars.I)
    pars.I   = sparse (N, T);
end

if isempty (pars.ge)
    pars.ge  = sparse (N, T);
end

if isempty (pars.gi)
    pars.gi  = sparse (N, T);
end

if ~isfield (tree, 'Ri')
    tree.Ri  = 100;
end

if ~isfield (tree, 'Gm')
    tree.Gm  = 1 / 40000;
end

if ~isfield (tree, 'Cm')
    tree.Cm  = 1;
end

if ~isfield (tree, 'Aspike')
tree.Aspike      = 110;
end

if ~isfield (tree, 'Vrest')
tree.Vrest       = -70;
end

if ~isfield (tree, 'Ee')
tree.Ee          =  60;
end

if ~isfield (tree, 'Ei')
tree.Ei          = -20;
end

if ~isfield (tree, 'iroot')
tree.iroot       = 1;
end

if ~isfield (tree, 'EL')
tree.EL          = 0;
end

if ~isfield (tree, 'DeltaT')
tree.DeltaT      = 2;
end

if ~isfield (tree, 'Vt')
tree.Vt          = 10;
end

if ~isfield (tree, 'thr')
tree.thr         = 80;
end

if ~isfield (tree, 'vreset')
tree.vreset      = 2;
end

if ~isfield (tree, 'tauw')
tree.tauw        = 0.4;
end

if ~isfield (tree, 'b')
tree.b           = 1 * 10^-6;
end

if ~isfield (tree, 'a')
tree.a           = 0;
end



dt               = diff (pars.time (1 : 2)) / 1000;
surf             = surf_tree (tree) / 100000000; % now [cm2]
Msurf            = spdiags   (surf, 0, N, N);
Mcm              = (Msurf .* tree.Cm) / dt; % given in micro Farad!!!!
M                = M + Mcm;
Mgm              = Msurf .* tree.Gm.* 1000000;
Mcm_vec          = full (diag (Mcm)); % get capacitance vector
Mgm_vec          = full (diag (Mgm));
v                = zeros (size (tree.X));
w                = zeros (size (tree.X));
sp               = [];
for counterT     = 1 : T - 1
    if mod (counterT, 500) == 1
        disp     (pars.time (counterT));
    end
    M1           = M;
    % feed into M the synaptic conductances
    M1           = M1 +  ...
        spdiags    (pars.ge (:, counterT), 0, N, N) + ...
        spdiags    (pars.gi (:, counterT), 0, N, N);

    w (:, counterT + 1) = ...
        (tree.a * (v (:, counterT) - tree.EL) - w (:, counterT)) ...
        / tree.tauw * dt + w (:, counterT);

    v (:, counterT + 1) = M1 \ (...
        (pars.ge   (:, counterT) .* tree.Ee') + ...
        (pars.gi   (:, counterT) .* tree.Ei') + ...
        pars.I     (:, counterT) - ...
        w          (:, counterT) + ...
        v          (:, counterT) .* Mcm_vec);

    v (tree.iroot, counterT + 1) = ...
        v (tree.iroot, counterT + 1) + ...
        tree.DeltaT * ...
        exp ((v (tree.iroot, counterT) - tree.Vt) / tree.DeltaT);


    if  any (v (tree.iroot, counterT + 1) >=  tree.thr)
        v (tree.iroot, counterT) =   tree.Aspike;
        v (v (:, counterT + 1) > tree.vreset, counterT + 1) = tree.vreset;

        w (:, counterT + 1) = w (:, counterT) + tree.b;

        % remember spike times:
        sp       =   [sp; (counterT * dt)];
    end
end

v                = v (1, :);

