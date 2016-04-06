% CVOL_TREE   Continuous volume of segments in a tree.
% (trees package)
%
% cvol = cvol_tree (intree, options)
% ----------------------------------
%
% Returns the continuous volume of all compartments [in 1/um]. This is
% used by  electrotonic calculations in relation to the specific axial
% resistance [ohm cm], see "sse_tree".
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%      {DEFAULT: ''}
%
% Output
% -------
% - cvol     ::Nx1 vector: continuous volume values for each segment
%
% Example
% -------
% cvol_tree    (sample_tree, '-s')
%
% See also len_tree surf_tree vol_tree sse_tree
% Uses len_tree ver_tree D
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function cvol = cvol_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

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

% vector containing length values of tree segments:
len              = len_tree (intree);
if isfrustum
    % vector containing index to direct parent:
    idpar        = idpar_tree (intree);
    % continuous volumes according to frustum (cone) -like segments
    % NOTE! not sure about this:
    cvol         = (12 * len) ./ ...
        (pi * (D.^2 + D.*D (idpar) + D (idpar).^2));
    cvol (cvol == 0) = 0.0001; % !!!!!!!! necessary numeric correction
else
    % continuous volumes according to cylinder segments:
    cvol         = (4  * len) ./ ...
        (pi * (D.^2)); 
    cvol (cvol == 0) = 0.0001; % !!!!!!!! necessary numeric correction
end

if strfind       (options, '-s') % show option
    clf; hold on; 
    HP           = plot_tree (intree, cvol, [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    colorbar;
    title        ('continuous volume');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

% in 1/cm it would be:
% cvol = cvol * 10000; % astounding scaling factors from um to cm



