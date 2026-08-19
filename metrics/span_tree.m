% SPAN_TREE   Calculate spanning area
% (trees package)
%
% [M, S] = span_tree (intree, radius, options, alpha)
% ---------------------------------------------------
%
% 2D spanning field of any given tree by morphological operations: first
% dilating and then eroding. Alternatively, the boundary is used (but
% boundaries using alpha shapes are less tight than using morphological
% operators).
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - radius   ::value:   diameter of morphological closing
%     {DEFAULT: Square root of bounding box}
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     '-b'   : uses boundary, then also uses alpha (see "boundary")
%     '-noM' : output only surface area
%     {DEFAULT '-w'}
% - alpha    ::value between 0..1: convexity for boundary function
%     {DEFAULT 0.5}
%
% Output
% ------
% - theta    ::value:
% - S        ::matrix: tight contour in matrix form 1: in tree; 0: outside
%
% Example
% -------
% span_tree    (sample_tree, 20, '-s')
%
% See also theta_tree theta_mc_tree scaleS_tree scaleV_tree
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz

function varargout = span_tree (intree, radius, options, alpha)

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function:
tree         = intree; % Actually only uses X and Y

if (nargin < 2) || isempty (radius)
    radius           = round     (sqrt (     ...
        (max (tree.X) - min (tree.X)) .* ...
        (max (tree.Y) - min (tree.Y))) /2);
end

if (nargin < 3) || isempty (options)
    options  = 'none';
end

if (nargin < 4) || isempty (alpha)
    alpha = 0.5;
end

span             = round (max ( ...
    max (abs (min (tree.X)), max (tree.X)), ...
    max (abs (min (tree.Y)), max (tree.Y)))) + radius;
if contains      (options, '-b')
    if contains  (options, '-noM')
        [~, S]   = boundary (tree.X, tree.Y, alpha);
    else
        [k, S]   = boundary (tree.X, tree.Y, alpha);
        [XX, YY] = meshgrid ( ...
            1 : 2 * span + 1, ...
            1 : 2 * span + 1);
        M        = double (inpolygon (YY, XX, ...
            round (tree.Y(k)) + span + 1, ...
            round (tree.X(k)) + span + 1));
    end
else
    M            = zeros         (2 * span + 1, 2 * span + 1);
    M ( ...
        sub2ind (size (M), ...
        round (tree.Y) + span + 1, ...
        round (tree.X) + span + 1)) = 1;
    se           = strel    ('disk', radius, 4); % resolution
    M            = imdilate (M, se);
    M            = imerode  (M, se);
    S            = sum (sum (M));
end

if contains (options, '-s') && ~contains (options, '-noM')
    clf;
    hold         on ;
    axis         equal off
    imagesc      (-span : span, -span : span, M);
    plot_tree    (tree, [1 0 0], [], [], [], '-b');
    xlim         ([-span span]);
    ylim         ([-span span]);
    title        ('distance matrix');
    colormap     gray
    colorbar
end

if contains  (options, '-noM')
    varargout{1}   = S;
else
    varargout{1}   = M;
end

if (nargout > 1)
    varargout{2}   = S;
end


