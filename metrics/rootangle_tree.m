% ROOTANGLE_TREE   Angle values between tree segments and line to root.
% (trees package)
%
% rootangle = rootangle_tree (intree, options)
% --------------------------------
%
% Returns for each node the angle between its segment and the straight line
% to the root.
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% -------
% - rootangle ::Nx1 vector: Raw rootangles for each segment
%
% Example
% -------
% rootangle_tree (sample_tree, '-s')
%
% See also vonMises_tree
% Uses cyl_tree ver_tree resample_tree
%
% Contributed by Alexander Bird (modified for TREES)
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2020  Hermann Cuntz

function [rootangle] = rootangle_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

ver_tree     (intree); % verify that input is a tree structure


rtree        = resample_tree (intree, 1);
%------------------ Get pure root angles ----------------------------------

[X1, X2, Y1, Y2, Z1, Z2]         = cyl_tree (rtree);
dX           = X2 - X1;
dY           = Y2 - Y1;
dZ           = Z2 - Z1;
eucl         = sqrt (dX.^2 + dY.^2 + dZ.^2);

dX           = dX ./ eucl;
dY           = dY ./ eucl;
dZ           = dZ ./ eucl;

eucl         = sqrt (X2.^2 + Y2.^2 + Z2.^2);
X2           = X2 ./ eucl;
Y2           = Y2 ./ eucl;
Z2           = Z2 ./ eucl;

rootangle    = zeros (length (X1), 1);
for counter  = 1 : length (X1)
    rootangle (counter)  = acos ( ...
        [(dX (counter)) (dY (counter)) (dZ (counter))] * ...
        [(X2 (counter)) (Y2 (counter)) (Z2 (counter))]');
end

rootangle (isnan (rootangle)) = 0;
rootangle    = real (rootangle);

if strcmp (options, '-s')
    AngV     = linspace   (0, pi, 25);
    pdf      = histcounts (rootangle, AngV);
    mAngV    = (AngV (2 : 25) + AngV (1 : 24)) / 2; % Get midpoints
    clf; hold on;
    plot     (mAngV, pdf / trapz (mAngV, pdf), 'black')
    xlim     ([0 pi]);
    xlabel   ('Angle');
    ylabel   ('Density');
end



