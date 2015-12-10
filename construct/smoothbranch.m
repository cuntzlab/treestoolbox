% SMOOTHBRANCH   Smoothen points along one path.
% (scheme package)
%
% [Xs, Ys, Zs] = smoothbranch (X, Y, Z, p, n)
% -------------------------------------------
%
% smoothes a branch given by consecutive (!) 3D coordinates. This changes
% (shortens) the total length of the branch significantly.
%
% Input
% -----
% - X, Y, Z  ::Nx1 vectors:  input coordinates
% - p        ::0..1:         percent smoothing at each iteration step
% - n        ::integer>0:    number of smoothing iterations
%
% Output
% ------
% - Xs, Ys, Zs::Nx1 vectors: output coordinates
%
%
% Example
% -------
% X            = 2 * rand (10, 1) + (1 : 10)';
% Y            = 2 * rand (10, 1) + (1 : 10)';
% Z            = zeros (10, 1);
% [Xs, Ys, Zs] = smoothbranch (X, Y, Z, 0.9, 5);
% clf; hold on;
% plot3        (X,  Y,  Z,  'k-');
% plot3        (Xs, Ys, Zs, 'r-');
%
% See also smooth_tree
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [Xs, Ys, Zs] = smoothbranch (X, Y, Z, p, n)

if length (X)    > 2
    for counter  = 1 : n
        X2       = X (2 : end - 1);
        Y2       = Y (2 : end - 1);
        Z2       = Z (2 : end - 1);
        X1       = X (1 : end - 2);
        Y1       = Y (1 : end - 2);
        Z1       = Z (1 : end - 2);
        X3       = X (3 : end);
        Y3       = Y (3 : end);
        Z3       = Z (3 : end);
        u        = ( ...
            (X2 - X1) .* (X3 - X1) + ...
            (Y2 - Y1) .* (Y3 - Y1) + ...
            (Z2 - Z1) .* (Z3 - Z1)) ./ ( ...
            (X3 - X1).^2 + ...
            (Y3 - Y1).^2 + ...
            (Z3 - Z1).^2);
        Xu       = X1 + u .* (X3 - X1);
        Yu       = Y1 + u .* (Y3 - Y1);
        Zu       = Z1 + u .* (Z3 - Z1);
        Xs       = X2 + p .* (Xu - X2);
        Ys       = Y2 + p .* (Yu - Y2);
        Zs       = Z2 + p .* (Zu - Z2);
        Xs       = [(X (1)); Xs; (X (end))];
        Ys       = [(Y (1)); Ys; (Y (end))];
        Zs       = [(Z (1)); Zs; (Z (end))];
        X        = Xs;
        Y        = Ys;
        Z        = Zs;
    end
else
    Xs           = X;
    Ys           = Y;
    Zs           = Z;
end


