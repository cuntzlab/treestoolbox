% SURF_TREE   Surface values for tree segments.
% (trees package)
%
% surf = surf_tree (intree, options)
% ----------------------------------
%
% Returns the surface of all tree segments using the X,Y,Z and D
% coordinates and the adjacency matrix [in um2].
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
% - surf     ::Nx1 vector: surface values of each segment
%
% Example
% -------
% surf_tree    (sample_tree, '-s')
%
% See also len_tree cvol_tree vol_tree
% Uses len_tree ver_tree D
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function surf = surf_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

% use only local diameters vector for this function
isfrustum    = 0;
if ~isstruct (intree)
    D        = trees{intree}.D;
    if ...
            (isfield (trees{intree}, 'frustum')) && ...
            (trees{intree}.frustum == 1)
        isfrustum  = 1;
    end
else
    D        = intree.D;
    if ...
            (isfield (intree, 'frustum')) && ...
            (intree.frustum == 1)
        isfrustum  = 1;
    end
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

len              = len_tree   (intree); % length values of tree segments
if isfrustum
    idpar        = idpar_tree (intree); % indices to direct parent
    % surface according to frustum (cone) like segments:
    surf         = (pi * (D + D (idpar)) / 2) .* ...
        sqrt   (len.^2 + (D - D (idpar)).^2 / 4);
else
    % surface according to cylinder segments:
    surf         =  pi *  D .* len;
end

if contains (options, '-s') % show option
    ipart        = find (surf ~= 0); % single out non-0-length segments
    clf;
    hold         on;
    HP           = plot_tree (intree, surf (ipart), [], ipart, [], '-b');
    set          (HP, ...
        'edgecolor',           'none');    
    colorbar;
    title        ( ...
        ['surface in \mum^2 [total ' (num2str (round (sum (surf)))) ']']);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

% in cm2 it would be:
% surf = surf / 100000000; % astounding scaling factors from um2 to cm2


