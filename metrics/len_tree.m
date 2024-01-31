% LEN_TREE   Length values of tree segments.
% (trees package)
%
% len = len_tree (intree, options)
% --------------------------------
%
% Returns the length of all tree segments using the X, Y and Z coordinates
% and the adjacency matrix [in um].
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options  ::string:
%     '-dim2'  : 2-dimensional lengths (Careful, it used to be '-2d')
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% -------
% - len      ::Nx1 vector: length values of each segment
%
% Example
% -------
% len_tree     (sample_tree, '-s')
%
% See also cvol_tree vol_tree surf_tree
% Uses cyl_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function len = len_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('dim2', false, @isBinary)
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {}, {'dim2', 's'});
%==============================================================================%

if pars.dim2
    % segments 2D start and end coordinates:
    [X1, X2, Y1, Y2]         = cyl_tree (intree, 'dim2', true);
    len          = sqrt ( ...
        (X2 - X1).^2 + ...
        (Y2 - Y1).^2);
else
    % segments start and end coordinates:
    [X1, X2, Y1, Y2, Z1, Z2] = cyl_tree (intree);
    len          = sqrt ( ...
        (X2 - X1).^2 + ...
        (Y2 - Y1).^2 + ...
        (Z2 - Z1).^2);
end

if pars.s % show option
    ipart        = find (len ~= 0); % single out non-0-length segments
    clf;
    hold         on;
    HP           = plot_tree    (intree, len (ipart), [], ipart, [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    colorbar;
    title        ( ...
        ['lengths in \mum [total ' (num2str (round (sum (len)))) ']' ]);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

% in cm it would be:
% len = len / 10000; % astounding scaling factors from um to cm

