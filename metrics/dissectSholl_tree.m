% DISSECTSHOLL_TREE Dissects Sholl intersection profile of a tree.
% (trees package)
%
% [Output] = dissectSholl_tree (intree, options, c)
% -------------------------------------------------
%
% Returns a dissected Sholl intersection profile structure (see Bird and
% Cuntz 2018)
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options  ::string: {DEFAULT: '-3d -a}
%     '-3d'  : three-dimensional dendrite
%     '-2d'  : two-dimensional (planar) dendrite
%      '-a'  : using correction for centripetal bias
%      '-d'  : spanning domain only
%      '-n'  : spanning domain and non-uniform density
%      '-s'  : plot dissected SIPs
% - c        ::convexity of intree:
%      {DEFAULT: calculated using convexity_tree}
%
% Output
% ------
% Output ::structure: Structure that can contain the following fields:
%    'c'     : convexity of intree (if not specified)
%    'V'     : volume (area in 2d) of boundary
%    'tL'    : total length of tree
%   'tScale' : integral of true Sholl profile
%    'RVec'  : radius vector where Sholl values are evaluated and estimated
%   'STrue'  : normalised observed Sholl profile
%    'SDom'  : normalised Sholl profile estimated from the spanning domain
%    'SAng'  : normalised Sholl profile estimated from both the spanning domain
%  and centripetal bias (if options contain '-a')
%   'SDens'  : normalised Sholl profile estimated from the spanning domain
% and (nonuniform) density of branch points (if options contain '-n')
% 'rootangle': rootangles of intree (if options contain '-a')
%     'k'    : centripetal bias of intree (if options contain '-a')
%     'bf'   : estimated balancing factor  (if options contain '-a')
% 'estScale' : estimated integral of Sholl profile (if options contain '-a')
%   'ErrDom' : error of domain-based estimation
%   'ErrAng' : error of estimation accounting for centripetal bias (if options contain '-a')
%  'ErrDens' : error of non-uniform density estimation (if options contain '-n')
%
% Example
% -------
% Output = dissectSholl_tree (sample_tree, '-3d -a')
%
% This function was contributed by Alex D Bird, 2018
%
% See also convexity_tree boundary_tree vonMises_tree sholl_tree
% Uses convexity_tree boundary_tree vonMises_tree sholl_tree bf_tree
% len_tree tran_tree eucl_tree
% Requires: Curve fitting toolbox
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009 - 2023 Hermann Cuntz

function Output = dissectSholl_tree(intree, options, c)

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 2) || isempty(options)
    % {DEFAULT: three dimensional with centripetal bias correction}
    options = '-3d -a';
end

if (nargin < 3) || isempty(c)
    % {DEFAULT: convexity unknown}
    c = convexity_tree(intree, options);
    Output.c = c;
end

thetRes = 1000000; % Test points along each radius
RRes = 25; % Radial resolution of SIP
Ls               = len_tree (intree);
tL = sum(Ls(:)); % Get total length of tree
Output.TotalLength = tL;
sf = 1;
ttree = tran_tree(intree); % Move tree to have root at origin

if contains(options, '-2d')
    %==========================================================================
    %==========================================================================
    % Planar neuron
    %==========================================================================
    %==========================================================================

    bound = boundary_tree(ttree, '-2d', c);
    xv = bound.xv;
    yv = bound.yv;
    V = bound.V;

    %--------------- True Sholl -----------------------

    eucs = eucl_tree(ttree);
    rmax = max(eucs(:));
    RVec = linspace(0, rmax, RRes);

    [Strue] = sholl_tree(ttree, 2*RVec); % Real Sholl

    %------------- Just spanning field -----------------

    SDom = zeros(RRes, 1);
    for i = 2:RRes
        R = RVec(i);
        thetRand = 2 * pi * rand(thetRes, 1);
        [x, y] = pol2cart(thetRand, R*ones(thetRes, 1));

        Is = inpolygon(x, y, xv, yv);
        SDom(i) = 2 * pi * R * nnz(Is(:)) / thetRes;
    end
    SDom(isnan(SDom)) = 0;
    Strue(isnan(Strue)) = 0;

    scale = trapz(RVec, Strue);
    SDomNorm = SDom / trapz(RVec, SDom);
    StrueNorm = Strue / trapz(RVec, Strue);

    Output.V = V;
    Output.tScale = scale;
    Output.STrue = StrueNorm;
    Output.RVec = RVec;
    Output.SDom = SDomNorm;

    if contains(options, '-a')
        %==========================================================================
        %==========================================================================
        % Account for centripetal bias
        %==========================================================================
        %==========================================================================

        [rootangle] = rootangle_tree(intree, '-2d'); % Calculate root angles
        [bf, k] = bf_tree(rootangle, '-2d'); % Estimate centripetal bias and balancing factor
        Output.bf = bf;

        bp = sqrt(tL^3*4/(3 * pi * V)); % Estimated number of branch points
        S = tL / (bp); % Estimated branch length

        x = RVec;
        y = SDomNorm;

        tV = linspace(0, pi, 25);
        rVraw = hist(rootangle, tV);
        rVraw(1) = rVraw(2) + (rVraw(2) - rVraw(3));
        rV = rVraw / trapz(tV, rVraw);
        S = S * max(rV(:));

        tVi = tV(rV > 0);
        rVi = rV(rV > 0);

        [X, Y] = pol2cart(tVi, S*rVi);

        X = X(end:(-1):1);
        Y = Y(end:(-1):1);
        Xmin = min(X(:));
        Xmax = max(X(:));


        X2 = linspace(Xmin(1), Xmax(1), 1000);
        Y2 = interp1(X, Y, X2); % Smooth out values

        N = length(x);
        z = zeros(N, 1);
        for i = 1:N
            rRange = linspace(x(i)+Xmin, x(i)+Xmax, 1000);

            zRange = interp1(x, y, rRange, 'spline', 0);
            iGrand = trapz(X2, zRange.*Y2);

            z(i) = iGrand;
        end
        z(N) = y(N);

        z = z / trapz(x, z);
        z = z + y;
        SAngNorm = z / trapz(x, z);

        Output.SDom = SDomNorm;
        Output.SAng = SAngNorm;
        Output.rootangle = rootangle;
        Output.k = k;
    end
elseif contains(options, '-3d')
    %==========================================================================
    %==========================================================================
    % 3D neuron
    %==========================================================================
    %==========================================================================
    bound = boundary_tree(ttree, '-3d', c); % Get boundary

    %--------------- True Sholl -----------------------
    eucs = eucl_tree(ttree);
    rmax = max(eucs(:));
    if rmax > 500
        sf = 2;
    end
    RVec = linspace(0, rmax, RRes);

    [Strue] = sholl_tree(ttree, 2*RVec); % Real Sholl
    %------------- Just spanning field -----------------
    SDom = zeros(RRes, 1);
    for i = 2:RRes
        R = RVec(i);
        thetRand = 2 * pi * rand(thetRes, 1);
        phiRand = acos(1-2*rand(thetRes, 1));
        [x, y, z] = sph2cart(thetRand, pi/2-phiRand, R*ones(thetRes, 1));
        Is = intriangulation(bound.Vertices, bound.Faces, [x, y, z]);
        SDom(i) = R^2 * 4 * pi * nnz(Is(:)) / thetRes;
    end
    SDom(isnan(SDom)) = 0;
    Strue(isnan(Strue)) = 0;
    scale = trapz(RVec, Strue);

    SDomNorm = SDom / trapz(RVec, SDom);
    StrueNorm = Strue / trapz(RVec, Strue);


    Output.V = bound.V;
    Output.tScale = scale;
    Output.STrue = StrueNorm;
    Output.RVec = RVec;
    Output.SDom = SDomNorm;

    if contains(options, '-a')
        %==========================================================================
        %==========================================================================
        % Account for centripetal bias
        %==========================================================================
        %==========================================================================
        [rootangle] = rootangle_tree(intree, '-3d'); % Calculate root angles
        [bf, k] = bf_tree(rootangle, '-3d'); % Estimate centripetal bias and balancing factor
        Output.bf = bf;


        bp = sqrt(tL^3/(3 * pi * bound.V)); % Estimated number of branch points
        S = sf * tL / (bp); % Estimated branch length

        x = RVec;
        y = SDomNorm;

        tV = linspace(0, pi, 25);
        rVraw = hist(rootangle, tV);
        rV = rVraw / trapz(tV, rVraw);

        tVi = tV(rV > 0);
        rVi = rV(rV > 0);

        [X, Y] = pol2cart(tVi, S*rVi);

        X = X(end:(-1):1);
        Y = Y(end:(-1):1);
        Xmin = min(X(:));
        Xmax = max(X(:));


        X2 = linspace(Xmin(1), Xmax(1), 1000);
        Y2 = interp1(X, Y, X2); % Smooth out values

        N = length(x);
        z = zeros(N, 1);
        for i = 1:N
            rRange = linspace(x(i)+Xmin, x(i)+Xmax, 1000);

            zRange = interp1(x, y, rRange, 'spline', 0);
            iGrand = trapz(X2, zRange.*Y2);

            z(i) = iGrand;
        end
        z(N) = y(N);

        z = z / trapz(x, z);
        z = z + y;
        SAngNorm = z / trapz(x, z);


        Output.SDom = SDomNorm;
        Output.SAng = SAngNorm;
        Output.rootangle = rootangle;
        Output.k = k;
    end
else
    error('Incorrect options')
end

if contains(options, '-n') % Nonuniform density
    [bDens] = density_tree(ttree, RVec);
    SDensNorm = 0.5 * (bDens / trapz(RVec, bDens) + SDomNorm');
    Output.SDens = SDensNorm;
end

if contains(options, '-a')
    estScale = Estscale(rootangle, tL); % Estimate scale of SIP
    Output.EstScale = estScale;
end

ErrDom = sqrt(trapz(RVec(:), (SDomNorm(:) - StrueNorm(:)).^2));
Output.ErrDom = ErrDom;

if contains(options, '-a')
    ErrAng = sqrt(trapz(RVec(:), (SAngNorm(:) - StrueNorm(:)).^2));
    Output.ErrAng = ErrAng;
end

if contains(options, '-n') % Nonuniform density
    ErrDens = sqrt(trapz(RVec(:), (SDensNorm(:) - StrueNorm(:)).^2));
    Output.ErrDens = ErrDens;
end

if contains(options, '-s') % Plot results
    figure
    hold
    plot(RVec, scale*StrueNorm, 'black') % Plot true Sholl
    strleg = "Observed Sholl";
    if (nargin < 3) || isempty(c)
        plot(RVec, scale*SDomNorm, 'red') % Plot tight boundary
    else
        plot(RVec, scale*SDomNorm, 'cyan') % Plot possibly non-fitted boundary
    end
    strleg = [strleg, "Spanning domain"];
    if contains(options, '-a')
        plot(RVec, scale*SAngNorm, 'magenta') % Plot correction for centripetal bias
        strleg = [strleg, "Centripetal bias"];
    end
    if contains(options, '-n')
        plot(RVec, scale*SDensNorm, 'green') % Plot non-uniform density
        strleg = [strleg, "Nonuniform density"];
    end
    legend(strleg)
    xlabel('Distance')
    ylabel('Number of intersections')
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function in = intriangulation(vertices, faces, testp)
% intriangulation: Tests whether points lie inside a triangulated boundary
% (internal function, adapted from function written by Johannes Korsawe (2013) for Matlab File Exchange).
meshXYZ = zeros(size(faces, 1), 3, 3);
for loop = 1:3
    meshXYZ(:, :, loop) = vertices(faces(:, loop), :);
end

[in, cl] = voxelise(testp(:, 1), testp(:, 2), testp(:, 3), meshXYZ);
[in2, cl2] = voxelise(testp(cl, 2), testp(cl, 3), testp(cl, 1), meshXYZ(:, [2, 3, 1], :));
in(cl(in2 == 1)) = 1;
cl = cl(cl2);
[in3, cl3] = voxelise(testp(cl, 3), testp(cl, 1), testp(cl, 2), meshXYZ(:, [3, 1, 2], :));
in(cl(in3 == 1)) = 1;
cl = cl(cl3);
in(cl) = -1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [OUTPUT, correctionLIST] = voxelise(testx, testy, testz, meshXYZ)
OUTPUT = false(size(testx, 1), 1);
meshZmin = min(min(meshXYZ(:, 3, :)));
meshZmax = max(max(meshXYZ(:, 3, :)));
meshXYZmin = min(meshXYZ, [], 3);
meshXYZmax = max(meshXYZ, [], 3);
correctionLIST = [];
facetCROSSLIST = zeros(1, 1e3);
for loop = 1:length(OUTPUT)
    nf = 0;
    possibleCROSSLISTy = find((testy(loop) - meshXYZmin(:, 2)).*(meshXYZmax(:, 2) - testy(loop)) > 0);
    possibleCROSSLISTx = (testx(loop) - meshXYZmin(possibleCROSSLISTy, 1)) .* (meshXYZmax(possibleCROSSLISTy, 1) - testx(loop)) > 0;
    possibleCROSSLIST = possibleCROSSLISTy(possibleCROSSLISTx);
    if isempty(possibleCROSSLIST) == 0
        for loopCHECKFACET = possibleCROSSLIST'
            Y1predicted = meshXYZ(loopCHECKFACET, 2, 2) - ((meshXYZ(loopCHECKFACET, 2, 2) - meshXYZ(loopCHECKFACET, 2, 3)) * (meshXYZ(loopCHECKFACET, 1, 2) - meshXYZ(loopCHECKFACET, 1, 1)) / (meshXYZ(loopCHECKFACET, 1, 2) - meshXYZ(loopCHECKFACET, 1, 3)));
            YRpredicted = meshXYZ(loopCHECKFACET, 2, 2) - ((meshXYZ(loopCHECKFACET, 2, 2) - meshXYZ(loopCHECKFACET, 2, 3)) * (meshXYZ(loopCHECKFACET, 1, 2) - testx(loop)) / (meshXYZ(loopCHECKFACET, 1, 2) - meshXYZ(loopCHECKFACET, 1, 3)));
            if (Y1predicted > meshXYZ(loopCHECKFACET, 2, 1) && YRpredicted > testy(loop)) || (Y1predicted < meshXYZ(loopCHECKFACET, 2, 1) && YRpredicted < testy(loop)) || (meshXYZ(loopCHECKFACET, 2, 2) - meshXYZ(loopCHECKFACET, 2, 3)) * (meshXYZ(loopCHECKFACET, 1, 2) - testx(loop)) == 0
            else
                continue;
            end
            Y2predicted = meshXYZ(loopCHECKFACET, 2, 3) - ((meshXYZ(loopCHECKFACET, 2, 3) - meshXYZ(loopCHECKFACET, 2, 1)) * (meshXYZ(loopCHECKFACET, 1, 3) - meshXYZ(loopCHECKFACET, 1, 2)) / (meshXYZ(loopCHECKFACET, 1, 3) - meshXYZ(loopCHECKFACET, 1, 1)));
            YRpredicted = meshXYZ(loopCHECKFACET, 2, 3) - ((meshXYZ(loopCHECKFACET, 2, 3) - meshXYZ(loopCHECKFACET, 2, 1)) * (meshXYZ(loopCHECKFACET, 1, 3) - testx(loop)) / (meshXYZ(loopCHECKFACET, 1, 3) - meshXYZ(loopCHECKFACET, 1, 1)));
            if (Y2predicted > meshXYZ(loopCHECKFACET, 2, 2) && YRpredicted > testy(loop)) || (Y2predicted < meshXYZ(loopCHECKFACET, 2, 2) && YRpredicted < testy(loop)) || (meshXYZ(loopCHECKFACET, 2, 3) - meshXYZ(loopCHECKFACET, 2, 1)) * (meshXYZ(loopCHECKFACET, 1, 3) - testx(loop)) == 0
            else
                continue;
            end
            Y3predicted = meshXYZ(loopCHECKFACET, 2, 1) - ((meshXYZ(loopCHECKFACET, 2, 1) - meshXYZ(loopCHECKFACET, 2, 2)) * (meshXYZ(loopCHECKFACET, 1, 1) - meshXYZ(loopCHECKFACET, 1, 3)) / (meshXYZ(loopCHECKFACET, 1, 1) - meshXYZ(loopCHECKFACET, 1, 2)));
            YRpredicted = meshXYZ(loopCHECKFACET, 2, 1) - ((meshXYZ(loopCHECKFACET, 2, 1) - meshXYZ(loopCHECKFACET, 2, 2)) * (meshXYZ(loopCHECKFACET, 1, 1) - testx(loop)) / (meshXYZ(loopCHECKFACET, 1, 1) - meshXYZ(loopCHECKFACET, 1, 2)));
            if (Y3predicted > meshXYZ(loopCHECKFACET, 2, 3) && YRpredicted > testy(loop)) || (Y3predicted < meshXYZ(loopCHECKFACET, 2, 3) && YRpredicted < testy(loop)) || (meshXYZ(loopCHECKFACET, 2, 1) - meshXYZ(loopCHECKFACET, 2, 2)) * (meshXYZ(loopCHECKFACET, 1, 1) - testx(loop)) == 0
            else
                continue;
            end
            nf = nf + 1;
            facetCROSSLIST(nf) = loopCHECKFACET;
        end
        facetCROSSLIST = facetCROSSLIST(1:nf);
        gridCOzCROSS = zeros(1, nf);
        for loopFINDZ = facetCROSSLIST
            planecoA = meshXYZ(loopFINDZ, 2, 1) * (meshXYZ(loopFINDZ, 3, 2) - meshXYZ(loopFINDZ, 3, 3)) + meshXYZ(loopFINDZ, 2, 2) * (meshXYZ(loopFINDZ, 3, 3) - meshXYZ(loopFINDZ, 3, 1)) + meshXYZ(loopFINDZ, 2, 3) * (meshXYZ(loopFINDZ, 3, 1) - meshXYZ(loopFINDZ, 3, 2));
            planecoB = meshXYZ(loopFINDZ, 3, 1) * (meshXYZ(loopFINDZ, 1, 2) - meshXYZ(loopFINDZ, 1, 3)) + meshXYZ(loopFINDZ, 3, 2) * (meshXYZ(loopFINDZ, 1, 3) - meshXYZ(loopFINDZ, 1, 1)) + meshXYZ(loopFINDZ, 3, 3) * (meshXYZ(loopFINDZ, 1, 1) - meshXYZ(loopFINDZ, 1, 2));
            planecoC = meshXYZ(loopFINDZ, 1, 1) * (meshXYZ(loopFINDZ, 2, 2) - meshXYZ(loopFINDZ, 2, 3)) + meshXYZ(loopFINDZ, 1, 2) * (meshXYZ(loopFINDZ, 2, 3) - meshXYZ(loopFINDZ, 2, 1)) + meshXYZ(loopFINDZ, 1, 3) * (meshXYZ(loopFINDZ, 2, 1) - meshXYZ(loopFINDZ, 2, 2));
            planecoD = -meshXYZ(loopFINDZ, 1, 1) * (meshXYZ(loopFINDZ, 2, 2) * meshXYZ(loopFINDZ, 3, 3) - meshXYZ(loopFINDZ, 2, 3) * meshXYZ(loopFINDZ, 3, 2)) - meshXYZ(loopFINDZ, 1, 2) * (meshXYZ(loopFINDZ, 2, 3) * meshXYZ(loopFINDZ, 3, 1) - meshXYZ(loopFINDZ, 2, 1) * meshXYZ(loopFINDZ, 3, 3)) - meshXYZ(loopFINDZ, 1, 3) * (meshXYZ(loopFINDZ, 2, 1) * meshXYZ(loopFINDZ, 3, 2) - meshXYZ(loopFINDZ, 2, 2) * meshXYZ(loopFINDZ, 3, 1));
            if abs(planecoC) < 1e-14
                planecoC = 0;
            end
            gridCOzCROSS(facetCROSSLIST == loopFINDZ) = (-planecoD - planecoA * testx(loop) - planecoB * testy(loop)) / planecoC;
        end
        if isempty(gridCOzCROSS), continue; end
        gridCOzCROSS = gridCOzCROSS(gridCOzCROSS >= meshZmin-1e-12 & gridCOzCROSS <= meshZmax+1e-12);
        gridCOzCROSS = round(gridCOzCROSS*1e10) / 1e10;
        tmp = sort(gridCOzCROSS);
        I = [0, tmp(2:end) - tmp(1:end-1)] ~= 0;
        gridCOzCROSS = [tmp(1), tmp(I)];
        if rem(numel(gridCOzCROSS), 2) == 0
            for loopASSIGN = 1:(numel(gridCOzCROSS) / 2)
                voxelsINSIDE = (testz(loop) > gridCOzCROSS(2*loopASSIGN-1) & testz(loop) < gridCOzCROSS(2*loopASSIGN));
                OUTPUT(loop) = voxelsINSIDE;
                if voxelsINSIDE, break; end
            end
        elseif numel(gridCOzCROSS) ~= 0
            correctionLIST = [correctionLIST; loop];
        end
    end
end
return
countCORRECTIONLIST = size(correctionLIST, 1);
if countCORRECTIONLIST > 0
    if min(correctionLIST(:, 1)) == 1 || max(correctionLIST(:, 1)) == numel(gridCOx) || min(correctionLIST(:, 2)) == 1 || max(correctionLIST(:, 2)) == numel(gridCOy)
        gridOUTPUT = [zeros(1, voxcountY+2, voxcountZ); zeros(voxcountX, 1, voxcountZ), gridOUTPUT, zeros(voxcountX, 1, voxcountZ); zeros(1, voxcountY+2, voxcountZ)];
        correctionLIST = correctionLIST + 1;
    end
    for loopC = 1:countCORRECTIONLIST
        voxelsforcorrection = squeeze(sum([gridOUTPUT(correctionLIST(loopC, 1)-1, correctionLIST(loopC, 2)-1, :), ...
            gridOUTPUT(correctionLIST(loopC, 1)-1, correctionLIST(loopC, 2), :), ...
            gridOUTPUT(correctionLIST(loopC, 1)-1, correctionLIST(loopC, 2)+1, :), ...
            gridOUTPUT(correctionLIST(loopC, 1), correctionLIST(loopC, 2)-1, :), ...
            gridOUTPUT(correctionLIST(loopC, 1), correctionLIST(loopC, 2)+1, :), ...
            gridOUTPUT(correctionLIST(loopC, 1)+1, correctionLIST(loopC, 2)-1, :), ...
            gridOUTPUT(correctionLIST(loopC, 1)+1, correctionLIST(loopC, 2), :), ...
            gridOUTPUT(correctionLIST(loopC, 1)+1, correctionLIST(loopC, 2)+1, :), ...
            ]));
        voxelsforcorrection = (voxelsforcorrection >= 4);
        gridOUTPUT(correctionLIST(loopC, 1), correctionLIST(loopC, 2), voxelsforcorrection) = 1;
    end
    if size(gridOUTPUT, 1) > numel(gridCOx) || size(gridOUTPUT, 2) > numel(gridCOy)
        gridOUTPUT = gridOUTPUT(2:end-1, 2:end-1, :);
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[tDens] = density_tree(intree, RVec)
% Gets density profile of branch points as afunction of radius
Tops = B_tree(intree);
Tops = Tops == 1;

eucl = eucl_tree(intree); % Euclidean distances to root
tDens = hist(eucl(Tops), RVec); % Density profile
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[estScale] = Estscale(rootangle, tL)
% Estimates magnitude of SIP from total length and rootangle distribution.
AngVec = linspace(0, pi, 25);
rVraw = hist(rootangle, AngVec);
rVraw(1) = rVraw(2) + (rVraw(2) - rVraw(3));
rV = rVraw / trapz(AngVec, rVraw);

Ig = abs(cos(AngVec).*rV);
estScale = tL * (trapz(AngVec, Ig));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%