% CYL_TREE   Cylinder coordinates of all segments in a tree.
% (trees package)
%
% [X1, X2, Y1, Y2 ,Z1, Z2] = cyl_tree (intree, options)
% -----------------------------------------------------
%
%       OR (if only one output):
%
% M = cyl_tree (intree, options)
% ------------------------------
%
% Uses the adjacency matrix to obtain the starting and ending points of the
% individual compartments.
%
% NOTE !! this function does not have a "show" option
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - options  ::string:
%     '-2d'  : output is only X and Y
%     '-dA'  : XYZ values are written in the correct location of the
%             adjacency matrix (slower)
%     {DEFAULT : ''}
%
% Output
% ------
% result     ::matrix, if one output: [X1 X2 Y1 Y2 {Z1 Z2}]
%    4 or 6 vertical vectors otherwise. if options is 'dA' then it is
%    4 or 6 matrices and output in one matrix only does not work (returns
%    X1)
%
% Example
% -------
% [X1, X2, Y1, Y2, Z1, Z2] = cyl_tree (sample_tree)
%
% See also idpar_tree
% Uses idpar_tree ver_tree dA X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function  [X1, X2, Y1, Y2, Z1, Z2] = cyl_tree (intree, options)

% trees : contains the dendrites in the trees package
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

X                = tree.X;         % X-locations of nodes on tree
Y                = tree.Y;         % Y-locations of nodes on tree
dA               = tree.dA;        % directed adjacency matrix of tree

if ~contains (options, '-dA')
     % vector containing index to direct parent:
    idpar        = idpar_tree (intree);
    X1           = X (idpar); % then it is simple, right?
    X2           = X;
    Y1           = Y (idpar);
    Y2           = Y;
    if ~contains (options, '-2d')
        Z        = tree.Z;
        Z1       = Z (idpar);
        Z2       = Z;
        M        = [X1 X2 Y1 Y2 Z1 Z2];
    else
        M        = [X1 X2 Y1 Y2];
    end
    if nargout   == 1
        X1       = M;
    end
else
    % SPECIAL : in adjacency form! SLOW!!
    % (application of adjacency matrix in both directions to find starting
    % and ending of all edges)
    N            = length (X); % number of nodes in tree
    % coordinates of first point in cylinder:
    X1           = dA * spdiags (X, 0, N, N);
    Y1           = dA * spdiags (Y, 0, N, N);
    % coordinates of second point in cylinder:
    X2           =      spdiags (X, 0, N, N) * dA;
    Y2           =      spdiags (Y, 0, N, N) * dA;
    if ~contains (options, '-2d')
        Z        = tree.Z;
        Z1       = dA * spdiags (Z, 0, N, N);
        Z2       =      spdiags (Z, 0, N, N) * dA;
    end
    % the sum of the elements over the rows would actually result in the
    % vector coordinates as above:
    % X1         = X1 * ones (N, 1);
    % X2         = X2 * ones (N, 1);
    % Y1         = Y1 * ones (N, 1);
    % Y2         = Y2 * ones (N, 1);
end


