% sharedvol_trees
% Calculates the shared volume of two trees with voxelization of the two hulls.
% Also the length of the trees inside the shared volume are calculated.
%
% CAREFULL tree must be resampled
% Uses boundary_tree VOXELIZE voxel_tree
%
%   input
% ---------
% -intree1 :tree:: 		first input tree
% -intree2 :tree:: 		second input tree
% - grid   :scalar::	voxelsize ( default 1)
% - shrink :scalar::    shrink factor for boundary function (0 to 1) (default 1)
% - options :string:: 	'-r' resample trees to 1
%
%  output
%----------
% - sharedVol :scalar:: shared Volume
% - Vol1 	  :scalar:: volume of intree1
% - Vol2 	  :scalar:: volume of intree2
% - Len1 	  :scalar:: cable length of intree1
% - Len2 	  :scalar:: cable length of intree2
%
%
function [sharedVol, Len1, Len2] = share_boundary_tree(intree1, intree2, varargin)

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('r', true, @isBinary)
pars = parseArgs(p, varargin, {}, {'r'});
%==============================================================================%

if pars.r
    tree1 = resample_tree(intree1, 1);
    tree2 = resample_tree(intree2, 1);
else
    tree1 = intree1;
    tree2 = intree2;
end

c1               = convexity_tree (intree1);
c2               = convexity_tree (intree2);

bound1           = boundary_tree(intree1, 'c', c1); % Get boundary
bound2           = boundary_tree(intree2, 'c', c2); % Get boundary


x1 = tree1.X;
y1 = tree1.Y;
z1 = tree1.Z;
x2 = tree2.X;
y2 = tree2.Y;
z2 = tree2.Z;


Is1in2 = intriangulation(bound2.Vertices, bound2.Faces, [x1, y1, z1]);
Is2in1 = intriangulation(bound1.Vertices, bound1.Faces, [x2, y2, z2]);

Len1 = nnz(Is1in2) * mean(len_tree(tree1));
Len2 = nnz(Is2in1) * mean(len_tree(tree2));

X = [x1(Is1in2); x2(Is2in1)];
Y = [y1(Is1in2); y2(Is2in1)];
Z = [z1(Is1in2); z2(Is2in1)];


% [c]=convexity_set(X,Y,Z)
[~, sharedVol] = boundary(X, Y, Z, 1-(c1 + c2)/2);
end

%==============================================================================%
%==============================================================================%
function in = intriangulation(vertices, faces, testp)
% intriangulation: Tests whether points lie inside a triangulated boundary
% (internal function, adapted from function written by Johannes Korsawe (2013) 
% for Matlab File Exchange).
meshXYZ = zeros(size(faces, 1), 3, 3);
for loop = 1:3
    meshXYZ(:, :, loop) = vertices(faces(:, loop), :);
end

[in, cl]   = voxelise(testp(:, 1), testp(:, 2), testp(:, 3), ...
    meshXYZ);
[in2, cl2] = voxelise(testp(cl, 2), testp(cl, 3), testp(cl, 1), ...
    meshXYZ(:, [2, 3, 1], :));
in(cl(in2 == 1)) = 1;
cl = cl(cl2);
[in3, cl3] = voxelise(testp(cl, 3), testp(cl, 1), testp(cl, 2), ...
    meshXYZ(:, [3, 1, 2], :));
in(cl(in3 == 1)) = 1;
cl = cl(cl3);
in(cl) = -1;
end
%==============================================================================%
function [OUTPUT, correctionLIST] = voxelise(testx, testy, testz, meshXYZ)
OUTPUT         = false(size(testx, 1), 1);
meshZmin       = min(min(meshXYZ(:, 3, :)));
meshZmax       = max(max(meshXYZ(:, 3, :)));
meshXYZmin     = min(meshXYZ, [], 3);
meshXYZmax     = max(meshXYZ, [], 3);
correctionLIST = [];
facetCROSSLIST = zeros(1, 1e3);
for loop = 1:length(OUTPUT)
    nf = 0;
    possibleCROSSLISTy = find((testy(loop) - meshXYZmin(:, 2)).*(meshXYZmax(:, 2) - testy(loop)) > 0);
    possibleCROSSLISTx = (testx(loop) - meshXYZmin(possibleCROSSLISTy, 1)) .* (meshXYZmax(possibleCROSSLISTy, 1) - testx(loop)) > 0;
    possibleCROSSLIST  = possibleCROSSLISTy(possibleCROSSLISTx);
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
%==============================================================================%
function c = convexity_set(X, Y, Z)

warning('off', 'all')
[k, V] = boundary(X, Y, Z, 0);

figure
F = gcf;
h = trisurf(k, X, Y, Z);
[rh] = reducepatch(h, 0.5);
rh.Vertices = rh.vertices;
rh.Faces = rh.faces;
bound = rh;
bound.V = V;
close(F)

S1 = [X, Y, Z]; % Probability source points
S2 = [X, Y, Z]; % Probability sinkpoints

nS1 = size(S1, 1);
nS2 = size(S2, 1);

sV1 = 1:nS1;
sV2 = 1:nS2;
[sM1, sM2] = meshgrid(sV1, sV2);
sA1 = sM1(:);
sA2 = sM2(:); % Indices of vector pairs

TriPoints = bound.Vertices; % Points of triangles
TriFaces = bound.Faces; % Indices of faces
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
        M = [va(1) - vb(1), v1(1) - v0(1), v2(1) - v0(1), va(2) - vb(2), v1(2) - v0(2), v2(2) - v0(2), va(3) - vb(3), v1(3) - v0(3), v2(3) - v0(3)];
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
warning('on', 'all')
end
%==============================================================================%