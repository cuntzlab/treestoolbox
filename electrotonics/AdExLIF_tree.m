% AdExLIF_tree   Adaptive exponential LIF in full morphology
% (trees package)
%
% [v, sp, w] = AdExLIF_tree (intree, time, I, ge, gi, options)
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
% - options::string: {DEFAULT: ''}
%     '-s' : show
%     '-full' : outputs voltage traces for all nodes
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
% AdExLIF_tree (sample_tree, 100,  95, '-s')
%
% See also syn_tree M_tree sse_tree syncat_tree
% Uses M_tree ver_tree
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [v, sp, w] = AdExLIF_tree (intree, time, I, ge, gi, options)

ver_tree     (intree);
tree         = intree;

if (nargin < 2)  || isempty (time)
    time     = 0 : 0.1 : 1000;
end

M            = M_tree (tree);
N            = size   (M, 1);
T            = size   (time, 2);

if (nargin < 3) || isempty (I)
    I        = sparse (N, T);
end

if (nargin < 4) || isempty (ge)
    ge       = sparse (N, T);
end

if (nargin < 5) || isempty (gi)
    gi       = sparse (N, T);
end

if (nargin < 6)  || isempty (options)
    options  = '';
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



dt               = diff (time (1 : 2)) / 1000;
surf             = surf_tree (tree) / 100000000; % now [cm2]
Msurf            = spdiags   (surf, 0, N, N);
Mcm              = (Msurf .* tree.Cm) / dt; % given in micro Farad!!!!
M                = M + Mcm;
Mgm              = Msurf .* tree.Gm.* 1000000;
Mcm_vec          = full (diag (Mcm)); % get capacitance vector
Mgm_vec          = full (diag (Mgm)) ;
v                = zeros (size (tree.X));
w                = zeros (size (tree.X));
sp               = [];
for counterT     = 1 : T - 1
    if mod (counterT, 500) == 1
        disp     (time (counterT));
    end
    M1           = M;
    % feed into M the synaptic conductances
    M1           = M1 +  ...
        spdiags (ge (:, counterT), 0, N, N) + ...
        spdiags (gi (:, counterT), 0, N, N);

    w (:, counterT + 1) = ...
        (tree.a * (v (:, counterT) - tree.EL) - w (:, counterT)) ...
        / tree.tauw * dt + w (:, counterT);

    v (:, counterT + 1) = M1 \ (...
        (ge   (:, counterT) .* tree.Ee') + ...
        (gi   (:, counterT) .* tree.Ei') + ...
        I     (:, counterT) - ...
        w     (:, counterT) + ...
        v     (:, counterT) .* Mcm_vec);

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

