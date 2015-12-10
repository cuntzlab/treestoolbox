% VOL_TREE   Volume values for all segments in a tree.
% (trees package)
%
% vol = vol_tree (intree, options)
% --------------------------------
%
% returns the volume of all compartments (in um3)
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - options::string: {DEFAULT: ''}
%     '-s'  : show
%
% Output
% -------
% - vol::Nx1 vector: volume values of each segment
%
% Example
% -------
% vol_tree (sample_tree, '-s')
%
% See also len_tree cvol_tree surf_tree
% Uses len_tree ver_tree D
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function vol = vol_tree (intree, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length(trees); % {DEFAULT tree: last tree in trees cell array} 
end;

ver_tree (intree); % verify that input is a tree structure

% use only local diameters vector for this function
isfrustum = 0;
if ~isstruct (intree),
    D = trees {intree}.D;
    if isfield (trees {intree}, 'frustum') && (trees {intree}.frustum == 1),
        isfrustum = 1;
    end
else
    D = intree.D;
    if isfield (intree, 'frustum') && (intree.frustum == 1),
        isfrustum = 1;
    end
end

if (nargin < 2)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

len = len_tree (intree); % vector containing length values of tree segments
if isfrustum,
    idpar = idpar_tree (intree); % vector containing index to direct parent
    % volume according to frustum (cone) -like  segments:
    vol = (pi.*(D.^2 + D.*D(idpar) + D(idpar).^2).*len) / 12;
else
    vol = (pi.*(D.^2).*len) / 4; % volume according to cylinder segments
end

if strfind (options, '-s'), % show option
    ipart = find (vol ~= 0);
    clf; shine; hold on; plot_tree (intree, vol (ipart), [], ipart); colorbar;
    title  (['volumes in \mum^3 [total ' num2str(round (sum (vol))) ']']);
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view (2); grid on; axis image;
end

% in cm3 it would be:
% vol = vol / 1000000000000; % astounding scaling factors from um3 to cm3
