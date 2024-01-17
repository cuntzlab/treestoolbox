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
% Copyright (C) 2009 - 2023  Hermann Cuntz

function cvol = cvol_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('s', false, @isBinary)

numParams = numel(varargin);
if (numParams > 0 && ~startsWith(varargin{1}, '-')) || numParams == 0
    p.parse(varargin{:})
else
    args = parsePositionalArgs(varargin, {}, {'s'}, 1);
    p.parse(args{:})
end
params = p.Results;
%==============================================================================%

% use only local diameters vector for this function
isfrustum    = 0;
D            = intree.D;
if isfield (intree, 'frustum') && intree.frustum == 1
    isfrustum  = 1;
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

if params.s % show option
    clf;
    hold         on; 
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

