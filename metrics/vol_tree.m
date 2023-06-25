% VOL_TREE   Volume values for all segments in a tree.
% (trees package)
%
% vol = vol_tree (intree, options)
% --------------------------------
%
% Returns the volume of all tree segments (in um3).
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
% - vol      ::Nx1 vector: volume values of each segment
%
% Example
% -------
% vol_tree     (sample_tree, '-s')
%
% See also len_tree cvol_tree surf_tree
% Uses len_tree ver_tree D
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function vol = vol_tree (intree, options)

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
            (trees{intree}.frustum == 1),
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
    options = '';
end

len              = len_tree   (intree); % length values of tree segments
if isfrustum
    idpar        = idpar_tree (intree); % indices to direct parent
    % volume according to frustum (cone) -like  segments:
    vol          = (pi .* len .* ...
        (D.^2 + D .* D (idpar) + D (idpar).^2)) / 12;
else
    % volume according to cylinder segments:
    vol          = (pi .* len .* ...
        (D.^2)) / 4;
end

if contains (options, '-s') % show option
    ipart        = find (vol ~= 0); % single out non-0-length segments
    clf;
    hold         on;
    HP           = plot_tree (intree, vol (ipart), [], ipart, [], '-b');
    set          (HP, ...
        'edgecolor',           'none');    
    colorbar;
    title        ( ...
        ['volumes in \mum^3 [total ' (num2str (round (sum (vol)))) ']']);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

% in cm3 it would be:
% vol = vol / 1000000000000; % astounding scaling factors from um3 to cm3


