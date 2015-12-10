% XDEND_TREE   Dendrogram X-coordinates of a tree.
% (trees package)
% 
% [xdend, tree] = xdend_tree (intree, options)
% --------------------------------------------
%
% Returns a vector of x-values useful for constructing a dendrogram. Each
% element's x-value is set in the middle of the labeled terminal children
% (maximum index + minimum index)/2. Optional output is a correlate
% (equivalent) tree to intree with same branch lengths and topology but
% with standard and sorted metrics. Branch overlap is also avoided if
% possible etc... intree must be in BCT conform format. If unsure just
% apply repair_tree beforehand.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     {DEFAULT '-w'}
%
% Output
% ------
% - xdend    ::vector:       x-values
% - tree     ::tree:         standard tree with exact same electrotonic
%     properties as original but completely lost metric coordinates
%
% Example
% -------
% xdend_tree   (sample_tree, '-s')
%
% See also   dendrogram_tree BCT_tree allBCTs_tree
% Uses       ipar_tree T_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [xdend, tree] = xdend_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

ver_tree     (intree);                 % verify that input is a tree

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

% xdend is (minT + maxT) ./ 2 after labeling terminals with T_tree
% this is still tricky because we have to obtain 
% minT and maxT from ipar (T) - 
% parent index structure (see "ipar_tree"):
ipar         = ipar_tree (intree);
% parent index path only for termination points:
iparT        = ipar      (T_tree (intree), :);
% sorting iparT as a vector:
[i1, i2]     = sort      (reshape (iparT', numel (iparT'), 1));
[~, b]       = ind2sub   (size (iparT'), i2); % b is the label
di           = [0; (diff (i1))];
idi          = [(diff (i1)); 1];
minT         = b (di  == 1);
maxT         = b (idi == 1);
maxT         = maxT (2 : length (maxT));
xdend        = (maxT + minT) ./ 2;     % there you go

if (nargout > 1) || ~isempty (strfind (options, '-s'))
    if ~isstruct (intree)
        tree     = trees{intree};
    else
        tree     = intree;
    end
    angle        = pi - 2 * pi * xdend ./ max (xdend);
    N            = length (xdend);
    PL           = PL_tree (tree);
    if isfield   (tree, 'X')
        len      = len_tree (tree);
        tree.X   = cos   (angle) .* PL;
        tree.Y   = sin   (angle) .* PL;
        tree.Z   = zeros (N, 1);
    else
        tree.X   = cos   (angle) .* PL;
        tree.Y   = sin   (angle) .* PL;
        tree.Z   = zeros (N, 1);
        tree.D   = ones  (N, 1);
        tree.R   = ones  (N, 1);
        tree.rnames = {'region1'};
        % replacement length of segment values:
        len      = 10 * ones (N, 1);
    end
    % (avoid showing result as well but conserve waitbar)
    if strfind   (options, '-w')
        tree     = morph_tree (tree, len, '-w');
    else
        tree     = morph_tree (tree, len, 'none');
    end
end

if strfind       (options, '-s') % show option
    clf; hold on;
    HP           = plot_tree (intree, [], -150);
    set          (HP, 'facealpha', .5);
    HP           = plot_tree (tree,   [1 0 0]);
    set          (HP, 'facealpha', .5);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
    title        ('equivalent tree');
end






