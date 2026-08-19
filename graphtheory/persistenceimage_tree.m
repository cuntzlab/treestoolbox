% PERSISTANCEIMAGE_TREE   Topological density.
% (trees package)
%
% CM = persistenceimage_tree (intree, options)
% ----------------------------------------------
%
% Returns the persistence image using persistence homology in form of a
% density matrix CM.
% This is a META-FUNCTION and can lead to various applications.
%
% Input
% -----
% - intree   ::integer: structured tree or cell array of trees
% - options  ::string:
%     '-l'   : use path lengths
%     '-E'   : use Euclidean distances
%     '-t'   : use topological paths (number of nodes)
%     '-s'   : show
%     {DEFAULT: '-s -l'}
%
% Output
% -------
% -  CM      ::Matrix: Density matrix of bars
%
% Example
% -------
% persistenceimage_tree     (sample_tree, '-s -l')
%
% Interpreted from Kanari et al., 2018 with help from Lida Kanari.
%
% See also barcode_tree and BLO_tree
% Uses ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz

function CM = persistenceimage_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees {intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

if contains      (options, '-E')
    % Euclidean distances (shouldn't work like this.., needs adjustment)
    V        = eucl_tree (tree);
elseif contains      (options, '-t')
    % Topological path length
    V        = ones (size (tree.dA, 1), 1);
else
    % {DEFAULT: length of segment in um, this way path length determines
    % order}
    V        = len_tree (tree);
end

barcode          = barcode_tree (tree, V);
birth            = barcode (:, 1);
death            = barcode (:, 2);
N                = size (barcode, 1);


[XX, YY]         = meshgrid (-1 : 0.02 : 1, -1 : 0.02 : 1);
G                = ...
    gauss (XX, 0, 0.35) .* ...
    gauss (YY, 0, 0.35);
G                = G ./ sum (sum (G));
SZ               = round (1.25 * max (death));
M                = zeros (SZ, SZ);
M (sub2ind (size (M), round (death), round (birth) + 1)) = 1;
M                = M';
CM               = convn (M, G, 'same');


if contains      (options, '-s') % show option
    clf;
    colormap         gray
    hold             on;
    axis             equal
    imagesc          (1 - CM);
    scatter          (death, birth, 8, [1 0 0], 'o', 'filled');
    plot             (max (death) * [0 1.5], max (death) * [0 1.5], 'k');
    plot             (max (death) * [0 1.5], max (death) * [1 1],   'k--');
    plot             (max (death) * [1 1],   max (death) * [0 1.5], 'k--');
    xlim             (max (death) * [0 1.1]);
    ylim             (max (death) * [0 1.1]);
    xlabel           ('Death');
    ylabel           ('Birth');

end



