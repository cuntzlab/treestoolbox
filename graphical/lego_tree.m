% LEGO_TREE   Lego density plot of a tree.
% (trees package)
%
% [HP, M] = lego_tree (intree, sr, thr, options)
% ----------------------------------------------
%
% Uses "gdens_tree" to plot the density matrix of points in a tree.
% Opacity and colors increase with density.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - sr       ::scalar:       spatial resolution in um
% - thr      ::0..1:         threshold value in percentage of maximum in M
% - options  ::string:
%     '-e'   : edge
%     '-f'   : no face transparency
%     {DEFAULT: ''}
%
% Output
% ------
% - HP       ::handle:       patch elements
%     note that default facealpha is 0.2
% - M        ::matrix:       3D matrix containing density measure
%     for each bin (from "gdens_tree")
%
% Example
% -------
% lego_tree    (sample_tree, 15); view (3)
%
% See also
% Uses       gdens_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [HP, M] = lego_tree (intree, sr, thr, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (sr)
    % {DEFAULT value: 50 um sampling}
    sr       = 50;
end

if (nargin < 3) || isempty (thr)
    % {DEFAULT value: no thresholding}
    thr      = 0;
end

if (nargin < 4) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

[M, dX, dY, dZ]  = gdens_tree (intree, sr, [], 'none');

% cube
cX               = [ ...
    0 0 0 0; ...
    0 1 1 0; ...
    0 1 1 0; ...
    1 1 0 0; ...
    1 1 0 0; ...
    1 1 1 1] - 0.5;
cY               = [ ...
    0 0 1 1; ...
    0 0 1 1; ...
    1 1 1 1; ...
    0 1 1 0; ...
    0 0 0 0; ...
    0 0 1 1] - 0.5;
cZ               = [ ...
    0 1 1 0; ...
    0 0 0 0; ...
    1 1 0 0; ...
    1 1 1 1; ...
    1 0 0 1; ...
    0 1 1 0] - 0.5;

% cylinder
res              = 8;
xX               = [ ...
    (cos (0            : 2 * pi / res : (2 * pi - 2 * pi / res))') ...
    (cos (2 * pi / res : 2 * pi / res :  2 * pi)')...
    (cos (2 * pi / res : 2 * pi / res :  2 * pi)')...
    (cos (0            : 2 * pi / res : (2 * pi - 2 * pi / res))')] / 2;
xY               = [ ...
    (sin (0            : 2 * pi / res : (2 * pi - 2 * pi / res))') ...
    (sin (2 * pi / res : 2 * pi / res :  2 * pi)')...
    (sin (2 * pi / res : 2 * pi / res :  2 * pi)')...
    (sin (0            : 2 * pi / res : (2 * pi - 2 * pi / res))')] / 2;
xZ               = repmat ([1 1 0 0], res, 1) - 0.5;
sc               = mean   (diff (dX));      % scaling factor
% unity cube :     p = patch (cX',cY',cZ',[0 0 0]);
% unity cylinder : p = patch (xX',xY',xZ',[0 0 0]);

uM               = unique (M);
uM               = uM (uM > thr .* max (uM));
nM               = uM - min (uM);
if nM            == 0
    nM           = 1;
else
    nM           = nM ./ max (nM);
end

HP               = [];
hold             on;
for counter      = 1 : length (uM)
    [Y, X, Z]    = ind2sub (size (M), find (M == uM (counter)));
    for counterX = 1 : length (X)
        x        = dX (X (counterX));
        y        = dY (Y (counterX));
        z        = dZ (Z (counterX));
        len      = 1;
        p        = zeros (5, 1);

        % cubes
        xc       = repmat (x, 1, 6);
        xc       = repmat (reshape (xc', numel (xc), 1), 1, 4);
        yc       = repmat (y, 1, 6);
        yc       = repmat (reshape (yc', numel (yc), 1), 1, 4);
        zc       = repmat (z, 1, 6);
        zc       = repmat (reshape (zc', numel (zc), 1), 1, 4);

        SX       = repmat (sc .* cX, len, 1) + xc;
        SY       = repmat (sc .* cY, len, 1) + yc;
        SZ       = repmat (sc .* cZ, len, 1) + zc;
        p (1)    = patch  (SX', SY', SZ', uM (counter));

        % cylinders
        xc       = repmat (x, 1, res);
        xc       = repmat (reshape (xc', numel (xc), 1), 1, 4);
        yc       = repmat (y, 1, res);
        yc       = repmat (reshape (yc', numel (yc), 1), 1, 4);
        zc       = repmat (z, 1, res);
        zc       = repmat (reshape (zc', numel (zc), 1), 1, 4);

        SX       = repmat (0.3 * sc * xX, len, 1) + xc - 0.25 * sc;
        SY       = repmat (0.3 * sc * xY, len, 1) + yc - 0.25 * sc;
        SZ       = repmat (0.2 * sc * xZ, len, 1) + zc + 0.5  * sc;
        p (2)    = patch  (SX', SY', SZ', uM (counter));

        SX       = repmat (0.3 * sc * xX, len, 1) + xc + 0.25 * sc;
        SY       = repmat (0.3 * sc * xY, len, 1) + yc - 0.25 * sc;
        SZ       = repmat (0.2 * sc * xZ, len, 1) + zc + 0.5  * sc;
        p (3)    = patch  (SX', SY', SZ', uM (counter));

        SX       = repmat (0.3 * sc * xX, len, 1) + xc - 0.25 * sc;
        SY       = repmat (0.3 * sc * xY, len, 1) + yc + 0.25 * sc;
        SZ       = repmat (0.2 * sc * xZ, len, 1) + zc + 0.5  * sc;
        p (4)    = patch  (SX', SY', SZ', uM (counter));

        SX       = repmat (0.3 * sc * xX, len, 1) + xc + 0.25 * sc;
        SY       = repmat (0.3 * sc * xY, len, 1) + yc + 0.25 * sc;
        SZ       = repmat (0.2 * sc * xZ, len, 1) + zc + 0.5  * sc;
        p (5)    = patch  (SX', SY', SZ', uM (counter));

        HP       = [HP; p];
        if ~contains (options, '-e')
            set  (p, ...
                'edgecolor',   'none');       % remove black lines
        end
        if ~contains (options, '-f')
            set  (p, ...
                'facealpha',   nM (counter)); % increase opacity / density
        end
    end
end
if sum   (get (gca, 'Dataaspectratio') == [1 1 1]) ~= 3
    axis         equal;
end



