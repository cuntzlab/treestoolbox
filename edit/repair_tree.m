% REPAIR_TREE   Rectify tree format to complete BCT conformity.
% (trees package)
% 
% tree = repair_tree (intree, options)
% ------------------------------------
%
% Repairs a tree. This means removing trifurcations by adding small
% segments, removing 0-length compartments, and sorting the indices to be
% BCT conform and lexicographically Level-Order left. Applying this
% function is crucial for many other functions in this toolbox which assume
% for example BCT-conformity.
% This function may alter the original morphology minimally!
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% repair_tree  (sample_tree, '-s')
% % however, no sample tree needs repairing of course...
%
% See also elim0_tree elimt_tree sortLO_tree
% Uses ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function varargout = repair_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

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

% eliminate trifurcations by adding short segments:
tree         = elimt_tree (tree);        
% eliminate 0-length compartments:
tree         = elim0_tree (tree);        
 % sort tree to be BCT conform, heavy parts left:
tree         = sort_tree  (tree, '-LO');

if strfind       (options, '-s') % show option
    clf; hold on; 
    xplore_tree  (intree, [], [], -20);
    xplore_tree  (tree,   [], [0 1 0]);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'g-');
    legend       (HP, ...
        {'before',             'repaired'});
    set          (HP, ...
        'visible',             'off');
    title        ('repair a tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

if (nargout == 1) || (isstruct (intree))
    varargout{1}   = tree; % if output is defined then it becomes the tree
else
    trees{intree}  = tree; % otherwise original tree in trees is replaced
end
