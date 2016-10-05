% ELIMT_TREE   Replace multifurcations by multiple bifurcations in a tree.
% (trees package)
% 
% tree = elimt_tree (intree, options)
% -----------------------------------
% 
% Eliminates the trifurcations/multifurcations present in the tree's
% adjacency matrix by adding tiny (x-deflected) compartments. The node
% labels are messed up and should be sorted after application of this
% function. This function alters the original morphology minimally!
% 
% Input
% -----
% - intree   ::integer:   index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     '-e'   : echo added nodes
%     {DEFAULT: ''}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% tree         = redirect_tree (sample2_tree, 3);
% elimt_tree   (tree, '-s -e');
%
% See also elim0_tree delete_tree repair_tree
% Uses ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function varargout = elimt_tree (intree, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree)
    tree     = trees{intree};
else
    tree     = intree;
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: nothing}
    options  = '';
end

dA           = tree.dA;            % directed adjacency matrix of tree
num          = size (dA, 1);       % number of nodes in tree
sumdA        = ones (1, num) * dA; % typeN: (actually faster than sum (dA))
itrif        = find (sumdA > 2);   % find trifurcations

for counter      = 1 : length (itrif)
    N            = size  (dA, 1);
    fed          = sumdA (itrif (counter)) - 2;
    dA           = [[dA; (zeros (fed, num))], (zeros (fed + num, fed))];
    % lengthen all vectors of form Nx1
    S            = fieldnames (tree);
    for counterS       = 1 : length (S)
        if ~strcmp (S{counterS}, 'dA')
            vec  = tree.(S{counterS});
            if isvector (vec) && (numel (vec) == N) && ~(ischar (vec))
                if strcmp  (S{counterS}, 'X'),
                    tree.X = [tree.X; ...
                        (ones (fed, 1) .* ...
                        tree.X (itrif (counter))) + ...
                        (0.0001 * (1 : fed)')];
                else
                    tree.(S{counterS}) = [tree.(S{counterS}); ...
                        (ones (fed, 1) .* ...
                        tree.(S{counterS})(itrif (counter)))];
                end
            end
        end
    end
    ibs          = find (dA(:, itrif (counter)) == 1);
    num          = num + 1;
    dA (num,     itrif (counter)) = 1;
    dA (ibs (2), itrif (counter)) = 0;
    dA (ibs (2), num)             = 1;
    for counterdA  = 3 : sumdA (itrif (counter)) - 1
        num      = num + 1;
        dA (num, num - 1)                   = 1;
        dA (ibs (counterdA), itrif (counter)) = 0;
        dA (ibs (counterdA), num)             = 1;
    end
    dA (ibs (sumdA (itrif (counter))), itrif (counter)) = 0;
    dA (ibs (sumdA (itrif (counter))), num)             = 1;
end
tree.dA          = dA;

if strfind       (options, '-s')   % show option
    clf; hold on;
    xplore_tree  (tree);
    if ~isempty  (itrif)
        pointer_tree (intree, itrif);
    end
    title        ('eliminate trifurcations');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

if strfind       (options,'-e')
    display      ([...
        'elimt_tree: eliminated ' ...
        (num2str (length (itrif))) ...
        ' trifurcations']);
end

if (nargout == 1) || (isstruct (intree))
    varargout{1}  = tree;
else
    trees{intree} = tree;
end

