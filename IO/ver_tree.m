% VER_TREE   Verifies the integrity of a tree.
% (trees package)
%
% ver_tree (intree)
% -----------------
%
% verifies the integrity of a tree and creates warnings that precede common
% errors. Is called by basically every single TREES package function. Could
% be useful for something else maybe...
%
% Input
% -----
% intree::integer:index of tree in trees or structured tree
%
% Output
% ------
% issues warnings ...
% and returns true or false if a warning was issued
%
% Example
% -------
% sample = sample_tree; sample.X = 0;
% ver_tree (sample);
%
% See also start_trees
% Uses X Y Z D R dA
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function no_error = ver_tree (intree)

% trees : contains the tree structures in the trees package
global trees

% use full tree for this function
if ~isstruct (intree),
    tree = trees {intree};
else
    tree = intree;
end

no_error = true;

if isfield (tree, 'dA'),
    if length (size (tree.dA)) ~= 2,
        warning ('Trees:NoTree', 'adjacency matrix incorrect dimensions');
        no_error = false;
    else
        if size (tree.dA, 1) ~= size (tree.dA, 2),
            warning ('Trees:NoTree', 'adjacency matrix not square');
            no_error = false;
        end
    end
else
    warning ('Trees:NoTree', 'missing adjacency matrix');
    no_error = false;
end

if isfield (tree, 'X'),
    if (size (tree.X, 2) ~= 1) || (length (size (tree.X)) ~= 2),
        warning ('Trees:NoTree', 'X not vertical vector');
        no_error = false;
    end
    if size (tree.X, 1) ~= size (tree.dA, 1),
        warning ('Trees:NoTree', 'X size not compatible with adjacency matrix');
        no_error = false;
    end
end

if isfield (tree, 'Y'),
    if (size (tree.Y, 2) ~= 1) || (length (size (tree.Y)) ~= 2),
        warning ('Trees:NoTree', 'Y not vertical vector');
        no_error = false;
    end
    if size (tree.Y, 1) ~= size (tree.dA, 1),
        warning ('Trees:NoTree', 'Y size not compatible with adjacency matrix');
        no_error = false;
    end
end

if isfield (tree, 'Z'),
    if (size (tree.Z, 2) ~= 1) || (length (size (tree.Z)) ~= 2),
        warning ('Trees:NoTree', 'Z not vertical vector');
        no_error = false;
    end
    if size (tree.Z, 1) ~= size (tree.dA, 1),
        warning ('Trees:NoTree', 'Z size not compatible with adjacency matrix');
        no_error = false;
    end
end

if isfield (tree, 'D'),
    if (size (tree.D, 2) ~= 1) || (length (size (tree.D)) ~= 2),
        warning ('Trees:NoTree', 'D not vertical vector');
        no_error = false;
    end
    if size (tree.D, 1) ~= size (tree.dA, 1),
        warning ('Trees:NoTree', 'D size not compatible with adjacency matrix');
        no_error = false;
    end
end

if isfield (tree, 'R'),
    if (size (tree.R, 2) ~= 1) || (length (size (tree.R)) ~= 2),
        warning ('Trees:NoTree', 'R not vertical vector');
        no_error = false;
    end
    if size (tree.R, 1) ~= size (tree.dA, 1),
        warning ('Trees:NoTree', 'R size not compatible with adjacency matrix');
        no_error = false;
    end
end
