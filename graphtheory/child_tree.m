% CHILD_TREE   Attribute add-up child node values all nodes in a tree.
% (trees package)
% 
% child = child_tree (intree, v, options)
% ---------------------------------------
%
% Returns a vector with the added up values in v of all child nodes
% excluding itself. This is done for each node in the tree.
% This is a META-FUNCTION and can lead to various applications.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - v        ::Nx1 vector:   values to be integrated
%     {DEFAULT: ones, number of child nodes}
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - child    ::Nx1 vector: accumulated values of all children to each node
%
% Example
% -------
% child_tree   (sample_tree, [], '-s')
%
% See also   ipar_tree ratio_tree LO_tree
% Uses       ipar_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function child = child_tree (intree, v, options)

ver_tree     (intree); % verify that input is a tree structure

% parent index structure (see "ipar_tree"):
ipar         = ipar_tree (intree);
% number of nodes in tree:
N            = size      (ipar, 1);

if (nargin < 2) || isempty (v)
    % {DEFAULT vector: ones, results in counting child nodes}
    v        = ones (N, 1);
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

v                = [0; v];
ipar2            = [ ...
    (zeros (1, size (ipar, 2) - 1)) ; ...
    (ipar  (:, 2 : end))];
% accumulate along parent paths:
child            = accumarray ( ...
    reshape (ipar2 + 1, numel (ipar2), 1), ...
    repmat  (v, size (ipar2, 2), 1));
child            = child (2 : end);
if size          (child, 1) < N
    child (N)    = 0;
end

if contains (options,'-s') % show option
    clf;
    hold         on; 
    plot_tree    (intree, child);
    colorbar;
    title        ('child count');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

%%% ALSO (mathematically more logical but more time consuming):
%
%%% columnsum of sum (A^i)
%
% dA           = trees (index).dA;
% resW         = dA;
% N            = dA;
% while full  (sum (sum (resW))) ~=0
%     resW    = dA * resW;
%     N       = N + resW;
% end
% result      = full (sum (N));

