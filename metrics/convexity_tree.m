% CONVEXITY_TREE Calculates convexity of a tree.
% (trees package)
%
% c = convexity_tree(intree, options)
% --------------------------------------
%
% Returns the convexity of a tree structure. Convexity is defined as the
% proportion of direct paths between termination points of a tree that lie
% entirely within the tightest boundary that can be drawn around said tree.
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options  ::string: {DEFAULT: '-3d'}
%     '-dim3'  : three-dimensional triangulation (Careful, it used to be '-3d')
%     '-dim2'  : two-dimensional polygon (Careful, it used to be '-2d')
%
% Output
% -------
% - c        ::scalar: convexity of intree.
%
% Example
% -------
% convexity_tree (sample_tree, '-dim3')
%
% See also boundary_tree
% Uses T_tree B_tree ver_tree
%
%
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz


function c = convexity_tree(intree, varargin)

ver_tree     (intree); % verify that input is a tree structure

warning      ('off', 'all');

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('dim2', false, @isBinary)
p.addParameter('dim3', true, @isBinary)
pars = parseArgs(p, varargin, {}, {'dim2', 'dim3'});
%==============================================================================%

if pars.dim3 % 3d case
    T = T_tree(intree);

    X = intree.X(T);
    Y = intree.Y(T);
    Z = intree.Z(T);

    [k, ~] = boundary(X, Y, Z, 0);
    figure1 = figure;
    K = trisurf(k, X, Y, Z);

    S1 = [X, Y, Z]; % Probability source points
    S2 = [X, Y, Z]; % Probability sinkpoints

    nS1 = size(S1, 1);
    nS2 = size(S2, 1);

    sV1 = 1:nS1;
    sV2 = 1:nS2;
    [sM1, sM2] = meshgrid(sV1, sV2);
    sA1 = sM1(:);
    sA2 = sM2(:); % Indices of vector pairs

    TriPoints = K.Vertices; % Points of triangles
    TriFaces = K.Faces; % Indices of faces
    nF = size(TriFaces, 1); % Number of faces

    %------------- Get intersections of planes and lines ---------------------
    Inds = zeros(nS1*nS2, 1);
    for i = 1:(nS1 * nS2)
        va = S1(sA1(i), :);
        vb = S2(sA2(i), :);
        t = 1;
        j = 1;
        while t == 1 && j <= nF
            v0 = TriPoints(TriFaces(j, 1), :);
            v1 = TriPoints(TriFaces(j, 2), :);
            v2 = TriPoints(TriFaces(j, 3), :);

            V = [va(1) - v0(1); va(2) - v0(2); va(3) - v0(3)];
            M = [va(1) - vb(1), v1(1) - v0(1), v2(1) - v0(1), ...
                 va(2) - vb(2), v1(2) - v0(2), v2(2) - v0(2), ...
                 va(3) - vb(3), v1(3) - v0(3), v2(3) - v0(3)];
            M = reshape(M, [3, 3])';
            X = M \ V;

            if X(1) >= 0 && X(1) <= 1 % Check intersection is between points;
                if X(2) >= 0 && X(2) <= 1 && X(3) >= 0 && X(3) <= 1 && (X(2) + X(3)) <= 1 % Check intersection lays on a face
                    t = 0;
                end
            end
            j = j + 1; % Increase index
        end
        if t == 1
            Inds(i) = 1;
        end
    end
    c = 1 - nnz(Inds) / (nS1 * nS2);
    close(figure1)
else % 2d case
    T = T_tree(intree);
    B = B_tree(intree);

    X = intree.X(T);
    Y = intree.Y(T);


    [k, ~] = boundary(X, Y, 1);

    xv = X(k);
    yv = Y(k);

    X = intree.X(B);
    Y = intree.Y(B);

    S1 = [X, Y]; % Probability source points
    S2 = [X, Y]; % Probability sinkpoints

    nS1 = size(S1, 1);
    nS2 = size(S2, 1);

    sV1 = 1:nS1;
    sV2 = 1:nS2;
    [sM1, sM2] = meshgrid(sV1, sV2);
    sA1 = sM1(:);
    sA2 = sM2(:); % Indices of vector pairs


    nF = length(k); % Number of sides
    Inds = zeros(nS1*nS2, 1);
    for i = 1:(nS1 * nS2)
        x1 = S1(sA1(i), 1);
        y1 = S1(sA1(i), 2);
        x2 = S2(sA2(i), 1);
        y2 = S2(sA2(i), 2);

        t = 1;
        j = 1;
        while t == 1 && j <= nF
            x3 = xv(j);
            y3 = yv(j);
            if j < nF
                x4 = xv(j+1);
                y4 = yv(j+1);
            else
                x4 = xv(1);
                y4 = yv(1);
            end

            A = [x2 - x1, x4 - x3, y2 - y1, y4 - y3];
            A = reshape(A, [2, 2])';
            B = [x3 - x1; y3 - y1];
            X = A \ B;
            if X(1) >= 0 && X(1) <= 1 % Check intersection is between points;
                if X(2) >= 0 && X(2) <= 1
                    t = 0;
                end
            end

            j = j + 1; % Increase index
        end
        if t == 1
            Inds(i) = 1;
        end
    end
    c = nnz(Inds) / (nS1 * nS2);
end
warning          ('on', 'all')

