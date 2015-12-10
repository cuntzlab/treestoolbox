% LEN_TREE   Length values of tree segments.
% (trees package)
%
% len = len_tree (intree, options)
% --------------------------------
%
% returns the length of all compartments from the X,Y and Z
% coordinates and the adjacency matrix [in um]
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - options::string: {DEFAULT: ''}
%     '-2d' : 2-dimensional lengths
%     '-s'  : show
%
% Output
% -------
% - len::Nx1 vector: length values of each segment
%
% Example
% -------
% len_tree (sample_tree, '-s')
%
% See also cvol_tree vol_tree surf_tree
% Uses cyl_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function len = len_tree (intree, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length(trees); % {DEFAULT tree: last tree in trees cell array} 
end;

ver_tree (intree); % verify that input is a tree structure

if (nargin < 2)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

if strfind (options, '-2d'),
    [X1 X2 Y1 Y2] =       cyl_tree (intree, '-2d'); % segments 2D start and end coordinates
    len = sqrt ((X2 - X1).^2 + (Y2 - Y1).^2);
else
    [X1 X2 Y1 Y2 Z1 Z2] = cyl_tree (intree); % segments start and end coordinates
    len = sqrt ((X2 - X1).^2 + (Y2 - Y1).^2 + (Z2 - Z1).^2);
end

if strfind (options, '-s'), % show option
    ipart = find (len ~= 0); % single out non-0-length segments
    clf; shine; hold on; plot_tree (intree, len (ipart), [], ipart); colorbar;
    title  (['lengths in \mum [total ' num2str(round (sum (len))) ']' ]);
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view(2); grid on; axis image;
end

% in cm it would be:
% len = len / 10000; % astounding scaling factors from um to cm
