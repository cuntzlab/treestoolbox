% AdExLIF_tree   Adaptive exponential LIF in full morphology
% (trees package)
%
% [v, t, sp] = LIF_tree (intree, time, options, ...
%                  ge, gi, Ee, Ei, I, iroot, thr, vreset, Aspike)
% -----------------------------------------------------------------
%
% Calculates passive or spiking responses to synaptic inputs with dynamic
% structure. The spiking mechanism is 
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - time::vector
% - options::string: {DEFAULT: ''}
%     '-s' : show 
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
% Copyright (C) 2009 - 2018  Hermann Cuntz

function [v, sp,w] = AdExLIF_tree (intree, time, I, ge, gi, options)

% trees : contains the tree structures in the trees package
global           trees

if (nargin < 1)  || isempty (intree)
    intree       = length (trees);
end

ver_tree         (intree);

% use full tree for this function
if ~isstruct     (intree)
    tree         = trees{intree};
else
    tree         = intree;
end

if (nargin < 2)  || isempty (time)
    time         = 0 : 0.1 : 1000;
end
% 
% if (nargin < 3)  || isempty (options)
%     options      = '';
% end


% % trees : contains the tree structures in the trees package
% global           trees
% 
% if (nargin < 1) || isempty (intree)
%     intree       = length (trees);
% end
% 
% ver_tree         (intree);
% 
% % use full tree for this function
% if ~isstruct (intree)
%     tree         = trees{intree};
% else
%     tree         = intree;
% end
% 
% if (nargin < 2) || isempty (ge)
%     ge           = sparse (N, T);
% end
% 
% if (nargin < 3) || isempty (gi)
%     gi           = sparse (N, T);
% end
% 
% if (nargin < 4) || isempty (I)
%     I            = sparse (size (ge));
% end
% 


[M]         = M_tree (intree);

N                = size (M, 1);
T                = size (time, 2);
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
%     if mod (counterT, 100) == 0
%         display (counterT);
%     end
    M1           = M;
    % feed into M the synaptic conductances
    M1           = M1 +  ...
        spdiags (ge (:, counterT), 0, N, N) + ...
        spdiags (gi (:, counterT), 0, N, N);
   
    w(:,counterT+1)=(tree.a*(v(:, counterT)-tree.EL)-w(:,counterT))/tree.tauw*dt+w(:,counterT);

    v (:, counterT + 1) = M1 \ (...
        (ge   (:, counterT) .* tree.Ee') + ...
        (gi   (:, counterT) .* tree.Ei') + ...
        I     (:, counterT) - ...
        w     (:, counterT) + ...
        v     (:, counterT) .* Mcm_vec);
  
   v (tree.iroot, counterT + 1)= v (tree.iroot, counterT + 1)+...
       tree.DeltaT*exp((v(tree.iroot,counterT)-tree.Vt)/tree.DeltaT);
  

    if  any(v (tree.iroot, counterT + 1) >=  tree.thr)      
        v     (tree.iroot, counterT) =   tree.Aspike;   

        v     (v     (:, counterT + 1) > tree.vreset, counterT + 1)     =   tree.vreset;
    
        w(:,counterT + 1)=w(:,counterT)+tree.b;

        % remember spike times:
        sp                      =   [sp; (counterT * dt)];
    end
end
v=v(1,:);





