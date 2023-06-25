function Matten = M_atten_tree (tree, thres)

if (nargin < 2) || isempty (thres)
    thres    = 0.13995;
end

N                = length (tree.X);
sse              = sse_tree (tree);
sseC             = sse > thres * max (max (sse));
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


