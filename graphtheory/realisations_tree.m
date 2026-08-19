% REALISATIONS_TREE   Number of realisations for a given tree.
% (trees package)
%
% realisations = realisations_tree (intree, V, options)
% -----------------------------------------------------
%
% Returns the number of realisations for a tree after calculating the
% barcode using persistence homology, see Kanari et al. 2018 for more
% details.
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - V        ::Nx1 vector:   for each node a number to be accumulated
%     {DEFAULT: len}
% - options  ::string:
%     {DEFAULT: ''}
%
% Output
% -------
% - barcode  ::Nx1 vector: length values of each segment
%
% Example
% -------
% realisations = realisations_tree (sample_tree)
%
%
% Interpreted from Kanari et al 2018 with help from Lida Kanari.
%
% See also BLO_tree barcode_tree
% Uses barcode_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz

function realisations = realisations_tree (intree, V, options)

% use full tree or previously calculated bar codes
if ~isstruct (intree)
    branches = intree;
else
    ver_tree (intree); % verify that input is a tree structure
    tree     = intree;
end

if exist ('tree', 'var')
    if (nargin < 2) || isempty (V)
        % {DEFAULT: length of segment in um, this way path length determines
        % order}
        V    = len_tree (tree);
    end
    branches = barcode_tree (tree, V);
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

N                = size (branches, 1);
branches         = sortrows (branches);
realisations     = 1;
for counter      = 1 : N - 1
    indy         = N + 1 - counter;
    ibranch      = ...
        (branches (indy, 1) >= branches (:, 1)) & ...
        (branches (indy, 1) <= branches (:, 2));
    ibranch (indy) = 0;
    ibranch      = find (ibranch);
    realisations = realisations * length (ibranch);
end



