% ELIM0_TREE   Eliminates zero-length segments in a tree.
% (trees package)
%
% tree = elim0_tree (intree, options)
% -----------------------------------
%
% Deletes points which define a 0-length segment (except first segment of
% course). Updates regions.
%
% Input
% -----
% - intree   ::integer:   index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     '-e'   : message deleted nodes
%     '-r'   : do not update regions
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% tree         = sample2_tree;
% tree.X (5)   = tree.X (4);
% tree.Y (5)   = tree.Y (4);
% tree.Z (5)   = tree.Z (4);
% elim0_tree   (tree, '-s -e')
%
% See also elimt_tree delete_tree repair_tree
% Uses delete_tree len_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function varargout = elim0_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (options)
    % {DEFAULT: nothing}
    options  = '';
end

len          = len_tree (intree);
ilen         = find     (len == 0);

if length (ilen) > 1
    if strfind (options, '-r')
        tree = delete_tree (intree, ilen (2 : end));
    else
        tree = delete_tree (intree, ilen (2 : end), '-r');
    end
else
    % leave tree unchanged
    if ~isstruct (intree)
        tree = trees{intree};
    else
        tree = intree;
    end
end

if strfind   (options, '-e')
    display  ([ ...
        'elim0_tree: deleted ' ...
        (num2str (length (ilen) - 1)) ...
        ' nodes']);
end

if strfind   (options, '-s')
    clf; hold on;
    xplore_tree (tree);
    if ~isempty (ilen (2 : end))
        pointer_tree (intree, ilen (2 : end));
    end
    title    ('eliminate 0-length segments');
    xlabel   ('x [\mum]');
    ylabel   ('y [\mum]'); 
    zlabel   ('z [\mum]');
    view     (2);
    grid     on;
    axis     image;
end

if (nargout == 1) || (isstruct (intree))
    varargout {1}  = tree;
else
    trees {intree} = tree;
end




