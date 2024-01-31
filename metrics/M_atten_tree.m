function Matten = M_atten_tree (tree, varargin)

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('thr', 0.13995, @isnumeric) % TODO check the size of thr
pars = parseArgs(p, varargin, {'thr'}, {});
%==============================================================================%

% if (nargin < 2) || isempty (thr)
%     thr    = 0.13995;
% end

N                = length (tree.X);
sse              = sse_tree (tree);
sseC             = sse > pars.thr * max (max (sse));
sseCM            = sseC * 0;
for counter      = 1 : N
    sseCM    ( ...
        find (sseC (:, counter), 1, 'first') : ...
        find (sseC (:, counter), 1, 'last'), ...
        find (sseC (:, counter), 1, 'first') : ...
        find (sseC (:, counter), 1, 'last')) = 1;
end

clf; 
DDF              = [0; (diff (diag (sseCM)))];
DDF (DDF == -1)  = 0;
DDF              = cumsum (DDF) .* diag (sseCM);
Matten           = max (DDF) + 1;


