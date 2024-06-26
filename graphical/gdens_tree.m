% GDENS_TREE   Density matrix of a tree.
% (trees package)
%
% [M, dX, dY, dZ, HP] = gdens_tree (intree, sr, ipart, options)
% -------------------------------------------------------------
%
% Calculates a density matrix of nodes in the tree intree. Uses isosurface
% to display the resulting gradient and increases opacity with density.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
%       alternatively, intree can be a Nx3 matrix XYZ of points
% - sr       ::scalar:       spatial resolution in um
%     {DEFAULT: 5 um}
% - ipart    ::index:        index to the subpart to be considered
%     {DEFAULT: all nodes}
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: '-s'}
%
% Output
% ------
% - M        ::matrix:       3D matrix containing node density for each bin
% - dX       ::vector:       X-pos at which density was measured (in a bin)
% - dY       ::vector:       Y-pos at which density was measured (in a bin)
% - dZ       ::vector:       Z-pos at which density was measured (in a bin)
% - HP       ::handles:      links to the graphical objects.
%
% Example
% -------
% gdens_tree   (sample_tree, 20)
%
% See also   lego_tree
% Uses       ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [M, dX, dY, dZ, HP] = gdens_tree (intree, varargin)

% use only node position for this function
if isnumeric (intree)
    X        = intree (:, 1);
    Y        = intree (:, 2);
    Z        = intree (:, 3);
else
    ver_tree (intree); % verify that input is a tree structure
    X        = intree.X;
    Y        = intree.Y;
    Z        = intree.Z;
end

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('sr', 5)
p.addParameter('ipart', (1 : length (X))')
p.addParameter('s', true, @isBinary)
pars = parseArgs(p, varargin, {'sr', 'ipart'}, {'s'});
%==============================================================================%

X                = X   (pars.ipart);
Y                = Y   (pars.ipart);
Z                = Z   (pars.ipart);
dX               = min (X) - 2 * pars.sr : pars.sr : max (X) + 2 * pars.sr;
dY               = min (Y) - 2 * pars.sr : pars.sr : max (Y) + 2 * pars.sr;
dZ               = min (Z) - 2 * pars.sr : pars.sr : max (Z) + 2 * pars.sr;
M                = zeros ( ...
    length  (dY), ...
    length  (dX), ...
    length  (dZ));
iX               = ...
    (repmat (X, 1, length (dX)) <  repmat (dX + pars.sr, length (X), 1)) & ...
    (repmat (X, 1, length (dX)) >= repmat (dX,      length (X), 1));
iY               = ...
    (repmat (Y, 1, length (dY)) <  repmat (dY + pars.sr, length (Y), 1)) & ...
    (repmat (Y, 1, length (dY)) >= repmat (dY,      length (Y), 1));
iZ               = ...
    (repmat (Z, 1, length (dZ)) <  repmat (dZ + pars.sr, length (Z), 1)) & ...
    (repmat (Z, 1, length (dZ)) >= repmat (dZ,      length (Z), 1));
iX               = sum (iX .* repmat (1 : length (dX), length (X), 1), 2);
iY               = sum (iY .* repmat (1 : length (dY), length (Y), 1), 2);
iZ               = sum (iZ .* repmat (1 : length (dZ), length (Z), 1), 2);
indx             = sub2ind (size (M), iY, iX, iZ);
uindx            = unique  (indx);
dX               = dX + pars.sr / 2;
dY               = dY + pars.sr / 2;
dZ               = dZ + pars.sr / 2;
M (uindx)        = histc (indx, uindx);
if pars.s
    hold         on;
    minM         = min (min (min (M)));
    maxM         = max (max (max (M)));
    HP           = zeros (1, 11);
    counter      = 1;
    for counterM = minM : (maxM - minM) / 10 : maxM
        c        = isosurface (dX, dY, dZ, M, counterM);
        HP (counter) = patch  (c, ...
            'FaceVertexCData', counterM, ...
            'facecolor',       'flat');
        % transparency expresses density:
        taux     = 0.3;
        trans    = exp ( ...
            -(1 - (((counterM - minM) ./ (maxM - minM)))) ./ ...
            taux);
        set      (HP (counter), ...
            'EdgeColor',       'none', ...
            'facealpha',       trans - 0.00001);
        counter  = counter + 1;
    end
    if sum (get (gca, 'Dataaspectratio') == [1 1 1]) ~= 3
        axis     equal
    end
else
    HP           = [];
end

