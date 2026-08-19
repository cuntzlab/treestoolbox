% SCALES_TREE   Scales a tree.
% (trees package)
%
% [xtree, sc, S] = scaleS_tree (intree, tS, options, alpha)
% ---------------------------------------------------------
%
% Scales the entire tree in 2D to ensure that the tree covers a target
% surface tS.
% NOTE: make sure tree is resampled to high resolution.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - tS       ::scalar:  target surface
%     {DEFAULT: 1,000,000um3}
% - options  ::string:
%     '-s'   : show before and after
%     '-b'   : uses boundary, then also uses alpha (see "boundary")
%     '-d'   : do not scale diameter
%     '-r'   : resample
%     {DEFAULT: '-r'}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
% - sc       :: scaling factor
% - S        :: original surface value
%
% Example
% -------
% scaleS_tree   (sample_tree, 1000000, '-s')
%
% See also tran_tree scaleV_tree theta_tree theta_mc_tree
% Uses tran_tree ver_tree X Y Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2026  Hermann Cuntz

function varargout = scaleS_tree (intree, tS, options, alpha)

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
tree         = intree;

if (nargin < 2) || isempty (tS)
    % {DEFAULT: 1,000,000 um3}
    tS       = 1000000; 
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '-r';
end

if (nargin < 4) || isempty (alpha)
    alpha    = 0.5;
end

radius           = round     (sqrt (     ...
    (max (tree.X) - min (tree.X)) .* ...
    (max (tree.Y) - min (tree.Y))) /2);

if contains      (options, '-b')
    [~, S]           = span_tree     (tree, radius, '-b');
    % scale tree to surface area of diamond shape:
    scaler           = sqrt      (tS ./ S);
    xtree            = scale_tree    (tree,  scaler);
    xradius          = round     (sqrt (     ...
        (max (xtree.X) - min (xtree.X)) .* ...
        (max (xtree.Y) - min (xtree.Y))) /2);
    [~, xS]          = span_tree     (xtree, xradius, '-b');
    % by scaling twice:
    scaler2          = sqrt      (tS ./ xS);
    xtree            = scale_tree    (xtree, scaler2);
    sc               = scaler * scaler2;
    if contains      (options, '-r')
    % this time resample tightly:
        xtree            = resample_tree (xtree, 1, 'none');
    end    
else
    [~, S]           = span_tree     (tree, radius, 'none');
    % scale tree to surface area of diamond shape:
    scaler           = sqrt      (tS ./ S);
    xtree            = scale_tree    (tree,  scaler);
    xradius          = round     (sqrt (     ...
        (max (xtree.X) - min (xtree.X)) .* ...
        (max (xtree.Y) - min (xtree.Y))) /2);
    [~, xS]          = span_tree     (xtree, xradius, 'none');
    % by scaling twice:
    scaler2          = sqrt      (tS ./ xS);
    xtree            = scale_tree    (xtree, scaler2);
    sc               = scaler * scaler2;
    if contains      (options, '-r')
        % this time resample tightly:
        xtree        = resample_tree (xtree, 1, 'none');
    end
end

if contains      (options, '-s') % show option
    clf;
    hold         on;
    HP           = plot_tree (tree, [], [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    HP           = plot_tree (xtree, [1 0 0], [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, ...
        {'before',             'after'});
    set          (HP, ...
        'visible',             'off');
    title        ('scale a tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]'); 
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

if (nargout >= 1)||(isstruct (intree))
    varargout{1}   = xtree; % if output is defined then it becomes the tree
end

if (nargout > 1)
    varargout{2}   = sc;
end

if (nargout > 2)
    varargout{3}   = S;
end



