% IPAR_TREE   Path to root: parent indices. 
% (trees package)
% 
% ipar = ipar_tree (intree, options, ipart)
% -----------------------------------------
%
% Returns the matrix of indices to the parent of individual nodes following
% the path against the direction of the adjacency matrix tocounter the root of
% the tree. This function is crucial to many other functions based on graph
% theory in the trees package.
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - options  ::string:
%     '-T'   : Only paths from termination point to first branch point
%     '-s'   : show
%     {DEFAULT: ''}
% - ipart    ::index:        index to the subpart to be plotted
%                            (if '-T', selects terminals only from ipart)
%     {DEFAULT: all nodes}
%
% Output
% ------
% - ipar     ::matrix:       all path indices of parent nodes for each node
%
% Example
% -------
% ipar_tree    (sample_tree, [], '-s')
%
% See also   idpar_tree child_tree
% Uses       PL_tree ver_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function ipar = ipar_tree (intree, varargin)

ver_tree     (intree);                 % verify that input is a tree
% use only directed adjacency for this function
dA       = intree.dA;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('ipart', []) % TODO check the size and type of fac
p.addParameter('T', false, @isBinary)
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {'ipart'}, {'T', 's'});
%==============================================================================%

% number of nodes in tree:
N                = size (dA, 1);
% maximum depth by maximum path length:
maxPL            = max  (PL_tree (intree));
V                = (1 : N)';
ipar             = zeros (N, maxPL + 2);
ipar (:, 1)      = V;
for counter      = 2 : maxPL + 2
    % use adjacency matrix to walk through tree:
    V            = dA * V;
    ipar (:, counter) = V;
end

if pars.T % Only terminal branches
    B            = B_tree       (intree);
    T            = T_tree       (intree);
    if ~isempty  (pars.ipart)
        T        = T (pars.ipart);
    end
    B1           = [0; B];
    ibranch      = cumsum       (B1 (ipar + 1), 2) < 1;
    ipar         = ibranch (T, :) .* ipar (T, :);
elseif ~isempty      (pars.ipart)
    ipar         = ipar (pars.ipart, any (ipar (pars.ipart, :) ~= 0, 1));
end

% if ~isempty      (ipart)
%     ipar         = ipar (ipart, any (ipar (ipart, :) ~= 0, 1));
% end

if pars.s % show option
    clf;
    imagesc      (ipar);
    ylabel       ('node #');
    xlabel       ('parent path');
    colorbar;
    title        ('color: parent node #');
end

% % stupid concatenation issue (2.5 sec.. for hss):
% N        = size (dA, 1);
% V        = (1 : N)';
% ipar     = V;
% while    sum (V) ~= 0
%     V    = dA * V;
%     ipar = [ipar V];
% end

% % ALSO POSSIBLE but slower (something like):
% for counter = 0 : N
%     ipar = [ipar (dA^counter)*(1:N)'];
% end

